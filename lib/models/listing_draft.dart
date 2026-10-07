import 'dart:convert';

import 'package:jebby/models/handoff_window.dart';
import 'package:jebby/utils/google_places_address.dart';

enum ListingPhotoKind { local, remote }

class ListingPhotoRef {
  final ListingPhotoKind kind;
  final String path;
  final bool isCover;
  /// Server `product_images.id` when loaded from the API (edit mode).
  final int? remoteId;

  const ListingPhotoRef({
    required this.kind,
    required this.path,
    this.isCover = false,
    this.remoteId,
  });

  ListingPhotoRef copyWith({bool? isCover, int? remoteId}) => ListingPhotoRef(
        kind: kind,
        path: path,
        isCover: isCover ?? this.isCover,
        remoteId: remoteId ?? this.remoteId,
      );

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'path': path,
        'isCover': isCover,
        if (remoteId != null) 'remoteId': remoteId,
      };

  factory ListingPhotoRef.fromJson(Map<String, dynamic> json) {
    return ListingPhotoRef(
      kind: json['kind'] == 'remote'
          ? ListingPhotoKind.remote
          : ListingPhotoKind.local,
      path: json['path']?.toString() ?? '',
      isCover: json['isCover'] == true,
      remoteId: json['remoteId'] is int
          ? json['remoteId'] as int
          : int.tryParse('${json['remoteId']}'),
    );
  }
}

class ListingLocation {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final double? latitude;
  final double? longitude;

  const ListingLocation({
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.latitude,
    this.longitude,
  });

  bool get isComplete =>
      line1.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty &&
      latitude != null &&
      longitude != null;

  String get publicCityState {
    final c = city.trim();
    final s = state.trim().toUpperCase();
    if (c.isEmpty && s.isEmpty) return '';
    if (c.isEmpty) return s;
    if (s.isEmpty) return c;
    return '$c, $s';
  }

  String get fullAddress {
    final parts = [
      line1.trim(),
      if (line2.trim().isNotEmpty) line2.trim(),
      city.trim(),
      '${state.trim().toUpperCase()} ${postalCode.trim()}'.trim(),
    ].where((p) => p.isNotEmpty);
    return parts.join(', ');
  }

  ParsedUsAddress toParsedAddress() => ParsedUsAddress(
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        postalCode: postalCode,
        formattedAddress: fullAddress,
        latitude: latitude,
        longitude: longitude,
      );

  factory ListingLocation.fromParsed(ParsedUsAddress address) => ListingLocation(
        line1: address.line1,
        line2: address.line2,
        city: address.city,
        state: address.state,
        postalCode: address.postalCode,
        latitude: address.latitude,
        longitude: address.longitude,
      );

