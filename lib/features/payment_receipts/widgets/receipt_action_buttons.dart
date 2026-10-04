import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class ReceiptActionButtons extends StatelessWidget {
  final bool canPrint;
  final bool canShare;
  final bool canEmail;
  final VoidCallback onPrint;
  final VoidCallback onWhatsApp;
  final VoidCallback onEmail;
  final VoidCallback onDownload;
  final VoidCallback? onReprint;

  const ReceiptActionButtons({
    super.key,
    required this.canPrint,
    required this.canShare,
    required this.canEmail,
    required this.onPrint,
    required this.onWhatsApp,
    required this.onEmail,
    required this.onDownload,
    this.onReprint,
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Receipt Actions',
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
              // Print Button
              if (canPrint)
                _buildActionButton(
                  icon: Icons.print_outlined,
                  label: 'Print',
                  color: AppTheme.primaryColor,
                  onTap: onPrint,
                ),

              // WhatsApp Share
              if (canShare)
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'WhatsApp',
                  color: Colors.green.shade600,
                  onTap: onWhatsApp,
                ),

              // Email Share
              if (canEmail)
                _buildActionButton(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: Colors.orange.shade700,
                  onTap: onEmail,
                ),

              // Download Local File
              _buildActionButton(
                icon: Icons.file_download_outlined,
                label: 'Save PDF',
                color: Colors.blue.shade700,
                onTap: onDownload,
              ),

              // Reprint historical receipt
              if (canPrint && onReprint != null)
                _buildActionButton(
                  icon: Icons.replay_circle_filled_outlined,
                  label: 'Reprint',
                  color: Colors.purple.shade700,
                  onTap: onReprint!,
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
      child: Container(
        width: 68.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22.sp, color: color),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
