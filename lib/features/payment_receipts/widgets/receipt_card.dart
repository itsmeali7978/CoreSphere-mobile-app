import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_payment_receipt.dart';

class ReceiptCard extends StatelessWidget {
  final CustomerPaymentReceipt receipt;

  const ReceiptCard({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(receipt.receiptDate.toLocal());

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: () => Get.toNamed('/payment-receipts/details', arguments: receipt),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Receipt Number Badge & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        receipt.receiptNo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    _buildStatusBadge(receipt.status, receipt.erpPosted),
                  ],
                ),
                SizedBox(height: 10.h),

                // Customer Name (Prioritizes Arabic)
                Text(
                  (receipt.customerName2 != null && receipt.customerName2!.trim().isNotEmpty)
                      ? receipt.customerName2!.trim()
                      : (receipt.customerName ?? 'Customer #${receipt.customerNo}'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),

                // Metadata Details & Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 13.sp, color: Colors.grey.shade600),
                            SizedBox(width: 4.w),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.payments_outlined, size: 13.sp, color: Colors.grey.shade600),
                            SizedBox(width: 4.w),
                            Text(
                              receipt.paymentMethodCode,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Amount Display
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount Received',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '⃁ ${NumberFormat('#,##0.00', 'en_US').format(receipt.amount)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontFamilyFallback: const ['SaudiRiyal'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status, bool erpPosted) {
    String label = erpPosted ? 'ERP Posted' : 'Posted';
    Color color = erpPosted ? Colors.green : Colors.blue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
