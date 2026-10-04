import 'package:get/get.dart';
import '../../authentication/bindings/authentication_binding.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Register all authentication dependencies first
    AuthenticationBinding().dependencies();

    // Eagerly instantiate SplashController
    Get.put<SplashController>(SplashController());
  }
}
