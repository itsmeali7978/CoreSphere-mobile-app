import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/receipt_history_controller.dart';
import '../widgets/receipt_card.dart';

class ReceiptHistoryView extends GetView<ReceiptHistoryController> {
  const ReceiptHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200.h) {
        controller.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment Receipts'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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
                  hintText: 'Search Receipt No, Customer or Reference...',
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
            const Divider(height: 1, color: Colors.grey),

            // Receipts List Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.receipts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                if (controller.hasError.value && controller.receipts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 54.sp, color: AppTheme.errorColor),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load payment receipts.',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => controller.loadReceipts(isRefresh: true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.receipts.isEmpty) {
                  return RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () => controller.loadReceipts(isRefresh: true),
                    child: ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64.sp, color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text(
                                controller.searchQuery.value.isNotEmpty
                                    ? 'No receipts matching "${controller.searchQuery.value}"'
                                    : 'No payment receipts found.',
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
                  onRefresh: () => controller.loadReceipts(isRefresh: true),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: controller.receipts.length + (controller.isLoadMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.receipts.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryColor),
                          ),
                        );
                      }

                      final receipt = controller.receipts[index];
                      return ReceiptCard(receipt: receipt);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      // Create Receipt FAB (Gated by permission: CREATE)
      floatingActionButton: Obx(() {
        if (!controller.canCreate.value) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () async {
            final result = await Get.toNamed('/payment-receipts/create');
            if (result == true) {
              controller.loadReceipts(isRefresh: true);
            }
          },
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
        );
      }),
    );
  }
}
