import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../data/models/approval_request.dart';
import '../../../data/repositories/approval_repository.dart';

class MyRequestsController extends GetxController {
  final ApprovalRepository _approvalRepo = Get.find<ApprovalRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final RxList<ApprovalRequest> requests = <ApprovalRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    if (!_networkService.isOnline.value) {
      _logger.warning("Fetch failed: Network is offline.");
      _showToast('Offline: No internet connection to load requests.', Colors.orangeAccent);
      hasError.value = true;
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _approvalRepo.getMyRequests();
      if (result.success && result.data != null) {
        requests.value = result.data!;
      } else {
        hasError.value = true;
      }
    } catch (e, stack) {
      _logger.error("Failed to load my requests", e.toString(), stack);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }
}
