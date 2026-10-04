import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/receipt_pdf_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/customer_payment_receipt.dart';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/company_info_repository.dart';
import '../../../data/repositories/translation_repository.dart';

class ReceiptPreviewController extends GetxController {
  final PermissionService _permissionService = Get.find<PermissionService>();
  final AppLogger _logger = Get.find<AppLogger>();
  final CompanyInfoRepository _companyRepo = Get.put(CompanyInfoRepository());
  final TranslationRepository _translationRepo = Get.put(TranslationRepository());

  final Rxn<CustomerPaymentReceipt> receipt = Rxn<CustomerPaymentReceipt>();
  final Rxn<Uint8List> pdfBytes = Rxn<Uint8List>();
  final RxBool isGeneratingPdf = false.obs;
  final RxBool isActionInProgress = false.obs;

  // Permissions
  final RxBool canPrint = false.obs;
  final RxBool canShare = false.obs;
  final RxBool canEmail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    _loadReceiptAndGeneratePdf();
  }

  void _checkPermissions() {
    canPrint.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'PRINT') ||
        _permissionService.hasPermission('RECEIPT', 'PRINT');

    canShare.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'SHARE') ||
        _permissionService.hasPermission('RECEIPT', 'SHARE');

    canEmail.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'EMAIL') ||
        _permissionService.hasPermission('RECEIPT', 'EMAIL');
  }

  Future<void> _loadReceiptAndGeneratePdf() async {
    final args = Get.arguments;
    if (args is CustomerPaymentReceipt) {
      receipt.value = args;
      await generatePdfBytes();
    } else {
      AppToast.show('No receipt provided for preview.', backgroundColor: Colors.redAccent);
    }
  }

  Future<void> generatePdfBytes() async {
    if (receipt.value == null) return;
    isGeneratingPdf.value = true;
    try {
      final companyInfo = await _companyRepo.getCompanyInfo();
      final translations = await _translationRepo.getTranslationsDictionary();

      Uint8List? logoBytes;
      String? logoUrl = companyInfo.logoUrl ?? companyInfo.logoPath;
      if (logoUrl != null && logoUrl.trim().isNotEmpty) {
        try {
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
        } catch (e) {
          _logger.error("Failed to download company logo from network", e.toString());
        }
      }

      final bytes = await ReceiptPdfService.generatePdf(
        receipt.value!,
        companyInfo: companyInfo,
        translations: translations,
        logoBytes: logoBytes,
      );
      pdfBytes.value = bytes;
      _logger.info("Generated PDF receipt bytes for ${receipt.value!.receiptNo}");
    } catch (e, stack) {
      _logger.error("Failed to generate PDF for receipt", e.toString(), stack);
      AppToast.show('Failed to generate PDF receipt.', backgroundColor: Colors.redAccent);
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  /// Print receipt using native mobile printing support
  Future<void> printReceipt() async {
    if (!canPrint.value) {
      AppToast.show('Access Denied: You do not have permission to print receipts.', backgroundColor: Colors.redAccent);
      return;
    }

    if (pdfBytes.value == null) return;

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes.value!,
        name: 'Receipt_${receipt.value?.receiptNo ?? 'CPR'}',
      );
      _logger.info("Sent receipt ${receipt.value?.receiptNo} to printer dialog.");
    } catch (e) {
      _logger.error("Printing failed", e.toString());
      AppToast.show('Failed to open print dialog.', backgroundColor: Colors.redAccent);
    }
  }

  /// Share PDF receipt via WhatsApp
  
