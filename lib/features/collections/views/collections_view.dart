import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/collections_controller.dart';
import '../widgets/collection_card.dart';

class CollectionsView extends GetView<CollectionsController> {
  const CollectionsView({super.key});

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
        title: Text('payment_collections'.tr),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCollections(isRefresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header Container
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              color: Colors.white,
              child: Column(
                children: [
                  // Main Search Bar (Customer Name, Receipt No, etc.)
                  TextField(
                    onChanged: controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'search_araname_custmrno'.tr,
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Employee ID Search Input Field
                  Obx(() => TextField(
                        controller: controller.employeeSearchController,
                        onChanged: controller.updateEmployeeSearch,
                        decoration: InputDecoration(
                          hintText: 'enter_empid_tofilter'.tr,
                          prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryColor),
                          suffixIcon: (controller.selectedEmployeeCode.value.isNotEmpty || controller.employeeSearchController.text.isNotEmpty)
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: controller.clearEmployeeFilter,
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),

            // Collections List Content
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
                            'Failed to load payment collections.',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => controller.loadCollections(isRefresh: true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displayed = controller.displayedReceipts;

                if (displayed.isEmpty) {
                  return RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () => controller.loadCollections(isRefresh: true),
                    child: ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 64.sp, color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text(
                                controller.searchQuery.value.isNotEmpty || controller.selectedEmployeeCode.value.isNotEmpty
                                    ? 'No collections matching your search criteria.'
                                    : 'No pending payment collections.',
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
                  onRefresh: () => controller.loadCollections(isRefresh: true),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: displayed.length + (controller.isLoadMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayed.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryColor),
                          ),
                        );
                      }

                      final receipt = displayed[index];
                      return CollectionCard(receipt: receipt);
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
}
