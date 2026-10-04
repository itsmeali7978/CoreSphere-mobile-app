import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../data/models/employee.dart';
import '../../../data/repositories/employee_repository.dart';

class EmployeeDetailsController extends GetxController {
  final EmployeeRepository _employeeRepo = Get.find<EmployeeRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  late String employeeCode;
  final Rxn<Employee> employee = Rxn<Employee>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Accept either direct Employee object or employeeCode String argument
    final args = Get.arguments;
    if (args is Employee) {
      employee.value = args;
      employeeCode = args.employeeCode;
    } else if (args is String) {
      employeeCode = args;
    } else {
      employeeCode = '';
    }

    if (employeeCode.isNotEmpty) {
      fetchEmployeeDetails();
    } else {
      hasError.value = true;
    }
  }

  Future<void> fetchEmployeeDetails() async {
    if (!_networkService.isOnline.value) {
      _logger.warning("Details fetch failed: Network is offline.");
      if (employee.value != null) {
        // Fallback silently to passed/cached employee object
        return;
      }
      _showToast('Offline: No internet connection to load fresh employee details.', Colors.orangeAccent);
      hasError.value = true;
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _employeeRepo.getEmployeeByCode(employeeCode);
      if (result.success && result.data != null) {
        employee.value = result.data;
        _logger.debug("Fetched employee details successfully: ${employee.value?.employeeCode}");
      } else {
        _logger.warning("API returned failure during employee details load: ${result.message}");
        if (employee.value == null) {
          hasError.value = true;
        }
      }
    } catch (e, stack) {
      _logger.error("Failed to load employee details", e.toString(), stack);
      if (employee.value == null) {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }
}
