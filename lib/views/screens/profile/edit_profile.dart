import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/views/widgets/address_autocomplete_field.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';
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
  static const Color _fieldFill = Color(0xFFF5F7FA);
  static const Color _fieldValueColor = Color(0xFF4B5563);
  static const Color _fieldMutedColor = Color(0xFF9CA3AF);
  static const double _fieldFontSize = 15;
  static const double _coverPreviewHeight = 132;
  static const double _profileAvatarRadius = 44;
  static const double _avatarRingWidth = 3.5;

  static const double _spaceLabelToField = 6;
  static const double _spaceFieldToHelper = 6;
  static const double _profileLocationMaxWidth = 300;

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
            style: _nunito(size: 18, weight: FontWeight.w800),
          ),
          content: Text(
            message,
            style: _nunito(size: 15, weight: FontWeight.w600, height: 1.35),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: _nunito(size: 15, weight: FontWeight.w700),
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

  InputDecoration _filledFieldDecoration({
    String? hintText,
    Widget? suffixIcon,
    bool compact = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: _nunito(
        size: 15,
        weight: FontWeight.w600,
        color: AppColors.jebbyTextMuted,
      ),
      isDense: compact,
      suffixIcon: suffixIcon,
      suffixIconConstraints: BoxConstraints(
        minWidth: compact ? 32 : 40,
        minHeight: compact ? 32 : 40,
      ),
      contentPadding: compact
          ? const EdgeInsets.fromLTRB(16, 12, 4, 12)
          : const EdgeInsets.fromLTRB(16, 13, 8, 13),
      filled: true,
      fillColor: _fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration get _profileAddressDecoration => _filledFieldDecoration(
        hintText: 'Search for your address',
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

  String? _publicLocationForHero() {
    final line = _publicLocationLine();
    if (line == 'Not set') return null;
    return line;
  }

  Widget _heroNameAndPublicLocation() {
    final name = _nameController.text.trim().isEmpty
        ? 'Your name'
        : _nameController.text.trim();
    final location = _publicLocationForHero();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
        ),
        if (location != null && location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.min(
                  _profileLocationMaxWidth,
                  MediaQuery.sizeOf(context).width - 40,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                  children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.jebbyBlue,
                        ),
                      ),
                    ),
                    TextSpan(text: location),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _savedAddressDisplay() {
    final text = _locationController.text.trim();
    if (text.isEmpty) return 'No address saved';
    return text;
  }

  Widget _pageHeader() {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Edit Profile',
          style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
        ),
        const SizedBox(height: 4),
        Text(
          'Update photos and default address.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JebbyFlowBackButton(onTap: () => Get.back()),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: titleBlock,
          ),
        ),
      ],
    );
  }

  Widget _profileCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: _nunito(
        size: 14,
        weight: FontWeight.w700,
        color: AppColors.jebbyTextPrimary,
      ),
    );
  }

  TextStyle _fieldValueTextStyle({bool muted = false, int maxLines = 1}) {
    return _nunito(
      size: _fieldFontSize,
      weight: FontWeight.w500,
      color: muted ? _fieldMutedColor : _fieldValueColor,
      height: maxLines > 1 ? 1.35 : 1.25,
    );
  }

  Widget _readOnlyFieldBox({
    required String value,
    int maxLines = 1,
    bool muted = true,
    bool compact = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final verticalPad = compact
        ? 12.0
        : (maxLines > 1 ? 12.0 : 13.0);
    final box = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        verticalPad,
        trailing != null ? 4 : 16,
        verticalPad,
      ),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: _fieldValueTextStyle(muted: muted, maxLines: maxLines),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );

    if (onTap == null) return box;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: box,
      ),
    );
  }

  TextStyle get _helperTextStyle => _nunito(
        size: 12,
        weight: FontWeight.w600,
        color: _fieldMutedColor,
        height: 1.4,
      );

  TextStyle get _privateSectionSubtitleStyle => _nunito(
        size: 14,
        weight: FontWeight.w600,
        color: AppColors.jebbyTextMuted,
        height: 1.35,
      );

  Widget _coverPhotoCameraButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.photo_camera,
            size: 18,
            color: AppColors.jebbyBlue,
          ),
        ),
      ),
    );
  }

  Widget _profilePhotoCameraButton({required VoidCallback onTap}) {
    return Material(
      color: AppColors.jebbyBlue,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white12,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(
              Icons.photo_camera,
              size: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _pickProfilePhoto() {
    getGalleryImage1();
  }

  Widget _editProfileAvatarRing() {
    final r = _profileAvatarRadius;
    return Container(
      width: (r + _avatarRingWidth) * 2,
      height: (r + _avatarRingWidth) * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.jebbyBlue,
      ),
      padding: const EdgeInsets.all(_avatarRingWidth),
      child: ClipOval(
        child: SizedBox(
          width: r * 2,
          height: r * 2,
          child: _image1 != null
              ? Image.file(_image1!, fit: BoxFit.cover)
              : ProfileImage.circularAvatar(
                  radius: r,
                  baseUrl: AppUrl.baseUrlM,
                  imagePath: imagesapi,
                ),
        ),
      ),
    );
  }

  Widget _profilePhotoWithCamera() {
    final outer = (_profileAvatarRadius + _avatarRingWidth) * 2;
    return SizedBox(
      width: outer + 6,
      height: outer + 6,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickProfilePhoto,
            child: _editProfileAvatarRing(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _profilePhotoCameraButton(onTap: _pickProfilePhoto),
          ),
        ],
      ),
    );
  }

  Widget _publicPhotoSection() {
    final avatarHang = _profileAvatarRadius + _avatarRingWidth;
    final heroHeight = _coverPreviewHeight + avatarHang + 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _coverPreviewHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _coverPreview(),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _coverPhotoCameraButton(onTap: getGalleryImage),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _coverPreviewHeight - avatarHang,
                left: 0,
                right: 0,
                child: Center(child: _profilePhotoWithCamera()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _heroNameAndPublicLocation(),
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

  Widget _privateDetailsCard() {
    final email = _emailController.text.trim().isEmpty
        ? 'No email saved'
        : _emailController.text.trim();

    return _profileCard(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.jebbySoftBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 22,
                color: AppColors.jebbyBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private details',
                    style: _nunito(size: 19, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your email and street address aren\'t shown on your profile.',
                    style: _privateSectionSubtitleStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _fieldLabel('Email'),
        SizedBox(height: _spaceLabelToField),
        _readOnlyFieldBox(value: email, muted: true),
        const SizedBox(height: 18),
        _fieldLabel('Saved Address'),
        SizedBox(height: _spaceLabelToField),
        if (_editingAddress)
          AddressAutocompleteField(
            controller: _locationController,
            resolvedAddress: _resolvedAddress,
            onEditingStarted: _clearResolvedAddress,
            onAddressSelected: (address) async {
              await _applySelectedAddress(address);
              if (mounted) setState(() => _editingAddress = false);
            },
            hint: 'Search for your address',
            decoration: _profileAddressDecoration,
            enableMapPicker: true,
            mapPickerInitialLatitude:
                double.tryParse(Latitiude?.toString() ?? ''),
            mapPickerInitialLongitude:
                double.tryParse(Longitude?.toString() ?? ''),
          )
        else
          _readOnlyFieldBox(
            value: _savedAddressDisplay(),
            maxLines: 2,
            muted: false,
            onTap: () => setState(() => _editingAddress = true),
            trailing: _fieldEditIcon(
              onTap: () => setState(() => _editingAddress = true),
            ),
          ),
        SizedBox(height: _spaceFieldToHelper),
        Text(
          'Default for new listings. Existing pickup locations stay the same.',
          style: _helperTextStyle,
        ),
      ],
    );
  }

  Widget _fieldEditIcon({
    required VoidCallback onTap,
    bool compact = false,
  }) {
    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.jebbyBlue,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      splashRadius: 18,
      icon: const Icon(
        Icons.edit_outlined,
        size: 18,
        color: AppColors.jebbyBlue,
      ),
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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _pageHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _publicPhotoSection(),
                    const SizedBox(height: 20),
                    _privateDetailsCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
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
        _editingAddress = false;
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
