import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';

class RequestActionButtons extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onWhatsApp;
  final VoidCallback onSavePdf;
  final VoidCallback onSaveExcel;

  const RequestActionButtons({
    super.key,
    required this.onPrint,
    required this.onWhatsApp,
    required this.onSavePdf,
    required this.onSaveExcel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'export_requests'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Print Button
              _buildActionButton(
                icon: Icons.print_rounded,
                label: 'print'.tr,
                color: AppTheme.primaryColor,
                onTap: onPrint,
              ),

              // 2. WhatsApp Share
              _buildActionButton(
                icon: Icons.share_rounded,
                label: 'share_whatsapp'.tr,
                color: Colors.green.shade600,
                onTap: onWhatsApp,
              ),

              // 3. Save PDF
              _buildActionButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'save_pdf'.tr,
                color: Colors.red.shade600,
                onTap: onSavePdf,
              ),

              // 4. Save Excel
              _buildActionButton(
                icon: Icons.table_chart_rounded,
                label: 'save_excel'.tr,
                color: Colors.teal.shade700,
                onTap: onSaveExcel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
