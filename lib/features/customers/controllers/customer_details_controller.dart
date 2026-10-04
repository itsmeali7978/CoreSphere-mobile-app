import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerDetailsController extends GetxController {
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  late String customerNo;
  final Rxn<Customer> customer = Rxn<Customer>();
  final Rxn<Map<String, dynamic>> agingDetails = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAging = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Support loading arguments (either the direct Customer model or just the CustomerNo String)
    final args = Get.arguments;
    if (args is Customer) {
      customer.value = args;
      customerNo = args.customerNo;
    } else if (args is String) {
      customerNo = args;
    } else {
      customerNo = '';
    }

    if (customerNo.isNotEmpty) {
      fetchCustomerDetails();
      fetchCustomerAgingDetails();
    } else {
      hasError.value = true;
    }
  }

  Future<void> fetchCustomerDetails() async {
    // 1. Connectivity Check
    if (!_networkService.isOnline.value) {
      _logger.warning("Details fetch failed: Network is offline.");
      if (customer.value != null) {
        // Fallback silently to memory cached object
        return;
      }
      AppToast.show('Offline: No internet connection to load customer details.', backgroundColor: Colors.orangeAccent);
      hasError.value = true;
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _customerRepo.getCustomerByNo(customerNo);
      if (result.success && result.data != null) {
        customer.value = result.data;
        _logger.debug("Fetched customer details successfully: ${customer.value?.customerNo}");
      } else {
        _logger.warning("API returned failure during customer details load: ${result.message}");
        if (customer.value == null) {
          hasError.value = true;
        }
      }
    } catch (e, stack) {
      _logger.error("Failed to load customer details", e.toString(), stack);
      if (customer.value == null) {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerAgingDetails() async {
    if (!_networkService.isOnline.value) return;
    isLoadingAging.value = true;
    try {
      final result = await _customerRepo.getCustomerAging(customerNo);
      if (result.success && result.data != null) {
        agingDetails.value = result.data;
        _logger.debug("Fetched customer aging details successfully.");
      }
    } catch (e) {
      _logger.error("Failed to load customer aging details", e.toString());
    } finally {
      isLoadingAging.value = false;
    }
  }
}
