import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer.dart';
import '../controllers/customers_controller.dart';

class CustomersListView extends GetView<CustomersController> {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {

    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200.h) {
        controller.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Customers'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            IconData icon = Icons.sort_rounded;
            Color iconColor = Colors.white70;
            if (controller.sortMode.value != CustomerSortMode.none) {
              icon = controller.sortMode.value == CustomerSortMode.balanceAsc
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded;
              iconColor = Colors.white;
            }
            return IconButton(
              icon: Icon(icon, color: iconColor),
              tooltip: 'Sort by Balance',
              onPressed: () => _showSortDialog(context),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              color: Colors.white,
              child: TextField(
                onChanged: controller.updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search by Code, Name or City...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Radio Button Style Toggle Filter (My Customers / All Customers)
            _buildRadioFilterHeader(),
            const Divider(height: 1, color: Colors.grey),

            // Paged List Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.sortedCustomers.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                if (controller.hasError.value && controller.sortedCustomers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_outlined, size: 54.sp, color: AppTheme.errorColor),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load customers.',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => controller.loadCustomers(isRefresh: true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.sortedCustomers.isEmpty) {
                  return RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () => controller.loadCustomers(isRefresh: true),
                    child: ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline_rounded, size: 64.sp, color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text(
                                controller.filterMode.value == CustomerFilterMode.myCustomers
                                    ? 'No customers assigned to you.'
                                    : 'No customers found.',
                                style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: () => controller.loadCustomers(isRefresh: true),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: controller.sortedCustomers.length + (controller.isLoadMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.sortedCustomers.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryColor),
                          ),
                        );
                      }

                      final customer = controller.sortedCustomers[index];
                      return _buildCustomerCard(customer);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioFilterHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final isMyCustomers = controller.filterMode.value == CustomerFilterMode.myCustomers;
              return InkWell(
                onTap: () => controller.setFilterMode(CustomerFilterMode.myCustomers),
                borderRadius: BorderRadius.circular(10.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isMyCustomers ? AppTheme.primaryColor.withOpacity(0.08) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isMyCustomers ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isMyCustomers ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<CustomerFilterMode>(
                        value: CustomerFilterMode.myCustomers,
                        groupValue: controller.filterMode.value,
                        onChanged: (val) {
                          if (val != null) controller.setFilterMode(val);
                        },
                        activeColor: AppTheme.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'My Customers',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isMyCustomers ? FontWeight.bold : FontWeight.w500,
                          color: isMyCustomers ? AppTheme.primaryColor : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() {
              final isAllCustomers = controller.filterMode.value == CustomerFilterMode.allCustomers;
              return InkWell(
                onTap: () => controller.setFilterMode(CustomerFilterMode.allCustomers),
                borderRadius: BorderRadius.circular(10.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isAllCustomers ? AppTheme.primaryColor.withOpacity(0.08) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isAllCustomers ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isAllCustomers ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<CustomerFilterMode>(
                        value: CustomerFilterMode.allCustomers,
                        groupValue: controller.filterMode.value,
                        onChanged: (val) {
                          if (val != null) controller.setFilterMode(val);
                        },
                        activeColor: AppTheme.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'All Customers',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isAllCustomers ? FontWeight.bold : FontWeight.w500,
                          color: isAllCustomers ? AppTheme.primaryColor : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
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
          onTap: () => Get.toNamed('/customers/details', arguments: customer),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header row (Customer Code & Arrow)
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
                        customer.customerNo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Customer Name
                Text(
                  customer.name2 != null && customer.name2!.trim().isNotEmpty
                      ? customer.name2!
                      : customer.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                
                // Contact / Metadata details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (customer.city != null && customer.city!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(
                                  customer.city!,
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        if (customer.mobileNo != null && customer.mobileNo!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.phone_iphone_outlined, size: 14.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Text(
                                customer.mobileNo!,
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    // Balance info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Balance',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          customer.balance != null
                              ? '⃁ ${customer.balance!.toStringAsFixed(2)}'
                              : '⃁ 0.00',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: (customer.balance ?? 0) > 0 ? AppTheme.errorColor : Colors.green.shade600,
                            fontFamilyFallback: const ['SaudiRiyal'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(height: 1, thickness: 0.5),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Get.toNamed('/payment-receipts/create', arguments: customer);
                      },
                      icon: Icon(Icons.add_card_rounded, size: 16.sp),
                      label: Text(
                        'Collect Payment',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
                        ),
                      ),
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

  void _showSortDialog(BuildContext context) {
    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('Sort Customers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<CustomerSortMode>(
              title: const Text('Default (No sorting)'),
              value: CustomerSortMode.none,
              groupValue: controller.sortMode.value,
              onChanged: (val) {
                if (val != null) controller.setSortMode(val);
                Get.back();
              },
            ),
            RadioListTile<CustomerSortMode>(
              title: const Text('Balance: High to Low'),
              value: CustomerSortMode.balanceDesc,
              groupValue: controller.sortMode.value,
              onChanged: (val) {
                if (val != null) controller.setSortMode(val);
                Get.back();
              },
            ),
            RadioListTile<CustomerSortMode>(
              title: const Text('Balance: Low to High'),
              value: CustomerSortMode.balanceAsc,
              groupValue: controller.sortMode.value,
              onChanged: (val) {
                if (val != null) controller.setSortMode(val);
                Get.back();
              },
            ),
          ],
        ),
      )),
    );
  }
}
