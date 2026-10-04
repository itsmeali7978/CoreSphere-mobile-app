import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/receipt_preview_controller.dart';
import '../widgets/receipt_action_buttons.dart';

class ReceiptPreviewView extends GetView<ReceiptPreviewController> {
  const ReceiptPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Receipt Print & Share'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isGeneratingPdf.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text('Generating PDF document...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          if (controller.pdfBytes.value == null) {
            return const Center(
              child: Text('Failed to load PDF document.'),
            );
          }

          return Column(
            children: [
              // PDF Document Live Visual Preview
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PdfPreview(
                      build: (format) => controller.pdfBytes.value!,
                      useActions: false,
                      allowPrinting: false,
                      allowSharing: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                    ),
                  ),
                ),
              ),

              // Action Buttons Panel at bottom
              Obx(() => Container(
                child: controller.isActionInProgress.value
                    ? Container(
                        height: 120.h,
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryColor),
                        ),
                      )
                    : ReceiptActionButtons(
                        canPrint: controller.canPrint.value,
                        canShare: controller.canShare.value,
                        canEmail: controller.canEmail.value,
                        onPrint: controller.printReceipt,
                        onWhatsApp: controller.shareWhatsApp,
                        onEmail: controller.shareEmail,
                        onDownload: controller.downloadPdf,
                        onReprint: controller.canPrint.value ? controller.printReceipt : null,
                      ),
              )),
            ],
          );
        }),
      ),
    );
  }
}
