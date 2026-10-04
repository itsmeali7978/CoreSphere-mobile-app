import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/authentication_repository.dart';

class AuthenticationController extends GetxController {
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromCache();
  }

  void _loadUserFromCache() {
    try {
      final cachedData = _prefsService.getAppInitializationData();
      if (cachedData != null && cachedData.user != null) {
        currentUser.value = cachedData.user;
        isLoggedIn.value = true;
        _logger.debug("Successfully loaded user profile from cache: ${currentUser.value?.userName}");
      }
    } catch (e) {
      _logger.error("Failed to load user from cache", e.toString());
    }
  }

  void updateCurrentUser(User user) {
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  Future<void> logout({bool showSessionExpired = false}) async {
    _logger.info("Executing user logout...");
    
    // 1. Fire background logout API call without blocking UI
    _authRepository.logout().catchError((e) {
      _logger.warning("Logout API call failed silently: $e");
    });

    // 2. Clear local session data instantly
    await _storageService.clearAll();
    await _prefsService.clearPrefs();
    
    currentUser.value = null;
    isLoggedIn.value = false;

    // 3. Redirect to login screen instantly and clear history stack
    Get.offAllNamed(RouteNames.login);

    if (showSessionExpired) {
      Future.delayed(const Duration(milliseconds: 300), () {
        AppToast.show('Session Expired. Please login again.', backgroundColor: Colors.orange);
      });
    }
  }
}
