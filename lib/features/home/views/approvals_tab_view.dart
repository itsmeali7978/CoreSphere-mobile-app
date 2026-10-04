import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class ApprovalsTabView extends StatelessWidget {
  const ApprovalsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon illustration container
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.playlist_add_check_circle_outlined,
                  size: 64.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Title
              Text(
                'Approvals',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Subtitle
              Text(
                'No pending approvals.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
