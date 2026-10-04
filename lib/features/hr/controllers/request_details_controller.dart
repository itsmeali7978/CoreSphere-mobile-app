import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/approval_request.dart';
import '../../../data/models/request_approval_history.dart';
import '../../../data/repositories/approval_repository.dart';

class RequestDetailsController extends GetxController {
  final ApprovalRepository _approvalRepo = Get.find<ApprovalRepository>();

  late ApprovalRequest request;
  final RxBool isLoadingHistory = false.obs;
  final RxList<RequestApprovalHistory> history = <RequestApprovalHistory>[].obs;
  
  final RxBool isProcessing = false.obs;
  late TextEditingController commentsController;

  final Rxn<DateTime> editedStartDate = Rxn<DateTime>();
  final Rxn<DateTime> editedEndDate = Rxn<DateTime>();
  final Rxn<double> calculatedLeaveDays = Rxn<double>();
  final RxBool isEditingDates = false.obs;
  final RxBool isSavingDates = false.obs;

  @override
  void onInit() {
    super.onInit();
    commentsController = TextEditingController();
    initFromArguments();
  }

  void initFromArguments() {
    final args = Get.arguments;
    if (args is ApprovalRequest) {
      request = args;
    } else if (args is Map) {
      final reqObj = args['request'] ?? args;
      if (reqObj is ApprovalRequest) {
        request = reqObj;
      } else if (reqObj is Map) {
        request = ApprovalRequest.fromJson(Map<String, dynamic>.from(reqObj));
      }
    }

    editedStartDate.value = request.startDate;
    editedEndDate.value = request.endDate;
    calculatedLeaveDays.value = request.leaveDays;
    fetchHistory();
    fetchRequestDetails();
  }

  Future<void> fetchRequestDetails() async {
    try {
      final result = await _approvalRepo.getRequestById(request.requestId);
      if (result.success && result.data != null) {
        request = result.data!;
        editedStartDate.value = request.startDate;
        editedEndDate.value = request.endDate;
        calculatedLeaveDays.value = request.leaveDays;
        update();
      }
    } catch (e) {}
  }

  void recalculateLeaveDays() {
    if (editedStartDate.value != null && editedEndDate.value != null) {
      final days = editedEndDate.value!.difference(editedStartDate.value!).inDays + 1;
      calculatedLeaveDays.value = days > 0 ? days.toDouble() : 1.0;
    }
  }

  Future<void> saveEditedDates() async {
    if (editedStartDate.value == null || editedEndDate.value == null) {
      AppToast.show('Please select both start and end dates', backgroundColor: Colors.orangeAccent);
      return;
    }
    if (editedEndDate.value!.isBefore(editedStartDate.value!)) {
      AppToast.show('End date cannot be before start date', backgroundColor: Colors.redAccent);
      return;
    }
    isSavingDates.value = true;
    try {
      final result = await _approvalRepo.updateRequestDates(
        request.requestId,
        editedStartDate.value!,
        editedEndDate.value!,
      );
      if (result.success && result.data != null) {
        request = result.data!;
        editedStartDate.value = request.startDate;
        editedEndDate.value = request.endDate;
        calculatedLeaveDays.value = request.leaveDays;
        isEditingDates.value = false;
        AppToast.show('Leave dates updated successfully', backgroundColor: Colors.green);
        update();
      } else {
        AppToast.show(result.message ?? 'Failed to update dates', backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      AppToast.show('An error occurred while updating dates', backgroundColor: Colors.redAccent);
    } finally {
      isSavingDates.value = false;
    }
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final result = await _approvalRepo.getRequestHistory(request.requestId);
      if (result.success && result.data != null) {
        history.value = result.data!;
      }
    } catch (e) {
      AppToast.show('Failed to load history', backgroundColor: Colors.redAccent);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> processApproval(String action) async {
    isProcessing.value = true;
    try {
      final Map<String, dynamic> data = {
        'requestId': request.requestId,
        'action': action,
        'comments': commentsController.text.trim(),
      };
      if (editedStartDate.value != null) {
        data['startDate'] = editedStartDate.value!.toIso8601String();
      }
      if (editedEndDate.value != null) {
        data['endDate'] = editedEndDate.value!.toIso8601String();
      }
      
      final result = await _approvalRepo.processApproval(data);
      if (result.success && result.data != null) {
        AppToast.show('Request $action successfully', backgroundColor: Colors.green);
        request = result.data!; // Update current request status
        await fetchHistory(); // Refresh history
        update(); // Notify UI
        Get.back(result: true); // Return to previous screen and trigger refresh
      } else {
        AppToast.show(result.message ?? 'Failed to process approval', backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      AppToast.show('An error occurred', backgroundColor: Colors.redAccent);
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    commentsController.dispose();
    super.onClose();
  }
}
