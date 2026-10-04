import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_payment_receipt.dart';
import '../controllers/collections_controller.dart';

class CollectionCard extends GetView<CollectionsController> {
  final CustomerPaymentReceipt receipt;

  const CollectionCard({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(receipt.receiptDate.toLocal());
    final arabicName = receipt.customerName2 ?? receipt.customerName ?? 'Customer #${receipt.customerNo}';

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header (Receipt No & Status)
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'pending_collection'.tr,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Arabic Customer Name & Customer No
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline_rounded, size: 18.sp, color: AppTheme.primaryColor),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabicName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'customer_no'.tr}: ${receipt.customerNo}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Date & Amount Section
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
                        Icon(Icons.person_pin_outlined, size: 13.sp, color: Colors.grey.shade600),
                        SizedBox(width: 4.w),
                        Text(
                          '${'created_by'.tr}: ${receipt.employeeCode}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'amount_due'.tr,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '⃁ ${receipt.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontFamilyFallback: const ['SaudiRiyal'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Action Button: Receive Payment
            SizedBox(
              width: double.infinity,
              height: 49.h,
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmationDialog(context),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label:  Text(
                  'receive_payment'.tr  ,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.payments_outlined, color: AppTheme.primaryColor, size: 24.sp),
            SizedBox(width: 8.w),
            Text('confirm_payment'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('collection_confrm_msg'.tr ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${'receipts'.tr}: ${receipt.receiptNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${'customer'.tr}: ${receipt.customerName2 ?? receipt.customerName ?? receipt.customerNo}'),
                  Text('${'amount'.tr }: ⃁ ${receipt.amount.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:  Text('cancel'.tr, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              controller.receivePayment(receipt);
            },
            icon: const Icon(Icons.check, size: 16),
            label:  Text('receive_payment'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
