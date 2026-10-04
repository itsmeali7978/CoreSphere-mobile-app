import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/customer_aging_bucket_controller.dart';

class CustomerAgingBucketView extends GetView<CustomerAgingBucketController> {
  const CustomerAgingBucketView({super.key});

  String _getBucketDisplayName(String name) {
    switch (name.toUpperCase()) {
      case 'CURRENT':
        return 'Current (0-30 Days)';
      case '31-60':
        return '31-60 Days Aging';
      case '61-90':
        return '61-90 Days Aging';
      case 'OVER90':
        return 'Over 90 Days Aging';
      default:
        return '$name Aging';
    }
  }

  Color _getBucketColor(String name) {
    switch (name.toUpperCase()) {
      case 'CURRENT':
        return const Color(0xFF2EC4B6);
      case '31-60':
        return const Color(0xFFFFBF00);
      case '61-90':
        return const Color(0xFFFF9F1C);
      case 'OVER90':
        return const Color(0xFFE71D36);
      default:
        return AppTheme.primaryColor;
    }
  }

  double _getBucketAmount(Map<String, dynamic> item, String name) {
    final key = _getBucketJsonKey(name);
    return double.tryParse(item[key]?.toString() ?? '0.0') ?? 0.0;
  }

  String _getBucketJsonKey(String name) {
    switch (name.toUpperCase()) {
      case 'CURRENT':
        return 'currentAmount';
      case '31-60':
        return 'day31To60Amount';
      case '61-90':
        return 'day61To90Amount';
      case 'OVER90':
        return 'over90Amount';
      default:
        return 'totalDueAmount';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bucketColor = _getBucketColor(controller.bucketName);
    final displayName = _getBucketDisplayName(controller.bucketName);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(displayName),
        elevation: 0,
        backgroundColor: bucketColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.search,
                decoration: InputDecoration(
                  hintText: 'Search customer name or ID...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.search('');
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: bucketColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
            
            // Customer List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                if (controller.hasError.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 54.sp, color: Colors.redAccent),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load customers.',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => controller.fetchCustomers(),
                            style: ElevatedButton.styleFrom(backgroundColor: bucketColor),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.filteredCustomers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 54.sp, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            'No customers found in this bucket.',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredCustomers[index];
                    final customerNo = item['customerNo']?.toString() ?? '';
                    final name = item['customerName']?.toString() ?? 'Unknown Customer';
                    final bucketAmt = _getBucketAmount(item, controller.bucketName);
                    final totalDueAmt = double.tryParse(item['totalDueAmount']?.toString() ?? '0.0') ?? 0.0;

                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          Get.toNamed(RouteNames.customerDetails, arguments: customerNo);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              // Left Icon Avatar
                              Container(
                                width: 44.w,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: bucketColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: bucketColor,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              
                              // Middle details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      'ID: $customerNo',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              
                              // Right Amount columns
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '⃁ ${bucketAmt.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: bucketColor,
                                      fontFamilyFallback: const ['SaudiRiyal'],
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Total Due: ⃁ ${totalDueAmt.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                      fontFamilyFallback: const ['SaudiRiyal'],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
