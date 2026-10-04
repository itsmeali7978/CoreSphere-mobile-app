import 'package:get/get.dart';
import '../../../data/repositories/employee_repository.dart';
import '../controllers/employee_details_controller.dart';

class EmployeeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EmployeeRepository>()) {
      Get.lazyPut<EmployeeRepository>(() => EmployeeRepository());
    }
    Get.lazyPut<EmployeeDetailsController>(() => EmployeeDetailsController());
  }
}
