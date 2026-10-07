import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/models/get_products_by_product_id_model.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/utils/listing_draft_photos.dart';
import 'package:jebby/utils/product_upload_filename.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/view_models/user_view_model.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class ListingFormController extends GetxController {
  static const _blobKey = 'listing_draft_v2_json';
  static const _legacyActiveKey = 'listing_draft_active';

  ListingDraft draft = ListingDraft();
  bool isEditMode = false;
  bool isLoading = true;
  bool isSubmitting = false;
  bool isSavingDraft = false;
  String? lastPublishedProductId;

  /// Gallery order from the server when edit mode loaded (primary = first).
  List<int> _initialRemoteImageIds = [];

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subcategories = [];
  bool categoriesFailed = false;
  bool subcategoriesFailed = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> bootstrap({
    String? editProductId,
    String? userId,
  }) async {
    isLoading = true;
    update();
    isEditMode = editProductId != null && editProductId.isNotEmpty;
    try {
      if (userId != null && userId.isNotEmpty) {
        draft.userId = userId;
      } else {
        final user = await UserViewModel().getUser();
        draft.userId = user.id.toString();
      }

      if (isEditMode) {
        await hydrateFromProduct(editProductId!);
      } else {
        await _loadDraftBlob();
        await prefillLocationFromUserProfileIfNeeded();
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Step 4 default: item location from the signed-in user's profile address.
  Future<void> prefillLocationFromUserProfileIfNeeded() async {
    if (isEditMode) return;
    if (draft.location.isComplete) return;

    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? row =
        await ApiRepository.shared.fetchUserProfileRow(draft.userId);

    final body = await ApiRepository.shared.fetchUserProfileBody(draft.userId);
    if (body != null && body['data'] is List && (body['data'] as List).isNotEmpty) {
      final first = body['data'][0];
      if (first is Map) {
        row = Map<String, dynamic>.from(first);
      }
    }

    final fromStructured = row != null ? _listingLocationFromProfileRow(row) : null;
    if (fromStructured != null && fromStructured.isComplete) {
      draft.location = fromStructured;
      update();
      return;
    }

    var profileAddress = row?['address']?.toString().trim() ?? '';
    if (profileAddress.isEmpty) {
      profileAddress = (prefs.getString('address') ?? '').trim();
    }
    var latText = row?['latitude']?.toString().trim() ?? '';
    var lngText = row?['longitude']?.toString().trim() ?? '';
    if (latText.isEmpty) latText = (prefs.getString('latitude') ?? '').trim();
    if (lngText.isEmpty) lngText = (prefs.getString('longitude') ?? '').trim();

    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);

    ParsedUsAddress? parsed = fromStructured != null
        ? ParsedUsAddress(
            line1: fromStructured.line1,
            line2: fromStructured.line2,
            city: fromStructured.city,
            state: fromStructured.state,
            postalCode: fromStructured.postalCode,
            formattedAddress: fromStructured.fullAddress,
            latitude: fromStructured.latitude,
            longitude: fromStructured.longitude,
          )
        : null;

    final places = GooglePlacesAddressService();
    if (parsed == null || !parsed.hasLine1) {
      if (lat != null && lng != null) {
        parsed = await places.reverseGeocode(lat, lng);
      }
      if ((parsed == null || !parsed.hasLine1) && profileAddress.isNotEmpty) {
        parsed = await places.geocodeAddress(profileAddress);
      }
    } else if (!parsed.hasCoordinates && lat != null && lng != null) {
      parsed = parsed.copyWith(latitude: lat, longitude: lng);
    }

    if (parsed == null || !parsed.hasLine1) return;

    draft.location = ListingLocation.fromParsed(parsed);
    update();
  }

  ListingLocation? _listingLocationFromProfileRow(Map<String, dynamic> row) {
    final line1 = row['address_line1']?.toString().trim() ?? '';
    if (line1.isEmpty) return null;
    return ListingLocation(
      line1: line1,
      line2: row['address_line2']?.toString().trim() ?? '',
      city: row['address_city']?.toString().trim() ?? '',
      state: row['address_state']?.toString().trim() ?? '',
      postalCode: row['address_postal_code']?.toString().trim() ?? '',
      latitude: double.tryParse(row['latitude']?.toString() ?? ''),
      longitude: double.tryParse(row['longitude']?.toString() ?? ''),
    );
  }

  Future<void> loadCategories() async {
    categoriesFailed = false;
    await ApiRepository.shared.getCategoryList(
      (list) {
        categories = list.data
                ?.map((e) => {
                      'id': e.id.toString(),
                      'name': e.name.toString(),
                    })
                .toList() ??
            [];
        syncCategoryLabelsFromIds();
        update();
      },
      (_) {
        categoriesFailed = true;
        update();
      },
    );
  }

  Future<void> loadSubcategories(String categoryId) async {
    if (categoryId.isEmpty) return;
    subcategoriesFailed = false;
    await ApiRepository.shared.getSubCategoryList(
      (list) {
        subcategories = list.data
                ?.map((e) => {
                      'id': e.id.toString(),
                      'name': e.name.toString(),
                    })
                .toList() ??
            [];
        _applySubcategoryNameFromList();
        update();
      },
      (_) {
        subcategoriesFailed = true;
        update();
      },
      categoryId,
    );
  }

  void _applyCategoryNameFromList() {
    if (draft.categoryId.trim().isEmpty ||
        draft.categoryName.trim().isNotEmpty) {
      return;
    }
    final id = draft.categoryId.trim();
    for (final entry in categories) {
      if ('${entry['id']}' == id) {
        draft.categoryName = entry['name']?.toString() ?? '';
        return;
      }
    }
  }

  void _applySubcategoryNameFromList() {
    if (draft.subcategoryId.trim().isEmpty ||
        draft.subcategoryName.trim().isNotEmpty) {
      return;
    }
    final id = draft.subcategoryId.trim();
    for (final entry in subcategories) {
      if ('${entry['id']}' == id) {
        draft.subcategoryName = entry['name']?.toString() ?? '';
        return;
      }
    }
  }

  /// Fills category/subcategory labels when IDs are known (edit / server draft).
  Future<void> syncCategoryLabelsFromIds() async {
    final categoryId = draft.categoryId.trim();
    if (categoryId.isEmpty) return;

    if (categories.isEmpty) {
      await loadCategories();
    }
    _applyCategoryNameFromList();

    final subcategoryId = draft.subcategoryId.trim();
    if (subcategoryId.isNotEmpty) {
      await loadSubcategories(categoryId);
      _applySubcategoryNameFromList();
    }

    update();
  }

  Future<void> hydrateFromProduct(String productId) async {
    draft.productId = productId;

    final detail = await ApiRepository.shared.fetchProductDetailRaw(productId);
    if (detail != null) {
      draft.name = detail['name']?.toString() ?? '';
      draft.description = detail['description']?.toString() ?? '';
      draft.pricePerDay = detail['price']?.toString() ?? '';
      draft.securityDeposit = detail['security_deposit']?.toString() ?? '0';
      draft.categoryId = detail['category_id']?.toString() ?? '';
      draft.subcategoryId = detail['subcategory_id']?.toString() ?? '';
      _applyProductRow(detail);
    }

    await ApiRepository.shared.getProductsById(
      (list) {
        if (list.data == null || list.data!.isEmpty) return;
        final rows = list.data!;
        final row = rows.first;

        final imageEntries = _productImageEntriesFromRows(rows);
        if (imageEntries.isNotEmpty) {
          draft.photos = imageEntries
              .map(
                (img) => ListingPhotoRef(
                  kind: ListingPhotoKind.remote,
                  path: img.path?.trim() ?? '',
                  remoteId: img.id,
                ),
              )
              .where((p) => p.path.isNotEmpty)
              .toList();
          draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);
          _captureInitialRemoteOrder();
        }

        final transport = row.transport;
        if (transport != null) {
          draft.delivery = DeliveryOptions(
            offersPickup: transport.pickup,
            offersDelivery: transport.delivery,
            deliveryFee: transport.deliveryCharges ?? '0',
            deliveryRadiusMiles:
                transport.deliveryRadiusMiles?.toString() ?? '10',
          );
          if (transport.handoffWindows.isNotEmpty &&
              draft.handoffSchedule.weeklyWindows.isEmpty) {
            draft.handoffSchedule = draft.handoffSchedule.copyWith(
              weeklyWindows: transport.handoffWindows,
            );
          }
        }
      },
      (_) {},
      productId,
    );

    await syncCategoryLabelsFromIds();
    if (_initialRemoteImageIds.isEmpty && draft.photos.isNotEmpty) {
      _captureInitialRemoteOrder();
    }
  }

  void _captureInitialRemoteOrder() {
    _initialRemoteImageIds = draft.photos
        .where(
          (p) =>
              p.kind == ListingPhotoKind.remote && p.remoteId != null,
        )
        .map((p) => p.remoteId!)
        .toList();
  }

  /// `getProductById` often returns product fields in [rows[0]] and images in [rows[1]].
  List<Images> _productImageEntriesFromRows(List<Data> rows) {
    if (rows.length >= 2 &&
        rows[1].images != null &&
        rows[1].images!.isNotEmpty) {
      return rows[1].images!;
    }
    if (rows[0].images != null && rows[0].images!.isNotEmpty) {
      return rows[0].images!;
    }
    return const [];
  }

  void _applyProductRow(Map<String, dynamic> row) {
    final blocked = row['blocked_dates'];
    List<String> blockedList = [];
    if (blocked is String && blocked.isNotEmpty) {
      try {
        blockedList = (jsonDecode(blocked) as List).map((e) => e.toString()).toList();
      } catch (_) {}
    } else if (blocked is List) {
      blockedList = blocked.map((e) => e.toString()).toList();
    }

    draft.availability = draft.availability.copyWith(blockedDates: blockedList);
    draft.rentalRules = RentalRules(
      advanceNoticeHours:
          int.tryParse('${row['advance_notice_hours']}') ?? 24,
      turnaroundHours: int.tryParse('${row['turnaround_hours']}') ?? 0,
      minRentalDays: int.tryParse('${row['min_rental_days']}'),
      maxRentalDays: int.tryParse('${row['max_rental_days']}'),
    );
    if (row['condition_rating'] != null) {
      draft.conditionRating = row['condition_rating'].toString();
    }
    draft.location = ListingLocation(
      line1: row['address_line1']?.toString() ??
          row['address']?.toString() ??
          draft.location.line1,
      line2: row['address_line2']?.toString() ?? '',
      city: row['address_city']?.toString() ?? '',
      state: row['address_state']?.toString() ?? '',
      postalCode: row['address_postal_code']?.toString() ?? '',
      latitude: double.tryParse(
            row['latitude']?.toString() ?? '',
          ) ??
          draft.location.latitude,
      longitude: double.tryParse(
            row['longitude']?.toString() ?? '',
          ) ??
          draft.location.longitude,
    );

    final scheduleRaw = row['handoff_schedule'];
    if (scheduleRaw != null) {
      Map<String, dynamic>? scheduleMap;
      if (scheduleRaw is Map) {
        scheduleMap = Map<String, dynamic>.from(scheduleRaw);
      } else if (scheduleRaw is String && scheduleRaw.isNotEmpty) {
        try {
          scheduleMap = Map<String, dynamic>.from(jsonDecode(scheduleRaw));
        } catch (_) {}
      }
      if (scheduleMap != null) {
        draft.handoffSchedule = HandoffSchedule.fromJson(scheduleMap);
      }
    }

    final imagePaths = row['images'];
    if (imagePaths is List && draft.photos.isEmpty) {
      draft.photos = imagePaths
          .map((path) => ListingPhotoRef(
                kind: ListingPhotoKind.remote,
                path: path.toString(),
                isCover: false,
              ))
          .toList();
      draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);
    }
  }

  void markDirty() {
    draft.isDirty = true;
    update();
  }

  Future<void> persistDraft() async {
    if (isEditMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_legacyActiveKey, true);
    await prefs.setString(_blobKey, draft.encode());
    await prefs.setString('listing_draft_product', draft.name.trim());
    await prefs.setString('listing_draft_rent', draft.pricePerDay.trim());
    draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);
    final imagePaths = draft.photos
        .where((p) => p.kind == ListingPhotoKind.local)
        .map((p) => p.path)
        .toList();
    await prefs.setStringList('listing_draft_images', imagePaths);
  }

  Future<void> _loadDraftBlob() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_blobKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        draft = ListingDraft.decode(raw);
        draft.userId = draft.userId.isNotEmpty ? draft.userId : '';
        draft.photos = ListingDraftPhotos.pruneMissingLocalPhotos(draft.photos);
        draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);
      } catch (_) {}
    }
    await syncCategoryLabelsFromIds();
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_blobKey);
    await prefs.setBool(_legacyActiveKey, false);
    await prefs.remove('listing_draft_product');
    await prefs.remove('listing_draft_rent');
    await prefs.remove('listing_draft_images');
  }

  String? validateStep(int step) {
    switch (step) {
      case 1:
        if (draft.photos.length < ListingDraft.minPhotos) {
          return 'Add at least ${ListingDraft.minPhotos} photos.';
        }
        if (draft.name.trim().isEmpty) return 'Enter an item name.';
        return null;
      case 2:
        if (draft.categoryId.isEmpty) return 'Choose a category.';
        if (draft.subcategoryId.isEmpty) return 'Choose a subcategory.';
        return null;
      case 3:
        final price = int.tryParse(draft.pricePerDay.trim());
        if (price == null || price < 0) return 'Enter a valid price per day.';
        final dep = int.tryParse(draft.securityDeposit.trim());
        if (dep == null || dep < 0) return 'Enter a valid security deposit.';
        return null;
      case 4:
        if (!draft.location.isComplete) {
          return 'Set a pickup location for this listing.';
        }
        if (draft.handoffSchedule.weeklyWindows.isEmpty) {
          return 'Add at least one pickup & return time window.';
        }
        if (!draft.delivery.offersPickup && !draft.delivery.offersDelivery) {
          return 'Enable pickup or delivery.';
        }
        if (draft.delivery.offersDelivery) {
          final r = int.tryParse(draft.delivery.deliveryRadiusMiles.trim());
          if (r == null || r <= 0) return 'Enter a delivery radius.';
        }
        return null;
      case 5:
        return null;
      default:
        return null;
    }
  }

  Future<String?> publishBlockedMessage() async {
    return ensureOnboardingController().publishListingBlockedMessage(
      forUserId: draft.userId,
    );
  }

  Future<bool> submit({required bool publish}) async {
    if (publish) {
      isSubmitting = true;
    } else {
      isSavingDraft = true;
    }
    update();
    var success = false;
    try {
      final fields = draft.toApiFields(publish: publish);
      if (isEditMode && draft.productId != null) {
        fields['id'] = draft.productId;
        fields['product_id'] = draft.productId;
        fields['user_id1'] = draft.userId;
        final ok = await ApiRepository.shared.updateListingJson(fields);
        if (ok) {
          await _syncImagesOnEdit();
          await clearDraft();
        }
        success = ok;
        return ok;
      }

      draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);
      final formData = dio.FormData.fromMap(fields);
      final files = <dio.MultipartFile>[];
      for (final photo in draft.photos) {
        if (photo.kind != ListingPhotoKind.local) continue;
        files.add(await dio.MultipartFile.fromFile(
          photo.path,
          filename: productUploadFilename(photo.path),
        ));
      }
      if (files.isNotEmpty) {
        formData.files.addAll(files.map((f) => MapEntry('file', f)));
      }

      final response = await ApiRepository.shared.insertProductMultipart(formData);
      final ok = response.statusCode == 200;
      if (ok) {
        final data = response.data;
        if (data is Map && data['product_id'] != null) {
          draft.productId = data['product_id'].toString();
        }
        lastPublishedProductId = draft.productId;
        await clearDraft();
      }
      success = ok;
      return ok;
    } finally {
      if (!success) {
        if (publish) {
          isSubmitting = false;
        } else {
          isSavingDraft = false;
        }
        update();
      }
    }
  }

  Future<void> _syncImagesOnEdit() async {
    final productId = draft.productId;
    if (productId == null) return;

    draft.photos = ListingDraftPhotos.normalizeCoverFirst(draft.photos);

    if (_needsFullGalleryResync()) {
      await _resyncEntireGallery(productId);
      return;
    }

    final files = <dio.MultipartFile>[];
    final insertAt = <int?>[];
    for (var i = 0; i < draft.photos.length; i++) {
      final photo = draft.photos[i];
      if (photo.kind != ListingPhotoKind.local) continue;
      insertAt.add(i);
      files.add(await dio.MultipartFile.fromFile(
        photo.path,
        filename: productUploadFilename(photo.path),
      ));
    }
    if (files.isEmpty) return;
    await ApiRepository.shared.uploadProductImages(
      productId: productId,
      files: files,
      insertAt: insertAt,
    );
  }

  List<int> _remoteIdsInDraftOrder() {
    return draft.photos
        .where(
          (p) => p.kind == ListingPhotoKind.remote && p.remoteId != null,
        )
        .map((p) => p.remoteId!)
        .toList();
  }

  /// True when gallery order/cover changed among existing server photos.
  bool _needsFullGalleryResync() {
    if (_initialRemoteImageIds.isEmpty) return false;

    final remoteIds = _remoteIdsInDraftOrder();
    if (remoteIds.isNotEmpty &&
        !listEquals(remoteIds, _initialRemoteImageIds)) {
      return true;
    }

    // New local photo set as cover before existing remotes.
    if (draft.photos.isNotEmpty &&
        draft.photos.first.kind == ListingPhotoKind.local) {
      return true;
    }

    return false;
  }

  /// Re-uploads the full desired gallery (append), then removes prior server rows.
  /// Avoids insert-at-0 replacing the previous primary image when cover changes.
  Future<void> _resyncEntireGallery(String productId) async {
    if (draft.photos.isEmpty) return;

    final tempDownloads = <File>[];
    try {
      for (final photo in draft.photos) {
        dio.MultipartFile part;
        if (photo.kind == ListingPhotoKind.local) {
          part = await dio.MultipartFile.fromFile(
            photo.path,
            filename: productUploadFilename(photo.path),
          );
        } else {
          final file = await _downloadRemoteListingPhoto(photo.path);
          if (file == null) return;
          tempDownloads.add(file);
          part = await dio.MultipartFile.fromFile(
            file.path,
            filename: productUploadFilename(file.path),
          );
        }

        final ok = await ApiRepository.shared.uploadProductImages(
          productId: productId,
          files: [part],
          append: true,
        );
        if (!ok) return;
      }

      for (final id in _initialRemoteImageIds) {
        await ApiRepository.shared.deleteProductImageSilently(
          id.toString(),
          productId: productId,
        );
      }
    } finally {
      for (final file in tempDownloads) {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<File?> _downloadRemoteListingPhoto(String path) async {
    final url = ProfileImage.resolveUrl(AppUrl.baseUrlM, path);
    if (url == null) return null;
    try {
      final tempDir = Directory.systemTemp;
      final ext = p.extension(path);
      final safeExt = ext.isNotEmpty ? ext : '.jpg';
      final out = File(
        p.join(
          tempDir.path,
          'listing_cover_${DateTime.now().millisecondsSinceEpoch}$safeExt',
        ),
      );
      await dio.Dio().download(url, out.path);
      if (!await out.exists()) return null;
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (draft.photos.length >= ListingDraft.maxPhotos) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final file = File(picked.path);
    final size = await file.length();
    if (size > 7 * 1024 * 1024) return;
    final stablePath = await ListingDraftPhotos.persistPickedFile(picked.path);
    final isFirst = draft.photos.isEmpty;
    draft.photos = ListingDraftPhotos.normalizeCoverFirst([
      ...draft.photos,
      ListingPhotoRef(
        kind: ListingPhotoKind.local,
        path: stablePath,
        isCover: isFirst,
      ),
    ]);
    markDirty();
    await persistDraft();
  }

  void setCover(int index) {
    if (index < 0 || index >= draft.photos.length) return;
    draft.photos = ListingDraftPhotos.normalizeCoverFirst([
      for (var i = 0; i < draft.photos.length; i++)
        draft.photos[i].copyWith(isCover: i == index),
    ]);
    markDirty();
  }

  void removePhoto(int index) {
    if (index < 0 || index >= draft.photos.length) return;
    final removed = draft.photos[index];
    if (removed.kind == ListingPhotoKind.local) {
      ListingDraftPhotos.deleteManagedFile(removed.path);
    }
    final list = [...draft.photos]..removeAt(index);
    if (list.isNotEmpty && !list.any((p) => p.isCover)) {
      list[0] = list[0].copyWith(isCover: true);
    }
    draft.photos = ListingDraftPhotos.normalizeCoverFirst(list);
    markDirty();
  }

  Future<void> replacePhoto(int index, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    if (index < 0 || index >= draft.photos.length) return;
    final previous = draft.photos[index];
    final stablePath = await ListingDraftPhotos.persistPickedFile(picked.path);
    if (previous.kind == ListingPhotoKind.local) {
      await ListingDraftPhotos.deleteManagedFile(previous.path);
    }
    final cover = previous.isCover;
    final list = [...draft.photos];
    list[index] = ListingPhotoRef(
      kind: ListingPhotoKind.local,
      path: stablePath,
      isCover: cover,
    );
    draft.photos = ListingDraftPhotos.normalizeCoverFirst(list);
    markDirty();
  }
}
