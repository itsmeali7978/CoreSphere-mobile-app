import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/create_receipt_controller.dart';

class CreateReceiptView extends GetView<CreateReceiptController> {
  const CreateReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('New Payment Receipt'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Payment Receipt',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Receipt numbers are generated automatically by backend.',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Form Section: Customer Selection
              _buildSectionTitle('Customer Information *'),
              SizedBox(height: 8.h),
              Obx(() {
                if (controller.isLoadingCustomers.value) {
                  return Container(
                    height: 52.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Text('Loading customers...'),
                      ],
                    ),
                  );
                }

                final isSelected = controller.selectedCustomer.value != null;
                final cust = controller.selectedCustomer.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showCustomerSearchBottomSheet(context),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: controller.customerError.value != null ? AppTheme.errorColor : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.corporate_fare_outlined,
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                isSelected
                                    ? '${cust!.customerNo} - ${cust.name2 != null && cust.name2!.trim().isNotEmpty ? cust.name2! : cust.name}'
                                    : 'Select Customer',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade500,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.customerError.value != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          controller.customerError.value!,
                          style: TextStyle(color: AppTheme.errorColor, fontSize: 12.sp),
                        ),
                      ),
                    if (isSelected && cust != null) ...[
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Outstanding Balance',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    cust.balance != null ? '⃁ ${cust.balance!.toStringAsFixed(2)}' : '⃁ 0.00',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: (cust.balance ?? 0) > 0 ? AppTheme.errorColor : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
              SizedBox(height: 20.h),

              // Form Section: Date & Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Date Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Receipt Date *'),
                        SizedBox(height: 8.h),
                        Obx(() => Container(
                          height: 52.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  dateFormat.format(controller.selectedDate.value),
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Amount Field
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Amount (﷼) *'),
                        SizedBox(height: 8.h),
                        Obx(() => TextField(
                          controller: controller.amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            errorText: controller.amountError.value,
                            prefixIcon: const Icon(Icons.attach_money_rounded, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Form Section: Payment Method
              _buildSectionTitle('Payment Method *'),
              SizedBox(height: 8.h),
              Obx(() => Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: controller.paymentMethods.map((method) {
                  final isSelected = controller.selectedPaymentMethod.value == method['code'];
                  return ChoiceChip(
                    label: Text(method['name']!),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                    onSelected: (val) {
                      if (val) controller.setPaymentMethod(method['code']!);
                    },
                  );
                }).toList(),
              )),
              SizedBox(height: 20.h),

              // Form Section: Payment Against
              _buildSectionTitle('Payment Against *'),
              SizedBox(height: 8.h),
              Obx(() => Row(
                children: [
                  ChoiceChip(
                    label: const Text('Partial Payment'),
                    selected: controller.selectedPaymentAgainst.value == 'Partial Payment',
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: controller.selectedPaymentAgainst.value == 'Partial Payment' ? Colors.white : Colors.black87,
                      fontWeight: controller.selectedPaymentAgainst.value == 'Partial Payment' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                    onSelected: (val) {
                      if (val) controller.selectedPaymentAgainst.value = 'Partial Payment';
                    },
                  ),
                  SizedBox(width: 12.w),
                  ChoiceChip(
                    label: const Text('Full Payment'),
                    selected: controller.selectedPaymentAgainst.value == 'Full Payment',
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: controller.selectedPaymentAgainst.value == 'Full Payment' ? Colors.white : Colors.black87,
                      fontWeight: controller.selectedPaymentAgainst.value == 'Full Payment' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                    onSelected: (val) {
                      if (val) controller.selectedPaymentAgainst.value = 'Full Payment';
                    },
                  ),
                ],
              )),
              SizedBox(height: 20.h),

              // Form Section: Reference Number (Optional)
              _buildSectionTitle('Reference Number'),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.referenceController,
                decoration: InputDecoration(
                  hintText: 'e.g. Check / Transfer / Transaction Ref #',
                  prefixIcon: const Icon(Icons.pin_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Form Section: Remarks (Optional)
              _buildSectionTitle('Remarks'),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional notes or payment remarks...',
                  prefixIcon: const Icon(Icons.notes_rounded, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.submitReceipt(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Save Payment Receipt',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              )),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  void _showCustomerSearchBottomSheet(BuildContext context) {
    // Reset query when opening
    controller.searchQuery.value = '';
    controller.searchController.clear();
    controller.filteredCustomers.assignAll(controller.customers);

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // 1. Drag Handle
            Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // 2. Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Customer',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    iconSize: 20.sp,
                    color: Colors.grey.shade600,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // 3. Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by Customer No. or Name...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, size: 20.sp, color: AppTheme.primaryColor),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: Icon(Icons.clear, size: 18.sp, color: Colors.grey.shade600),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchQuery.value = '';
                          controller.filteredCustomers.assignAll(controller.customers);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp),
                onChanged: (val) {
                  controller.searchQuery.value = val;
                },
              ),
            ),
            
            // 4. Customers List
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }
                
                if (controller.filteredCustomers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_outlined, size: 48.sp, color: Colors.grey.shade300),
                          SizedBox(height: 12.h),
                          Text(
                            'No customers found',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Try searching with a different name or ID.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: controller.filteredCustomers.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final cust = controller.filteredCustomers[index];
                    final isCurrentSelected = controller.selectedCustomer.value?.customerNo == cust.customerNo;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                      title: Text(
                        cust.name2 != null && cust.name2!.trim().isNotEmpty ? cust.name2! : cust.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  cust.customerNo,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              if (cust.city != null && cust.city!.trim().isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Icon(Icons.location_on_outlined, size: 12.sp, color: Colors.grey.shade400),
                                  SizedBox(width: 2.w),
                                  Text(
                                    cust.city!,
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                                  ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: isCurrentSelected
                          ? Icon(Icons.check_circle, color: Colors.green.shade600, size: 20.sp)
                          : Icon(Icons.arrow_forward_ios, color: Colors.grey.shade300, size: 14.sp),
                      onTap: () {
                        controller.setCustomer(cust);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
