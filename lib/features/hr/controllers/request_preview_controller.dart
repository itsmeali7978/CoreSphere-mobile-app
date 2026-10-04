import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/request_export_service.dart';
import '../../../data/models/approval_request.dart';
import '../../../data/models/company_info.dart';
import '../../../data/models/request_approval_history.dart';
import '../../../data/repositories/company_info_repository.dart';
import '../../../data/repositories/employee_repository.dart';

class RequestPreviewController extends GetxController {
  final Rxn<ApprovalRequest> request = Rxn<ApprovalRequest>();
  final RxList<RequestApprovalHistory> history = <RequestApprovalHistory>[].obs;
  final Rxn<Uint8List> pdfBytes = Rxn<Uint8List>();
  final RxBool isGeneratingPdf = false.obs;
  final RxBool isActionInProgress = false.obs;

  @override
  void onInit() {
    super.onInit();
    initFromArguments();
  }

  void initFromArguments() {
    _loadArgumentsAndGeneratePdf();
  }

  void _loadArgumentsAndGeneratePdf() {
    final args = Get.arguments;
    if (args is ApprovalRequest) {
      request.value = args;
    } else if (args is Map) {
      final reqObj = args['request'] ?? args;
      if (reqObj is ApprovalRequest) {
        request.value = reqObj;
      } else if (reqObj is Map) {
        request.value = ApprovalRequest.fromJson(Map<String, dynamic>.from(reqObj));
      }

      if (args['history'] is List<RequestApprovalHistory>) {
        history.assignAll(args['history'] as List<RequestApprovalHistory>);
      } else if (args['history'] is List) {
        final list = (args['history'] as List)
            .map((item) => item is RequestApprovalHistory
                ? item
                : RequestApprovalHistory.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        history.assignAll(list);
      }
    }

    if (request.value == null) {
      AppToast.show('No request details provided for preview.', backgroundColor: Colors.redAccent);
      return;
    }

    generatePdf();
  }

  Future<void> generatePdf() async {
    if (request.value == null) return;
    try {
      isGeneratingPdf.value = true;

      // Fetch fresh employee info if Arabic name or resumption date is missing
      if (request.value!.employeeCode.isNotEmpty && (request.value!.employeeNameArabic == null || request.value!.resumptionDate == null)) {
        try {
          final empRepo = Get.isRegistered<EmployeeRepository>()
              ? Get.find<EmployeeRepository>()
              : Get.put(EmployeeRepository());
          final empRes = await empRepo.getEmployeeByCode(request.value!.employeeCode);
          if (empRes.success && empRes.data != null) {
            final emp = empRes.data!;
            final updatedReq = ApprovalRequest(
              requestId: request.value!.requestId,
              requestNo: request.value!.requestNo,
              requestTypeId: request.value!.requestTypeId,
              requestTypeName: request.value!.requestTypeName,
              employeeCode: request.value!.employeeCode,
              employeeName: request.value!.employeeName,
              subject: request.value!.subject,
              description: request.value!.description,
              status: request.value!.status,
              statusDisplayName: request.value!.statusDisplayName,
              currentLevel: request.value!.currentLevel,
              currentApproverEmployeeCode: request.value!.currentApproverEmployeeCode,
              currentApproverName: request.value!.currentApproverName,
              startDate: request.value!.startDate,
              endDate: request.value!.endDate,
              leaveDays: request.value!.leaveDays,
              attachmentUrl: request.value!.attachmentUrl,
              selectedDates: request.value!.selectedDates,
              attachmentUrls: request.value!.attachmentUrls,
              createdDate: request.value!.createdDate,
              completedDate: request.value!.completedDate,
              daysSinceLastVacation: request.value!.daysSinceLastVacation,
              employeeNameArabic: emp.employeeNameArabic ?? request.value!.employeeNameArabic,
              iqamaNo: emp.iqamaNo ?? request.value!.iqamaNo,
              joinDate: emp.joinDate ?? request.value!.joinDate,
              resumptionDate: emp.resumptionDate ?? request.value!.resumptionDate,
              approvalHistory: request.value!.approvalHistory,
            );
            request.value = updatedReq;
          }
        } catch (_) {}
      }

      CompanyInfo? companyInfo;
      Uint8List? logoBytes;

      try {
        final companyRepo = Get.put(CompanyInfoRepository());
        companyInfo = await companyRepo.getCompanyInfo();

        String? logoUrl = companyInfo.logoUrl ?? companyInfo.logoPath;
        if (logoUrl != null && logoUrl.trim().isNotEmpty) {
          String fullUrl = logoUrl.trim();
          if (!fullUrl.startsWith('http')) {
            final baseUri = Uri.parse(ApiConstants.baseUrl);
            final origin = '${baseUri.scheme}://${baseUri.host}:${baseUri.port}';
            fullUrl = fullUrl.startsWith('/') ? '$origin$fullUrl' : '$origin/$fullUrl';
          }
          final dio = Dio();
          final response = await dio.get<List<int>>(fullUrl, options: Options(responseType: ResponseType.bytes));
          if (response.data != null && response.data!.isNotEmpty) {
            logoBytes = Uint8List.fromList(response.data!);
          }
        }
      } catch (_) {}

      final bytes = await RequestExportService.generateSingleRequestPdfBytes(
        request.value!,
        history: history,
        companyInfo: companyInfo,
        logoBytes: logoBytes,
      );
      pdfBytes.value = bytes;
    } catch (e) {
      AppToast.show('Failed to generate PDF document: $e', backgroundColor: Colors.redAccent);
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  /// Option 1: Print PDF
  Future<void> printPdf() async {
    if (pdfBytes.value == null) return;
    try {
      isActionInProgress.value = true;
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes.value!,
        name: 'Request_${request.value?.requestNo ?? "Details"}.pdf',
      );
    } catch (e) {
      AppToast.show('Failed to print document: $e', backgroundColor: Colors.redAccent);
    } finally {
      isActionInProgress.value = false;
    }
  }

  /// Option 2: Share WhatsApp
  Future<void> shareWhatsApp() async {
    if (pdfBytes.value == null || request.value == null) return;
    try {
      isActionInProgress.value = true;
      final directory = await getTemporaryDirectory();
      final fileName = 'Request_${request.value!.requestNo}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes.value!);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CoreSphere ERP - Request Details (${request.value!.requestNo})',
      );
    } catch (e) {
      AppToast.show('Failed to share via WhatsApp: $e', backgroundColor: Colors.redAccent);
    } finally {
      isActionInProgress.value = false;
    }
  }

  /// Option 3: Save PDF
  Future<void> savePdf() async {
    if (pdfBytes.value == null || request.value == null) return;
    try {
      isActionInProgress.value = true;
      final directory = await getTemporaryDirectory();
      final fileName = 'Request_${request.value!.requestNo}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes.value!);

      AppToast.show('PDF document saved successfully', backgroundColor: Colors.green);
      await OpenFilex.open(file.path);
    } catch (e) {
      AppToast.show('Failed to save PDF: $e', backgroundColor: Colors.redAccent);
    } finally {
      isActionInProgress.value = false;
    }
  }

  /// Option 4: Save Excel
  Future<void> saveExcel() async {
    if (request.value == null) return;
    try {
      isActionInProgress.value = true;
      await RequestExportService.exportSingleRequestToExcel(
        request.value!,
        history: history,
      );
    } catch (e) {
      AppToast.show('Failed to save Excel: $e', backgroundColor: Colors.redAccent);
    } finally {
      isActionInProgress.value = false;
    }
  }
}
