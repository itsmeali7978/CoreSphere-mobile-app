import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/request_preview_controller.dart';
import '../widgets/request_action_buttons.dart';

class RequestPreviewView extends StatelessWidget {
  const RequestPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<RequestPreviewController>()
        ? (Get.find<RequestPreviewController>()..initFromArguments())
        : Get.put(RequestPreviewController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('request_preview'.tr),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isGeneratingPdf.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text('generating_pdf'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // PDF Visual Live Preview
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

              // Action Buttons Panel under preview
              Obx(() => Container(
                child: controller.isActionInProgress.value
                    ? Container(
                        height: 120.h,
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryColor),
                        ),
                      )
                    : RequestActionButtons(
                        onPrint: controller.printPdf,
                        onWhatsApp: controller.shareWhatsApp,
                        onSavePdf: controller.savePdf,
                        onSaveExcel: controller.saveExcel,
                      ),
              )),
            ],
          );
        }),
      ),
    );
  }
}
