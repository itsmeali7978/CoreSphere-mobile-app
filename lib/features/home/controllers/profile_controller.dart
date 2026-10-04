import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/user.dart';
import '../../../data/models/change_password_request.dart';
import '../../../data/repositories/authentication_repository.dart';
import '../../authentication/controllers/authentication_controller.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();
  final AuthenticationController _authController = Get.find<AuthenticationController>();
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();

  final Rxn<User> currentUser = Rxn<User>();
  final RxString appVersion = 'Unknown'.obs;
  final RxString deviceInfo = 'Unknown Device'.obs;
  final RxString lastLoginFormatted = 'Never'.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _fetchSystemMetadata();
    refreshProfileData();
  }

  void _loadProfile() {
    currentUser.value = _authController.currentUser.value;
    
    // Listen to changes in the global user session state
    ever(_authController.currentUser, (User? user) {
      currentUser.value = user;
    });

    // Format last login time from configuration
    try {
      final cache = _prefsService.getAppInitializationData();
      if (cache?.device?.lastLogin != null) {
        // C# DateTime JSON serialization is parsed as String
        final DateTime parsedDate = DateTime.parse(cache!.device!.lastLogin!);
        lastLoginFormatted.value = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate.toLocal());
      }
    } catch (e) {
      lastLoginFormatted.value = 'Unknown';
    }
  }

  Future<void> _fetchSystemMetadata() async {
    try {
      // 1. Fetch App version details
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = "v${packageInfo.version} (Build ${packageInfo.buildNumber})";

      // 2. Fetch Device specifications (with platform-safe checks)
      final deviceInfoPlugin = DeviceInfoPlugin();
      
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceInfo.value = "Web - ${webInfo.browserName.name}";
      } else if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo.value = "${androidInfo.brand.toUpperCase()} ${androidInfo.model} (Android ${androidInfo.version.release})";
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo.value = "${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})";
      } else if (GetPlatform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceInfo.value = "Windows PC - ${windowsInfo.computerName}";
      } else if (GetPlatform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        deviceInfo.value = "macOS - ${macInfo.computerName}";
      }
    } catch (e, stack) {
      _logger.error("Failed to query device/package metadata", e.toString(), stack);
    }
  }

  Future<void> refreshProfileData() async {
    isRefreshing.value = true;
    try {
      // Trigger HomeController to fetch /refresh from network
      final homeController = Get.find<HomeController>();
      await homeController.refreshDashboard();
      
      // Update local values after success
      _loadProfile();
    } catch (e) {
      _logger.error("Profile refresh trigger failed", e.toString());
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final locale = languageCode == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');
    await _prefsService.saveLanguage(languageCode);
    Get.updateLocale(locale);
  }

  final RxBool isChangingPassword = false.obs;

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    debugPrint("DEBUG: changePassword called with current='$currentPassword', new='$newPassword', confirm='$confirmNewPassword'");
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      debugPrint("DEBUG: Validation failed: empty fields");
      const msg = "All fields are required.";
      AppToast.show(msg, backgroundColor: Colors.redAccent);
      return msg;
    }

    if (newPassword.length < 4) {
      debugPrint("DEBUG: Validation failed: password length < 4");
      const msg = "New password must be at least 4 characters long.";
      AppToast.show(msg, backgroundColor: Colors.redAccent);
      return msg;
    }

    if (newPassword != confirmNewPassword) {
      debugPrint("DEBUG: Validation failed: passwords do not match");
      const msg = "Passwords do not match.";
      AppToast.show(msg, backgroundColor: Colors.redAccent);
      return msg;
    }

    isChangingPassword.value = true;
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      debugPrint("DEBUG: Sending API request...");
      final result = await _authRepository.changePassword(request);
      debugPrint("DEBUG: API Response: success=${result.success}, message='${result.message}'");
      
      if (result.success) {
        AppToast.show("Password changed successfully!", backgroundColor: Colors.green);
        return null; // Null means success
      } else {
        final msg = result.message.isNotEmpty ? result.message : "Failed to change password.";
        AppToast.show(msg, backgroundColor: Colors.redAccent);
        return msg;
      }
    } catch (e, stack) {
      debugPrint("DEBUG: Exception changing password: $e\n$stack");
      _logger.error("Exception changing password", e.toString());
      const msg = "An error occurred. Please try again.";
      AppToast.show(msg, backgroundColor: Colors.redAccent);
      return msg;
    } finally {
      isChangingPassword.value = false;
      debugPrint("DEBUG: changePassword completed execution");
    }
  }

  void logout() {
    _authController.logout();
  }

  void showImageSourceSelection(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Get.back();
                  pickAndUploadImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  pickAndUploadImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickAndUploadImage(BuildContext context, ImageSource source) async {
    try {
      // 1. Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile == null) return;

      // 2. Crop image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: AppTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      // 3. Compress image
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        minWidth: 400,
        minHeight: 400,
        quality: 80,
      );

      if (compressedFile == null) {
        AppToast.show("Compression failed.", backgroundColor: Colors.redAccent);
        return;
      }

      // 4. Upload image
      AppToast.show("Uploading profile picture...", backgroundColor: Colors.blue);
      final response = await _authRepository.uploadProfileImage(compressedFile.path);

      if (response.success && response.data != null) {
        AppToast.show("Profile picture updated successfully!", backgroundColor: Colors.green);
        // Refresh session to sync across all controllers
        await refreshProfileData();
      } else {
        AppToast.show(response.message.isNotEmpty ? response.message : "Failed to upload image.", backgroundColor: Colors.redAccent);
      }
    } catch (e, stack) {
      _logger.error("Exception in pickAndUploadImage", e.toString(), stack);
      AppToast.show("An error occurred during upload.", backgroundColor: Colors.redAccent);
    }
  }
}
