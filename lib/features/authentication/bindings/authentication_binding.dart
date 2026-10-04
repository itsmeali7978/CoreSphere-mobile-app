import 'package:get/get.dart';
import '../../../data/repositories/authentication_repository.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/login_controller.dart';
import '../../home/controllers/splash_controller.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Register Repository
    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepository(), fenix: true);

    // 2. Register Global Session Controller (Permanent)
    Get.put<AuthenticationController>(AuthenticationController(), permanent: true);

    // 3. Register Login Controller
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);

    // 4. Register Splash Controller
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
  }
}