  Map<String, dynamic> toJson() => {
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory ListingLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ListingLocation();
    return ListingLocation(
      line1: json['line1']?.toString() ?? '',
      line2: json['line2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  ListingLocation copyWith({
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) =>
      ListingLocation(
        line1: line1 ?? this.line1,
        line2: line2 ?? this.line2,
        city: city ?? this.city,
        state: state ?? this.state,
        postalCode: postalCode ?? this.postalCode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}

class ListingAvailability {
  final List<String> blockedDates;

  const ListingAvailability({this.blockedDates = const []});

  Map<String, dynamic> toJson() => {
        'blockedDates': blockedDates,
      };

  factory ListingAvailability.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ListingAvailability();
    return ListingAvailability(
      blockedDates: (json['blockedDates'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  ListingAvailability copyWith({List<String>? blockedDates}) =>
      ListingAvailability(
        blockedDates: blockedDates ?? this.blockedDates,
      );
}

class RentalRules {
  final int advanceNoticeHours;
  final int turnaroundHours;
  final int? minRentalDays;
  final int? maxRentalDays;

  const RentalRules({
    this.advanceNoticeHours = 24,
    this.turnaroundHours = 0,
    this.minRentalDays,
    this.maxRentalDays,
  });

  Map<String, dynamic> toJson() => {
        'advanceNoticeHours': advanceNoticeHours,
        'turnaroundHours': turnaroundHours,
        'minRentalDays': minRentalDays,
        'maxRentalDays': maxRentalDays,
      };

  factory RentalRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RentalRules();
    return RentalRules(
      advanceNoticeHours: json['advanceNoticeHours'] is int
          ? json['advanceNoticeHours'] as int
          : int.tryParse('${json['advanceNoticeHours']}') ?? 24,
      turnaroundHours: json['turnaroundHours'] is int
          ? json['turnaroundHours'] as int
          : int.tryParse('${json['turnaroundHours']}') ?? 0,
      minRentalDays: json['minRentalDays'] == null
          ? null
          : int.tryParse('${json['minRentalDays']}'),
      maxRentalDays: json['maxRentalDays'] == null
          ? null
          : int.tryParse('${json['maxRentalDays']}'),
    );
  }

  RentalRules copyWith({
    int? advanceNoticeHours,
    int? turnaroundHours,
    int? minRentalDays,
    int? maxRentalDays,
  }) =>
      RentalRules(
        advanceNoticeHours: advanceNoticeHours ?? this.advanceNoticeHours,
        turnaroundHours: turnaroundHours ?? this.turnaroundHours,
        minRentalDays: minRentalDays ?? this.minRentalDays,
        maxRentalDays: maxRentalDays ?? this.maxRentalDays,
      );
}

class HandoffSchedule {
  final Set<int> weekdays;
  final List<HandoffWindow> weeklyWindows;
  final Map<int, List<HandoffWindow>> perDayOverrides;
  final Map<int, bool> useWeeklyByDay;

  const HandoffSchedule({
    this.weekdays = const {0, 1, 2, 3, 4, 5, 6},
    this.weeklyWindows = const [],
    this.perDayOverrides = const {},
    this.useWeeklyByDay = const {},
  });

  Map<String, dynamic> toApiJson() => {
        'weekdays': weekdays.toList()..sort(),
        'weekly_windows': weeklyWindows.map((w) => w.toJson()).toList(),
        'per_day_overrides': perDayOverrides.map(
          (k, v) => MapEntry(k.toString(), v.map((w) => w.toJson()).toList()),
        ),
        'use_weekly_by_day': useWeeklyByDay.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      };

  List<HandoffWindow> windowsForDay(int weekday) {
    if (useWeeklyByDay[weekday] != false && weeklyWindows.isNotEmpty) {
      return weeklyWindows;
    }
    return perDayOverrides[weekday] ?? weeklyWindows;
  }

  Map<String, dynamic> toJson() => {
        'weekdays': weekdays.toList(),
        'weeklyWindows': weeklyWindows.map((w) => w.toJson()).toList(),
        'perDayOverrides': perDayOverrides.map(
          (k, v) => MapEntry(k.toString(), v.map((w) => w.toJson()).toList()),
        ),
        'useWeeklyByDay': useWeeklyByDay.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      };

  factory HandoffSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HandoffSchedule(weeklyWindows: HandoffWindow.defaultSlots);
    }
    Set<int> days = {0, 1, 2, 3, 4, 5, 6};
    if (json['weekdays'] is List) {
      days = (json['weekdays'] as List)
          .map((e) => int.tryParse('$e'))
          .whereType<int>()
          .where((d) => d >= 0 && d <= 6)
          .toSet();
      if (days.isEmpty) days = {0, 1, 2, 3, 4, 5, 6};
    }
    List<HandoffWindow> parseWindows(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((m) => HandoffWindow.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    final weekly = parseWindows(json['weekly_windows'] ?? json['weeklyWindows']);
    final overridesRaw = json['per_day_overrides'] ?? json['perDayOverrides'];
    final overrides = <int, List<HandoffWindow>>{};
    if (overridesRaw is Map) {
      overridesRaw.forEach((key, value) {
        final day = int.tryParse('$key');
        if (day != null) overrides[day] = parseWindows(value);
      });
    }
    final useWeeklyRaw = json['use_weekly_by_day'] ?? json['useWeeklyByDay'];
    final useWeekly = <int, bool>{};
    if (useWeeklyRaw is Map) {
      useWeeklyRaw.forEach((key, value) {
        final day = int.tryParse('$key');
        if (day != null) useWeekly[day] = value == true;
      });
    }

    final resolvedWeekly =
        weekly.isNotEmpty ? weekly : HandoffWindow.defaultSlots;
    String windowSignature(List<HandoffWindow> windows) => windows
        .map((w) => '${w.startTime}_${w.endTime}')
        .join(';');
    final weeklySignature = windowSignature(resolvedWeekly);
    for (final entry in overrides.entries) {
      final day = entry.key;
      if (entry.value.isEmpty) continue;
      if (useWeekly.containsKey(day)) continue;
      if (windowSignature(entry.value) != weeklySignature) {
        useWeekly[day] = false;
      }
    }

    return HandoffSchedule(
      weekdays: days,
      weeklyWindows: resolvedWeekly,
      perDayOverrides: overrides,
      useWeeklyByDay: useWeekly,
    );
  }

  HandoffSchedule copyWith({
    Set<int>? weekdays,
    List<HandoffWindow>? weeklyWindows,
    Map<int, List<HandoffWindow>>? perDayOverrides,
    Map<int, bool>? useWeeklyByDay,
  }) =>
      HandoffSchedule(
        weekdays: weekdays ?? this.weekdays,
        weeklyWindows: weeklyWindows ?? this.weeklyWindows,
        perDayOverrides: perDayOverrides ?? this.perDayOverrides,
        useWeeklyByDay: useWeeklyByDay ?? this.useWeeklyByDay,
      );
}

class DeliveryOptions {
  final bool offersPickup;
  final bool offersDelivery;
  final String deliveryFee;
  final String deliveryRadiusMiles;

  const DeliveryOptions({
    this.offersPickup = true,
    this.offersDelivery = false,
    this.deliveryFee = '0',
    this.deliveryRadiusMiles = '10',
  });

  Map<String, dynamic> toJson() => {
        'offersPickup': offersPickup,
        'offersDelivery': offersDelivery,
        'deliveryFee': deliveryFee,
        'deliveryRadiusMiles': deliveryRadiusMiles,
      };

  factory DeliveryOptions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryOptions();
    return DeliveryOptions(
      offersPickup: json['offersPickup'] != false,
      offersDelivery: json['offersDelivery'] == true,
      deliveryFee: json['deliveryFee']?.toString() ?? '0',
      deliveryRadiusMiles:
          json['deliveryRadiusMiles']?.toString() ?? '10',
    );
  }

  DeliveryOptions copyWith({
    bool? offersPickup,
    bool? offersDelivery,
    String? deliveryFee,
    String? deliveryRadiusMiles,
  }) =>
      DeliveryOptions(
        offersPickup: offersPickup ?? this.offersPickup,
        offersDelivery: offersDelivery ?? this.offersDelivery,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        deliveryRadiusMiles: deliveryRadiusMiles ?? this.deliveryRadiusMiles,
      );
}

class ListingDraft {
  static const int minPhotos = 2;
  static const int maxPhotos = 5;

  String? productId;
  String userId;
  String name;
  String description;
  List<ListingPhotoRef> photos;
  String categoryId;
  String categoryName;
  String subcategoryId;
  String subcategoryName;
  String conditionRating;
  String pricePerDay;
  String securityDeposit;
  ListingLocation location;
  ListingAvailability availability;
  RentalRules rentalRules;
  HandoffSchedule handoffSchedule;
  DeliveryOptions delivery;
  int currentStep;
  bool isDirty;

  ListingDraft({
    this.productId,
    this.userId = '',
    this.name = '',
    this.description = '',
    this.photos = const [],
    this.categoryId = '',
    this.categoryName = '',
    this.subcategoryId = '',
    this.subcategoryName = '',
    this.conditionRating = 'good',
    this.pricePerDay = '',
    this.securityDeposit = '0',
    ListingLocation? location,
    ListingAvailability? availability,
    RentalRules? rentalRules,
    HandoffSchedule? handoffSchedule,
    DeliveryOptions? delivery,
    this.currentStep = 1,
    this.isDirty = false,
  })  : location = location ?? const ListingLocation(),
        availability = availability ?? ListingAvailability.fromJson(null),
        rentalRules = rentalRules ?? const RentalRules(),
        handoffSchedule =
            handoffSchedule ?? HandoffSchedule(weeklyWindows: HandoffWindow.defaultSlots),
        delivery = delivery ?? const DeliveryOptions();

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'userId': userId,
        'name': name,
        'description': description,
        'photos': photos.map((p) => p.toJson()).toList(),
        'categoryId': categoryId,
        'categoryName': categoryName,
        'subcategoryId': subcategoryId,
        'subcategoryName': subcategoryName,
        'conditionRating': conditionRating,
        'pricePerDay': pricePerDay,
        'securityDeposit': securityDeposit,
        'location': location.toJson(),
        'availability': availability.toJson(),
        'rentalRules': rentalRules.toJson(),
        'handoffSchedule': handoffSchedule.toJson(),
        'delivery': delivery.toJson(),
        'currentStep': currentStep,
      };

  factory ListingDraft.fromJson(Map<String, dynamic> json) {
    return ListingDraft(
      productId: json['productId']?.toString(),
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photos: (json['photos'] as List?)
              ?.map((e) => ListingPhotoRef.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList() ??
          const [],
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subcategoryId: json['subcategoryId']?.toString() ?? '',
      subcategoryName: json['subcategoryName']?.toString() ?? '',
      conditionRating: json['conditionRating']?.toString() ?? 'good',
      pricePerDay: json['pricePerDay']?.toString() ?? '',
      securityDeposit: json['securityDeposit']?.toString() ?? '0',
      location: ListingLocation.fromJson(
        json['location'] is Map
            ? Map<String, dynamic>.from(json['location'] as Map)
            : null,
      ),
      availability: ListingAvailability.fromJson(
        json['availability'] is Map
            ? Map<String, dynamic>.from(json['availability'] as Map)
            : null,
      ),
      rentalRules: RentalRules.fromJson(
        json['rentalRules'] is Map
            ? Map<String, dynamic>.from(json['rentalRules'] as Map)
            : null,
      ),
      handoffSchedule: HandoffSchedule.fromJson(
        json['handoffSchedule'] is Map
            ? Map<String, dynamic>.from(json['handoffSchedule'] as Map)
            : null,
      ),
      delivery: DeliveryOptions.fromJson(
        json['delivery'] is Map
            ? Map<String, dynamic>.from(json['delivery'] as Map)
            : null,
      ),
      currentStep: json['currentStep'] is int
          ? json['currentStep'] as int
          : int.tryParse('${json['currentStep']}') ?? 1,
    );
  }

  String encode() => jsonEncode(toJson());

  static ListingDraft decode(String raw) =>
      ListingDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  Map<String, dynamic> toApiFields({required bool publish}) {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'name': name,
      'description': description.isNotEmpty ? description : name,
      'price': pricePerDay,
      'security_deposit': securityDeposit,
      'condition_rating': conditionRating,
      'blocked_dates': jsonEncode(availability.blockedDates),
      'advance_notice_hours': rentalRules.advanceNoticeHours,
      'turnaround_hours': rentalRules.turnaroundHours,
      if (rentalRules.minRentalDays != null)
        'min_rental_days': rentalRules.minRentalDays,
      if (rentalRules.maxRentalDays != null)
        'max_rental_days': rentalRules.maxRentalDays,
      'address': location.fullAddress,
      'address_line1': location.line1,
      'address_line2': location.line2,
      'address_city': location.city,
      'address_state': location.state,
      'address_postal_code': location.postalCode,
      'latitude': location.latitude?.toString() ?? '',
      'longitude': location.longitude?.toString() ?? '',
      'offers_pickup': delivery.offersPickup ? 1 : 0,
      'offers_delivery': delivery.offersDelivery ? 1 : 0,
      'delivery_charges': delivery.deliveryFee,
      'delivery_radius_miles': delivery.deliveryRadiusMiles,
      'handoff_schedule': jsonEncode(handoffSchedule.toApiJson()),
      'listing_status': publish ? 'published' : 'draft',
      'publish_state': publish ? 'published' : 'draft',
      if (!publish) 'bookable': 0,
    };
  }
}
