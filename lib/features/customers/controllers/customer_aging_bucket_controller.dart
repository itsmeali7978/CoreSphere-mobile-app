import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerAgingBucketController extends GetxController {
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  late String bucketName;
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredCustomers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    bucketName = Get.arguments as String? ?? 'CURRENT';
    fetchCustomers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchCustomers() async {
    if (!_networkService.isOnline.value) {
      AppToast.show('Offline: No connection to fetch bucket details.', backgroundColor: Colors.orangeAccent);
      hasError.value = true;
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _customerRepo.getCustomersByBucket(bucketName);
      if (result.success && result.data != null) {
        customers.assignAll(result.data!);
        filteredCustomers.assignAll(result.data!);
      } else {
        hasError.value = true;
      }
    } catch (e, stack) {
      _logger.error("Failed to load aging bucket customers", e.toString(), stack);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      filteredCustomers.assignAll(customers);
      return;
    }
    final term = query.toLowerCase().trim();
    filteredCustomers.assignAll(
      customers.where((c) {
        final name = c['customerName']?.toString().toLowerCase() ?? '';
        final no = c['customerNo']?.toString().toLowerCase() ?? '';
        return name.contains(term) || no.contains(term);
      }).toList(),
    );
  }
}
