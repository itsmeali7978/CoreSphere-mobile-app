import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../data/repositories/authentication_repository.dart';
import '../../../data/models/api_response.dart';
import '../../../core/services/push_notification_service.dart';
import '../../authentication/controllers/authentication_controller.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();
  final AppLogger _logger = Get.find<AppLogger>();

  @override
  void onInit() {
    super.onInit();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    _logger.info("Initializing Splash Screen Session Check...");
    
    // Minimum splash screen delay (e.g. 2 seconds) for premium aesthetic transition
    final splashDelay = Future.delayed(const Duration(seconds: 2));

    try {
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        _logger.info("No active token found in Secure Storage.");
        await splashDelay;
        Get.offNamed(RouteNames.login);
      } else {
        _logger.info("Active token found. Calling Refresh API...");
        
        // Parallelize splash delay with API call (if API is fast, wait for minimum splash duration)
        final results = await Future.wait([
          _authRepository.refresh(),
          splashDelay,
        ]);

        final refreshResult = results[0] as ApiResponse<AppInitializationResponse>;

        if (refreshResult.success && refreshResult.data != null) {
          final initResponse = refreshResult.data!;
          
          // Update SharedPreferences cached initialization data
          await _prefsService.saveAppInitializationData(initResponse);
          _logger.info("Session successfully refreshed. Updating local cache.");

          // Update current user state globally
          if (initResponse.user != null) {
            Get.find<AuthenticationController>().updateCurrentUser(initResponse.user!);
          }
          
          // Register device for push notifications
          if (Get.isRegistered<PushNotificationService>()) {
            final fcmToken = Get.find<PushNotificationService>().fcmToken;
            if (fcmToken != null) {
              try {
                await _authRepository.registerDevice(fcmToken);
                _logger.info("FCM device registered from splash screen.");
              } catch (e) {
                _logger.error("Failed to register FCM device from splash screen: $e");
              }
            }
          }

          Get.offNamed(RouteNames.home);
        } else {
          // If token expired or API failed, clear and logout automatically
          _logger.warning("Session refresh failed: ${refreshResult.message}. Cleaning session details...");
          await _storageService.clearAll();
          await _prefsService.clearPrefs();
          
          Get.offNamed(RouteNames.login);
        }
      }
    } catch (e, stackTrace) {
      _logger.error("Exception during splash session check", e.toString(), stackTrace);
      // Fail-safe redirect to login
      await _storageService.clearAll();
      await _prefsService.clearPrefs();
      await splashDelay;
      Get.offNamed(RouteNames.login);
    }
  }
}
