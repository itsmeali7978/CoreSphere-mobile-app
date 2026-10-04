import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../data/repositories/authentication_repository.dart';
import 'authentication_controller.dart';

class LoginController extends GetxController {
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  // Validation observables
  final RxnString usernameError = RxnString();
  final RxnString passwordError = RxnString();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool _validateInputs() {
    bool isValid = true;
    
    if (usernameController.text.trim().isEmpty) {
      usernameError.value = 'Username is required.';
      isValid = false;
    } else {
      usernameError.value = null;
    }

    if (passwordController.text.trim().isEmpty) {
      passwordError.value = 'Password is required.';
      isValid = false;
    } else {
      passwordError.value = null;
    }

    return isValid;
  }

  Future<void> login() async {
    if (!_validateInputs()) return;
    if (isLoading.value) return; // Prevent duplicate clicks

    isLoading.value = true;
    _logger.info("Login request started for user: ${usernameController.text.trim()}");

    try {
      // 1. Perform Login API call
      final loginResult = await _authRepository.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (loginResult.success && loginResult.data != null) {
        final loginResponse = loginResult.data!;
        _logger.info("Login API succeeded. Saving token...");

        // 2. Save token and user details to Secure Storage
        await _storageService.saveToken(loginResponse.token);
        await _storageService.saveUserId(loginResponse.userId.toString());
        await _storageService.saveEmployeeCode(loginResponse.employeeCode);

        // 3. Immediately call GET /api/app/initialize to fetch application context
        _logger.info("Calling app initialization...");
        final initResult = await _authRepository.initialize();

        if (initResult.success && initResult.data != null) {
          final initResponse = initResult.data!;
          
          // 4. Save initialization data locally to SharedPreferences
          await _prefsService.saveAppInitializationData(initResponse);
          _logger.info("Initialization data cached successfully.");

          // 5. Update global Authentication state
          if (initResponse.user != null) {
            Get.find<AuthenticationController>().updateCurrentUser(initResponse.user!);
          }

          isLoading.value = false;
          _logger.info("App initialized. Navigating to Home...");
          
          // 6. Register device for push notifications
          if (Get.isRegistered<PushNotificationService>()) {
            final fcmToken = Get.find<PushNotificationService>().fcmToken;
            if (fcmToken != null) {
              await _authRepository.registerDevice(fcmToken);
              _logger.info("FCM device registered.");
            }
          }

          // 7. Navigate to Home Screen and clear previous route stack
          Get.offAllNamed(RouteNames.home);
        } else {
          // Initialization failed, treat as login failure to prevent entering app in half-initialized state
          final errMsg = initResult.message.isNotEmpty ? initResult.message : "Failed to load application configuration.";
          _logger.error("Initialization API failed: $errMsg", null);
          _showError(errMsg);
          
          // Rollback saved credentials to maintain security
          await _storageService.clearAll();
          isLoading.value = false;
        }
      } else {
        final errMsg = loginResult.message.isNotEmpty ? loginResult.message : "Invalid username or password.";
        _logger.warning("Login failed: $errMsg");
        _showError(errMsg);
        isLoading.value = false;
      }
    } catch (e, stackTrace) {
      _logger.error("Exception during login flow", e.toString(), stackTrace);
      _showError("A connection error occurred. Please check your network and try again.");
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    AppToast.show(message, backgroundColor: Colors.redAccent);
  }
}
