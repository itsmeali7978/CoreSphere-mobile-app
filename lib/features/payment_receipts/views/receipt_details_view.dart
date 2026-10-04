import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_payment_receipt.dart';
import '../controllers/receipt_details_controller.dart';

class ReceiptDetailsView extends GetView<ReceiptDetailsController> {
  const ReceiptDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final dateOnlyFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Receipt Details'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (controller.hasError.value || controller.receipt.value == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 54.sp, color: AppTheme.errorColor),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load receipt details.',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: controller.retry,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final r = controller.receipt.value!;
          final formattedDate = dateOnlyFormat.format(r.receiptDate.toLocal());
          final formattedCreatedDate = dateFormat.format(r.createdDate.toLocal());

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // Top Receipt Header Summary Card
                      _buildReceiptHeader(r, formattedDate),
                      SizedBox(height: 16.h),

                      // Customer Details Box
                      _buildInfoCard(
                        title: 'Customer Information',
                        icon: Icons.person_outline_rounded,
                        children: [
                          _buildDetailRow('Customer No', r.customerNo),
                          _buildDetailRow(
                            'Customer Name',
                            (r.customerName2 != null && r.customerName2!.trim().isNotEmpty)
                                ? r.customerName2!.trim()
                                : (r.customerName ?? 'N/A'),
                          ),
                          _buildDetailRow('City', r.customerCity ?? 'N/A'),
                          _buildDetailRow('Mobile No', r.customerMobile ?? 'N/A'),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Payment Information Box
                      _buildInfoCard(
                        title: 'Payment Details',
                        icon: Icons.payments_outlined,
                        children: [
                          _buildDetailRow('Amount', '⃁ ${NumberFormat('#,##0.00', 'en_US').format(r.amount)}', boldValue: true, highlightValueColor: Colors.green.shade700, useSaudiRiyalFont: true),
                          _buildDetailRow('Payment Against', r.paymentAgainst),
                          _buildDetailRow('Payment Method', r.paymentMethodCode),
                          _buildDetailRow('Reference No', r.referenceNo ?? 'N/A'),
                          _buildDetailRow('Remarks', r.remarks ?? 'N/A'),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Audit Logs Box
                      _buildInfoCard(
                        title: 'Audit Metadata',
                        icon: Icons.history_toggle_off_rounded,
                        children: [
                          _buildDetailRow('Created Date', formattedCreatedDate),
                          _buildDetailRow('Created By', r.employeeCode),
                          _buildDetailRow('ERP Sync Status', r.erpPosted ? 'Synced' : 'Pending'),
                          if (r.erpPostedDate != null)
                            _buildDetailRow('ERP Sync Date', dateFormat.format(r.erpPostedDate!.toLocal())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions Bar Gated by Permissions
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -3)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/payment-receipts/preview', arguments: r),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text(
                      'Print / Share Receipt PDF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildReceiptHeader(CustomerPaymentReceipt r, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B192C), Color(0xFF1E3E62)],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.receiptNo,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              _buildStatusBadge(r.status, r.erpPosted),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Received Date',
            style: TextStyle(fontSize: 11.sp, color: Colors.white.withOpacity(0.6)),
          ),
          SizedBox(height: 2.h),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status, bool erpPosted) {
    String label = erpPosted ? 'ERP Posted' : 'Posted';
    Color color = erpPosted ? Colors.green : Colors.blue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool boldValue = false, Color? highlightValueColor, bool useSaudiRiyalFont = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: boldValue ? FontWeight.bold : FontWeight.w600,
                color: highlightValueColor ?? AppTheme.secondaryColor,
                fontFamilyFallback: useSaudiRiyalFont ? const ['SaudiRiyal'] : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
