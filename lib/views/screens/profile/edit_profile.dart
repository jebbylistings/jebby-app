import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/views/widgets/address_autocomplete_field.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:jebby/utils/show_snackbar.dart';

import 'package:jebby/constants/color.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/models/user_model.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/overlay_support.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../../view_models/user_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const double _coverPreviewHeight = 96;
  static const double _profileAvatarRadius = 46;
  /// Cover height plus how far the avatar hangs below the cover bottom.
  static const double _profilePhotoOverlap = 40;
  static double get _publicPhotoStackHeight =>
      _coverPreviewHeight + _profilePhotoOverlap;

  static const double _spaceLabelToField = 6;
  static const double _spaceFieldToHelper = 6;

  File? _image;
  File? _image1;
  bool _editingAddress = false;

  final picker = ImagePicker();

  Future getGalleryImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        _showAlert(
          'Selected file is larger than 5MB. Please select a smaller file.',
        );
      } else {
        setState(() {
          _image = file;
        });
      }
    } else {
      log("No image picked");
    }
  }

  Future<void> getGalleryImage1() async {
    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted) return;

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          _showAlert(
            'Selected file is larger than 5MB. Please select a smaller file.',
          );
        } else {
          setState(() {
            _image1 = file;
          });
        }
      }
    } catch (e) {
      log('Profile photo pick failed: $e');
      if (!mounted) return;
      showAppErrorSnackbar(
        'Could not open your photo library. Check app permissions and try again.',
      );
    }
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  String dropdownValue = "standard";
  List<String> items = ["standard", "custom", "express"];

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }


  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'File Size Exceeded',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishProfileSave() async {
    if (id != null && id!.isNotEmpty && mounted) {
      final row = await ApiRepository.shared.fetchUserProfileRow(id!);
      if (row != null) {
        await context.read<UserViewModel>().syncProfileFromRow(row);
      }
    }
    if (!mounted) return;
    Get.back(result: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAppSuccessSnackbar('Profile updated successfully.');
    });
  }


  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          log("message from Edir profile" + id.toString());
          getProductsApi(id);
          fullname = value.name.toString();
          _nameController.text = fullname.toString();
          email = value.email.toString();
          role = value.role.toString();
          getUserData();
          log("From Edit PAge Log Test" + fullname.toString());
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  var _locationController = TextEditingController();
  ParsedUsAddress? _resolvedAddress;
  var Latitiude;
  var Longitude;
  var uuid = new Uuid();
  var vuid = new Uuid();
  var selected = "standard";

  void _clearResolvedAddress() {
    setState(() {
      _resolvedAddress = const ParsedUsAddress();
    });
  }

  String? _locationValidationError() {
    if (_locationController.text.trim().isEmpty) {
      return 'Please enter current location';
    }
    if (_resolvedAddress?.hasResolvedMapLocation != true) {
      return ParsedUsAddress.selectFromSuggestionsMessage;
    }
    return null;
  }

  Future<void> _applySelectedAddress(ParsedUsAddress address) async {
    setState(() {
      _resolvedAddress = address;
      _locationController.text = address.displayLine;
      if (address.hasCoordinates) {
        Latitiude = address.latitude!.toString();
        Longitude = address.longitude!.toString();
      } else {
        Latitiude = null;
        Longitude = null;
      }
    });
  }

  InputDecoration get _profileAddressDecoration => InputDecoration(
        hintText: 'Search for your address',
        hintStyle: _nunito(size: 15, weight: FontWeight.w600, color: AppColors.jebbyTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
        ),
      );

  TextStyle _nunito({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.jebbyTextPrimary,
      height: height,
    );
  }

  String _publicLocationLine() {
    final addr = _resolvedAddress;
    if (addr != null) {
      final city = addr.city.trim();
      final state = addr.state.trim();
      if (city.isNotEmpty && state.isNotEmpty) {
        return '$city, ${state.toUpperCase()}';
      }
    }
    final saved = _locationController.text.trim();
    if (saved.isEmpty) return 'Not set';
    return PublicLocation.cityStateLine(saved) ?? 'Not set';
  }

  String _savedAddressDisplay() {
    final text = _locationController.text.trim();
    if (text.isEmpty) return 'No address saved';
    return text;
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.jebbySoftBlue,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Get.back(),
            splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
            highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.jebbyTextPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit profile',
                  style: _nunito(size: 24, weight: FontWeight.w800, height: 1.1),
                ),
                const SizedBox(height: 6),
                Text(
                  'Update your photos, name, and default listing address.',
                  style: _helperTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: _nunito(size: 17, weight: FontWeight.w800));
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: _nunito(
        size: 14,
        weight: FontWeight.w700,
        color: AppColors.jebbyTextMuted,
      ),
    );
  }

  TextStyle get _helperTextStyle => _nunito(
        size: 13,
        weight: FontWeight.w600,
        color: AppColors.jebbyTextMuted,
        height: 1.35,
      );

  Widget _photoCameraButton({
    required VoidCallback onTap,
    double size = 36,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.18),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.photo_camera_outlined,
            size: size * 0.48,
            color: AppColors.jebbyBlue,
          ),
        ),
      ),
    );
  }

  Widget _profilePhotoWithCamera() {
    return Center(
      child: SizedBox(
        width: (_profileAvatarRadius + 3) * 2 + 8,
        height: (_profileAvatarRadius + 3) * 2 + 8,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: getGalleryImage1,
              child: _profileAvatar(),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: _photoCameraButton(
                onTap: getGalleryImage1,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar({double radius = _profileAvatarRadius}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.jebbySoftBlue, AppColors.jebbyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _image1 != null
          ? CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              backgroundImage: FileImage(_image1!),
            )
          : ProfileImage.circularAvatar(
              radius: radius,
              baseUrl: AppUrl.baseUrlM,
              imagePath: imagesapi,
            ),
    );
  }

  Widget _publicPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _publicPhotoStackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _coverPreviewHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _coverPreview(),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _photoCameraButton(onTap: getGalleryImage),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _profilePhotoWithCamera(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cover photo',
                    style: _nunito(size: 14, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shown at the top of your earner profile.',
                    style: _helperTextStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Profile photo',
                    style: _nunito(size: 14, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Renters see this on your profile and listings.',
                    textAlign: TextAlign.center,
                    style: _helperTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _coverPreview() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }
    if (ProfileImage.isValidPath(back_image_api)) {
      return Image.network(
        ProfileImage.resolveUrl(AppUrl.baseUrlM, back_image_api)!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _coverPlaceholder(),
      );
    }
    return _coverPlaceholder();
  }

  Widget _coverPlaceholder() {
    return Container(
      color: AppColors.earnerBannerBlue,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 28,
        color: AppColors.jebbyBlue.withValues(alpha: 0.55),
      ),
    );
  }

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Name'),
        SizedBox(height: _spaceLabelToField),
        TextField(
          controller: _nameController,
          style: _nunito(size: 16, weight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
            ),
          ),
        ),
        SizedBox(height: _spaceFieldToHelper),
        Text(
          'Public location: ${_publicLocationLine()}',
          style: _helperTextStyle,
        ),
      ],
    );
  }

  Widget _privateDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, size: 17, color: AppColors.jebbyTextMuted),
            const SizedBox(width: 8),
            Text('Private details', style: _nunito(size: 17, weight: FontWeight.w800)),
          ],
        ),
        SizedBox(height: _spaceLabelToField),
        Text(
          'Your email and street address aren\'t shown on your profile.',
          style: _helperTextStyle,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.jebbySoftBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.jebbyBlue.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _privateDetailRow(
                  label: 'Email',
                  value: _emailController.text.trim().isEmpty
                      ? 'No email saved'
                      : _emailController.text.trim(),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.jebbyBlue.withValues(alpha: 0.14),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Saved address'),
                        SizedBox(height: _spaceLabelToField),
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Text(
                            _savedAddressDisplay(),
                            style: _nunito(
                              size: 16,
                              weight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _editIconButton(
                        onTap: () =>
                            setState(() => _editingAddress = !_editingAddress),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_editingAddress) ...[
          SizedBox(height: _spaceLabelToField),
          AddressAutocompleteField(
            controller: _locationController,
            resolvedAddress: _resolvedAddress,
            onEditingStarted: _clearResolvedAddress,
            onAddressSelected: _applySelectedAddress,
            hint: 'Search for your address',
            decoration: _profileAddressDecoration,
            enableMapPicker: true,
            mapPickerInitialLatitude:
                double.tryParse(Latitiude?.toString() ?? ''),
            mapPickerInitialLongitude:
                double.tryParse(Longitude?.toString() ?? ''),
          ),
        ],
        SizedBox(height: _spaceFieldToHelper),
        Text(
          'Default for new listings. Existing pickup locations stay the same.',
          style: _helperTextStyle,
        ),
      ],
    );
  }

  Widget _editIconButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.edit_outlined,
            size: 20,
            color: AppColors.jebbyBlue,
          ),
        ),
      ),
    );
  }

  Widget _privateDetailRow({
    required String label,
    required String value,
    bool multiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel(label),
        SizedBox(height: _spaceLabelToField),
        Text(
          value,
          style: _nunito(
            size: 16,
            weight: FontWeight.w700,
            height: multiline ? 1.35 : null,
          ),
        ),
      ],
    );
  }

  void getUserData() {
    ApiRepository.shared.userCredential(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {}
            else
              {
                setState(() {
                  stripeEmailController.text =
                      ApiRepository
                                  .shared
                                  .getUserCredentialModelList!
                                  .data![0]
                                  .stripeEmail
                                  .toString() ==
                              "0"
                          ? ""
                          : ApiRepository
                              .shared
                              .getUserCredentialModelList!
                              .data![0]
                              .stripeEmail
                              .toString();
                  dropdownValue =
                      ApiRepository
                                  .shared
                                  .getUserCredentialModelList!
                                  .data![0]
                                  .stripeAccountType
                                  .toString() ==
                              "0"
                          ? "standard"
                          : ApiRepository
                              .shared
                              .getUserCredentialModelList!
                              .data![0]
                              .stripeAccountType
                              .toString();
                  selected =
                      ApiRepository
                                  .shared
                                  .getUserCredentialModelList!
                                  .data![0]
                                  .stripeAccountType
                                  .toString() ==
                              "0"
                          ? "standard"
                          : ApiRepository
                              .shared
                              .getUserCredentialModelList!
                              .data![0]
                              .stripeAccountType
                              .toString();
                }),
              },
          },
      },
      (error) => {if (error != null) {}},
      id.toString(),
    );
  }

  bool _isSaving = false;

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    log('pressed tap');
    Loader.show();
    if (_nameController.text.isEmpty) {
      Loader.hide();
      showAppErrorSnackbar(
        'Please Enter Name',
        title: 'Required',
      );
      return;
    }
    final locationError = _locationValidationError();
    if (locationError != null) {
      Loader.hide();
      showAppErrorSnackbar(
        locationError,
        title: 'Required',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (!ProfileImage.isValidPath(imagesapi)) {
        if (_image == null) {
          Loader.hide();
          showAppErrorSnackbar(
            'Please Upload Cover Picture',
            title: 'Required',
          );
          return;
        }
        if (_image1 == null) {
          Loader.hide();
          showAppErrorSnackbar(
            'Please Upload Profile Picture',
            title: 'Required',
          );
          return;
        }

        final fileName = Uuid().v4();
        final fileName1 = Uuid().v4();
        final formData = d.FormData.fromMap({
          'name': _nameController.text.toString(),
          'email': _emailController.text.toString(),
          'phone_number': '',
          'address': _locationController.text.toString(),
          'latitude': Latitiude,
          'longitude': Longitude,
          'user_id': id,
          'file': [
            await d.MultipartFile.fromFile(
              _image1!.path,
              filename: fileName1,
            ),
            await d.MultipartFile.fromFile(
              _image!.path,
              filename: fileName,
            ),
          ],
        });
        log(formData.fields.toString());

        final response = await ApiRepository.shared.submitUserProfileMultipart(
          formData,
          isUpdate: false,
        );
        log(response.statusCode.toString());
        Loader.hide();
        await _finishProfileSave();
        return;
      }

      late d.FormData formData;
      if (role == '1') {
        if (stripeEmailController.text.isEmpty) {
          Loader.hide();
          showAppErrorSnackbar(
            'Payment fields cannot be empty',
            title: 'Required',
          );
          return;
        }

        if (_image == null && _image1 != null) {
          final fileName1 = p.basename(_image1!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 1,
            'file': await d.MultipartFile.fromFile(
              _image1!.path,
              filename: fileName1,
            ),
          });
        } else if (_image1 == null && _image != null) {
          final fileName = p.basename(_image!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 2,
            'file': await d.MultipartFile.fromFile(
              _image!.path,
              filename: fileName,
            ),
          });
        } else if (_image1 == null && _image == null) {
          log('both images are null');
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 1,
          });
        } else {
          log('hellooooo22');
          final fileName = p.basename(_image!.path);
          final fileName1 = p.basename(_image1!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 3,
            'file': [
              await d.MultipartFile.fromFile(
                _image1!.path,
                filename: fileName1,
              ),
              await d.MultipartFile.fromFile(
                _image!.path,
                filename: fileName,
              ),
            ],
          });
        }
        log(formData.fields.toString());
      } else {
        if (_image == null && _image1 != null) {
          final fileName1 = p.basename(_image1!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 1,
            'file': await d.MultipartFile.fromFile(
              _image1!.path,
              filename: fileName1,
            ),
          });
        } else if (_image1 == null && _image != null) {
          final fileName = p.basename(_image!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 2,
            'file': await d.MultipartFile.fromFile(
              _image!.path,
              filename: fileName,
            ),
          });
        } else if (_image1 == null && _image == null) {
          log('both images are null');
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 1,
          });
        } else {
          log('hellooooo22');
          final fileName = p.basename(_image!.path);
          final fileName1 = p.basename(_image1!.path);
          formData = d.FormData.fromMap({
            'name': _nameController.text.toString(),
            'email': _emailController.text.toString(),
            'phone_number': '',
            'address': _locationController.text.toString(),
            'latitude': Latitiude,
            'longitude': Longitude,
            'user_id': id,
            'pics': 3,
            'file': [
              await d.MultipartFile.fromFile(
                _image1!.path,
                filename: fileName1,
              ),
              await d.MultipartFile.fromFile(
                _image!.path,
                filename: fileName,
              ),
            ],
          });
        }
        log(formData.fields.toString());
      }

      final response = await ApiRepository.shared.submitUserProfileMultipart(
        formData,
        isUpdate: true,
      );
      log(response.statusCode.toString());
      Loader.hide();
      await _finishProfileSave();
    } catch (e) {
      Loader.hide();
      log('expectation Caught: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  TextEditingController stripeEmailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _pageHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Public profile'),
                    const SizedBox(height: 8),
                    _publicPhotoSection(),
                    const SizedBox(height: 12),
                    _nameField(),
                    const SizedBox(height: 20),
                    _privateDetailsSection(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.jebbyBlue,
                          disabledBackgroundColor:
                              AppColors.jebbyBlue.withValues(alpha: 0.6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save changes',
                                style: _nunito(
                                  size: 17,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  var imagesapi = "";
  var nameapi = "";
  var locationapi = "";
  var emailapi = "";
  var back_image_api = "";

  Future getProductsApi(id) async {
    final row = await ApiRepository.shared.fetchUserProfileRow(id.toString());
    if (row == null) return 'No data';

    log(row.toString());
    if (mounted) {
      setState(() {
        final profileImage = row['profile_image']?.toString().trim() ?? '';
        imagesapi = ProfileImage.sanitizePath(profileImage);
        nameapi = row['name']?.toString() ?? '';
        _nameController.text = row['name']?.toString() ?? '';
        _emailController.text = row['email']?.toString() ?? '';
        _locationController.text = row['address']?.toString() ?? '';
        final coverImage = row['cover_image']?.toString().trim() ?? '';
        back_image_api = ProfileImage.sanitizePath(coverImage);
        Latitiude = row['latitude']?.toString();
        Longitude = row['longitude']?.toString();
        final addressText = row['address']?.toString() ?? '';
        if (addressText.isNotEmpty) {
          _resolvedAddress = ParsedUsAddress(
            formattedAddress: addressText,
            latitude: double.tryParse(Latitiude?.toString() ?? ''),
            longitude: double.tryParse(Longitude?.toString() ?? ''),
          );
        }
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return row;
    setState(() {
      prefs.setString('fullname', row['name']?.toString() ?? '');
      prefs.setString('email', row['email']?.toString() ?? '');
      prefs.setString(
        'profileImage',
        ProfileImage.sanitizePath(row['profile_image']?.toString()),
      );
      prefs.setString('address', row['address']?.toString() ?? '');
      prefs.setString('latitude', row['latitude']?.toString() ?? '');
      prefs.setString('longitude', row['longitude']?.toString() ?? '');
      prefs.setString('phoneNumber', row['phone_number']?.toString() ?? '');
    });
    return {'data': [row]};
  }
}
