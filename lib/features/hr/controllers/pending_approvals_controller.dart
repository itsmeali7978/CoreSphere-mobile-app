import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../data/models/approval_request.dart';
import '../../../data/repositories/approval_repository.dart';

class PendingApprovalsController extends GetxController {
  final ApprovalRepository _approvalRepo = Get.find<ApprovalRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final RxList<ApprovalRequest> pendingRequests = <ApprovalRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingApprovals();
  }

  Future<void> fetchPendingApprovals() async {
    if (!_networkService.isOnline.value) {
      _logger.warning("Fetch failed: Network is offline.");
      _showToast('Offline: No internet connection.', Colors.orangeAccent);
      hasError.value = true;
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _approvalRepo.getPendingApprovals();
      if (result.success && result.data != null) {
        pendingRequests.value = result.data!;
      } else {
        hasError.value = true;
      }
    } catch (e, stack) {
      _logger.error("Failed to load pending approvals", e.toString(), stack);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }
}
