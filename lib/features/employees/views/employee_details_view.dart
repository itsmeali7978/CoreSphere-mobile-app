import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/employee.dart';
import '../controllers/employee_details_controller.dart';

class EmployeeDetailsView extends GetView<EmployeeDetailsController> {
  const EmployeeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Employee Profile'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.employee.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (controller.hasError.value && controller.employee.value == null) {
            return _buildErrorState();
          }

          final emp = controller.employee.value;
          if (emp == null) {
            return _buildErrorState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employee Header Banner Card
                _buildHeaderBanner(emp),
                SizedBox(height: 16.h),

                // 1. Basic Information Card
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildDetailRow('Employee Code', emp.employeeCode),
                    _buildDetailRow('Name (English)', emp.employeeNameEnglish ?? 'N/A'),
                    _buildDetailRow('Name (Arabic)', emp.employeeNameArabic ?? 'N/A'),
                    _buildDetailRow('Mobile Number', emp.mobileNo ?? 'N/A'),
                    _buildDetailRow('Email Address', emp.email ?? 'N/A'),
                    _buildDetailRow('Gender', emp.gender ?? 'N/A'),
                    _buildDetailRow('Nationality', emp.nationality ?? 'N/A'),
                    _buildDetailRow('Saudi National', emp.isSaudiNational ? 'Yes' : 'No'),
                    _buildDetailRow(
                      'Join Date',
                      emp.joinDate != null ? DateFormat('dd MMM yyyy').format(emp.joinDate!) : 'N/A',
                    ),
                    _buildDetailRow(
                      'Resumption Date',
                      emp.resumptionDate != null ? DateFormat('dd MMM yyyy').format(emp.resumptionDate!) : 'N/A',
                    ),
                    _buildDetailRow('Sales Person Code', emp.empSalesmanCode ?? 'N/A'),
                    _buildDetailRow('Status', emp.isActive ? 'Active' : 'Inactive', isStatus: true),
                  ],
                ),
                SizedBox(height: 16.h),

                // 2. Organization Card
                _buildSectionCard(
                  title: 'Organization',
                  icon: Icons.corporate_fare_outlined,
                  children: [
                    _buildDetailRow('Department', emp.departmentName ?? 'N/A'),
                    _buildDetailRow('Designation', emp.designationName ?? 'N/A'),
                    _buildDetailRow('Location', emp.location ?? 'N/A'),
                  ],
                ),
                SizedBox(height: 16.h),

                // 3. Identity Information Card
                _buildSectionCard(
                  title: 'Identity Information',
                  icon: Icons.badge_outlined,
                  children: [
                    _buildDetailRow('Iqama Number', emp.iqamaNo ?? 'N/A'),
                    _buildDetailRow('Passport Number', emp.passportNo ?? 'N/A'),
                  ],
                ),
                SizedBox(height: 16.h),

                // 4. Banking Information Card
                _buildSectionCard(
                  title: 'Banking Information',
                  icon: Icons.account_balance_outlined,
                  children: [
                    _buildDetailRow('Bank Code', emp.bankCode ?? 'N/A'),
                    _buildDetailRow('Account Number', emp.accountNo ?? 'N/A'),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderBanner(Employee emp) {
    final String displayName = emp.employeeNameEnglish?.isNotEmpty == true
        ? emp.employeeNameEnglish!
        : (emp.employeeNameArabic?.isNotEmpty == true ? emp.employeeNameArabic! : 'No Name');

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    emp.designationName ?? emp.employeeCode,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            Divider(height: 20.h, color: Colors.grey.shade200),

            // Rows
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 16.w),
          Flexible(
            child: isStatus
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: value == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: value == 'Active' ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryColor,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64.sp, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          Text(
            'Failed to Load Employee Details',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: () => controller.fetchEmployeeDetails(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
