import 'package:get/get.dart';
import '../../../data/repositories/employee_repository.dart';
import '../controllers/employees_controller.dart';

class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EmployeeRepository>()) {
      Get.lazyPut<EmployeeRepository>(() => EmployeeRepository());
    }
    Get.lazyPut<EmployeesController>(() => EmployeesController());
  }
}
