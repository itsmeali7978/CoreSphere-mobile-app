import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/request_type.dart';
import '../../../data/repositories/approval_repository.dart';

import '../../../data/models/user.dart';
import '../../authentication/controllers/authentication_controller.dart';
import '../../home/controllers/home_controller.dart';

class CreateRequestController extends GetxController {
  final ApprovalRepository _approvalRepo = Get.find<ApprovalRepository>();
  final AppLogger _logger = Get.find<AppLogger>();

  final RxList<RequestType> requestTypes = <RequestType>[].obs;
  final Rx<RequestType?> selectedRequestType = Rx<RequestType?>(null);
  
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final RxBool isLoadingTypes = false.obs;
  final RxBool isSubmitting = false.obs;

  // New Observables for Leave
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  // New Observables for Multi-date and Multi-attachment
  final RxList<DateTime> selectedDates = <DateTime>[].obs;
  final RxList<PlatformFile> attachments = <PlatformFile>[].obs;

  Rxn<User> get currentUser => Get.find<AuthenticationController>().currentUser;

  bool get isLeaveRequest {
    if (selectedRequestType.value == null) return false;
    return selectedRequestType.value!.code.toUpperCase().contains('LEAVE') || 
           selectedRequestType.value!.code.toUpperCase().contains('LV');
  }

  bool get isAnnualLeave {
    if (selectedRequestType.value == null) return false;
    return selectedRequestType.value!.name.toUpperCase().contains('ANNUAL') || selectedRequestType.value!.code.toUpperCase().contains('ANNUAL') || (!isUnpaidLeave && !isSickLeave);
  }

  bool get isUnpaidLeave {
    if (selectedRequestType.value == null) return false;
    return selectedRequestType.value!.name.toUpperCase().contains('UNPAID') || selectedRequestType.value!.code.toUpperCase().contains('UNPAID');
  }

  bool get isSickLeave {
    if (selectedRequestType.value == null) return false;
    return selectedRequestType.value!.name.toUpperCase().contains('SICK') || selectedRequestType.value!.code.toUpperCase().contains('SICK');
  }

  double get leaveDays {
    if (isUnpaidLeave || isSickLeave) {
      return selectedDates.length.toDouble();
    }
    
    if (startDate.value == null || endDate.value == null) return 0;
    if (endDate.value!.isBefore(startDate.value!)) return 0;
    return (endDate.value!.difference(startDate.value!).inDays + 1).toDouble();
  }

  @override
  void onInit() {
    super.onInit();
    fetchRequestTypes();
    refreshUserProfile();
    
    // Clear selections if type changes
    ever(selectedRequestType, (_) {
      startDate.value = null;
      endDate.value = null;
      selectedDates.clear();
      attachments.clear();
      refreshUserProfile();
    });
  }

  Future<void> refreshUserProfile() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().silentAutoSync();
      }
    } catch (_) {}
  }

  Future<void> fetchRequestTypes() async {
    isLoadingTypes.value = true;
    try {
      final result = await _approvalRepo.getRequestTypes();
      if (result.success && result.data != null) {
        requestTypes.value = result.data!.where((t) => t.isActive).toList();
      }
    } catch (e, stack) {
      _logger.error("Failed to load request types", e.toString(), stack);
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> pickFile({bool allowMultiple = false}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        if (allowMultiple) {
          attachments.addAll(result.files);
        } else {
          attachments.value = [result.files.first];
        }
      }
    } catch (e) {
      _logger.error("Error picking file", e.toString());
      AppToast.show('Error picking file', backgroundColor: Colors.redAccent);
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  Future<void> submitRequest() async {
    if (selectedRequestType.value == null) {
      AppToast.show('Please select a request type', backgroundColor: Colors.redAccent);
      return;
    }
    if (selectedRequestType.value == null) {
      AppToast.show('Please select a request type', backgroundColor: Colors.redAccent);
      return;
    }
    if (isLeaveRequest) {
      if (isUnpaidLeave || isSickLeave) {
        if (selectedDates.isEmpty) {
          AppToast.show('Please select at least one date', backgroundColor: Colors.redAccent);
          return;
        }
      } else {
        if (startDate.value == null || endDate.value == null) {
          AppToast.show('Start date and end date are mandatory for leave requests', backgroundColor: Colors.redAccent);
          return;
        }
        if (leaveDays <= 0) {
          AppToast.show('End date must be after or equal to start date', backgroundColor: Colors.redAccent);
          return;
        }
      }
    }

    isSubmitting.value = true;
    try {
      List<String> uploadedUrls = [];

      if (attachments.isNotEmpty) {
        var uploadFormData = dio.FormData();
        for (var file in attachments) {
          if (file.path != null) {
            uploadFormData.files.add(MapEntry(
              'attachmentFiles',
              await dio.MultipartFile.fromFile(file.path!, filename: file.name),
            ));
          }
        }
        
        final uploadResult = await _approvalRepo.uploadRequestAttachments(uploadFormData);
        
        if (uploadResult.success && uploadResult.data != null) {
           uploadedUrls = uploadResult.data!;
        }
      }

      var requestData = {
        'RequestTypeId': selectedRequestType.value!.requestTypeId,
        'Subject': 'Request - ${selectedRequestType.value!.name}',
        'Description': descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
      };

      if (isLeaveRequest) {
        if (isUnpaidLeave || isSickLeave) {
          requestData['SelectedDates'] = selectedDates.map((d) => d.toIso8601String()).toList();
          requestData['LeaveDays'] = leaveDays.toInt();
        } else {
          requestData['StartDate'] = startDate.value!.toIso8601String();
          requestData['EndDate'] = endDate.value!.toIso8601String();
          requestData['LeaveDays'] = leaveDays.toInt();
        }
      }

      if (uploadedUrls.isNotEmpty) {
        requestData['AttachmentUrls'] = uploadedUrls;
        requestData['AttachmentUrl'] = uploadedUrls.first;
      }

      final result = await _approvalRepo.createRequest(requestData);
      if (result.success) {
        AppToast.show('Request submitted successfully', backgroundColor: Colors.green);
        Get.back(result: true);
      } else {
        AppToast.show(result.message ?? 'Failed to submit request', backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      _logger.error("Error submitting request", e.toString());
      String errorMsg = 'An error occurred';
      if (e is dio.DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMsg = e.response!.data['message'];
        }
      }
      AppToast.show(errorMsg, backgroundColor: Colors.redAccent);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
