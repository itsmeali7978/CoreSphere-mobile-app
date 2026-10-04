import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/modules_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/bottom_navigation_controller.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/module_navigation_service.dart';
import '../../../data/repositories/approval_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<PermissionService>(() => PermissionService(), fenix: true);
    Get.lazyPut<ModuleNavigationService>(() => ModuleNavigationService(), fenix: true);

    // Controllers
    Get.lazyPut<BottomNavigationController>(() => BottomNavigationController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ModulesController>(() => ModulesController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    
    // Repositories for embedded tabs
    if (!Get.isRegistered<ApprovalRepository>()) {
      Get.put<ApprovalRepository>(ApprovalRepository(), permanent: true);
    }
  }
}