Future<void> shareWhatsApp() async {
  if (!canShare.value) {
    AppToast.show(
      'Access Denied: You do not have permission to share receipts.',
      backgroundColor: Colors.redAccent,
    );
    return;
  }

  if (pdfBytes.value == null || receipt.value == null) return;

  isActionInProgress.value = true;

  try {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/Receipt_${receipt.value!.receiptNo}.pdf';

    final file = File(filePath);

    await file.writeAsBytes(
      pdfBytes.value!,
      flush: true,
    );

    final xFile = XFile(
      filePath,
      mimeType: 'application/pdf',
    );

    Rect? sharePositionOrigin;

    // Only calculate this for iOS.
    if (Platform.isIOS && Get.context != null) {
      final renderObject = Get.context!.findRenderObject();

      if (renderObject is RenderBox && renderObject.hasSize) {
        sharePositionOrigin =
            renderObject.localToGlobal(Offset.zero) & renderObject.size;
      }
    }

    await Share.shareXFiles(
      [xFile],
      text:
          'Payment Receipt: ${receipt.value!.receiptNo}\n'
          'Customer: ${receipt.value!.customerName ?? receipt.value!.customerNo}\n'
          'Amount: ⃁ ${NumberFormat('#,##0.00', 'en_US').format(receipt.value!.amount)}',
      sharePositionOrigin: sharePositionOrigin,
    );
  } catch (e) {
    _logger.error(
      "WhatsApp share failed",
      e.toString(),
    );

    AppToast.show(
      'Failed to share via WhatsApp.',
      backgroundColor: Colors.redAccent,
    );
  } finally {
    isActionInProgress.value = false;
  }
}

  /// Share PDF receipt via Email

Future<void> shareEmail() async {
  if (!canEmail.value) {
    AppToast.show(
      'Access Denied: You do not have permission to email receipts.',
      backgroundColor: Colors.redAccent,
    );
    return;
  }

  if (pdfBytes.value == null || receipt.value == null) return;

  isActionInProgress.value = true;

  try {
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/Receipt_${receipt.value!.receiptNo}.pdf';

    final file = File(filePath);

    await file.writeAsBytes(
      pdfBytes.value!,
      flush: true,
    );

    final xFile = XFile(
      filePath,
      mimeType: 'application/pdf',
    );

    Rect? sharePositionOrigin;

    // iOS requires a valid share position.
    if (Platform.isIOS && Get.context != null) {
      final renderObject = Get.context!.findRenderObject();

      if (renderObject is RenderBox && renderObject.hasSize) {
        sharePositionOrigin =
            renderObject.localToGlobal(Offset.zero) & renderObject.size;
      }
    }

    await Share.shareXFiles(
      [xFile],
      subject:
          'Customer Payment Receipt - ${receipt.value!.receiptNo}',
      text:
          'Dear Customer,\n\n'
          'Please find attached your payment receipt '
          '${receipt.value!.receiptNo} for ⃁ '
          '${NumberFormat('#,##0.00', 'en_US').format(receipt.value!.amount)}.'
          '\n\nThank you,\nCoreSphere ERP',
      sharePositionOrigin: sharePositionOrigin,
    );
  } catch (e) {
    _logger.error(
      "Email share failed",
      e.toString(),
    );

    AppToast.show(
      'Failed to share via Email.',
      backgroundColor: Colors.redAccent,
    );
  } finally {
    isActionInProgress.value = false;
  }
}

  /// Save PDF locally to device download storage
Future<void> downloadPdf() async {
  if (pdfBytes.value == null || receipt.value == null) return;

  isActionInProgress.value = true;

  try {
    final String fileName =
        'Receipt_${receipt.value!.receiptNo}.pdf';

    Directory appDocDir;

    if (Platform.isAndroid) {
      // Keep your original Android behavior
      appDocDir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      // iOS
      appDocDir = await getApplicationDocumentsDirectory();
    }

    final String filePath = '${appDocDir.path}/$fileName';

    final File file = File(filePath);

    await file.writeAsBytes(
      pdfBytes.value!,
      flush: true,
    );

    AppToast.show(
      'Receipt saved successfully.',
      backgroundColor: Colors.green,
    );

    await OpenFilex.open(filePath);
  } catch (e) {
    _logger.error(
      "Download PDF failed",
      e.toString(),
    );

    AppToast.show(
      'Failed to save receipt locally.',
      backgroundColor: Colors.redAccent,
    );
  } finally {
    isActionInProgress.value = false;
  }
}


}
