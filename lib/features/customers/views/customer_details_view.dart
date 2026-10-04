import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  Widget _buildFieldRow(IconData icon, String label, String value, {bool useSaudiRiyalFont = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppTheme.primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontFamilyFallback: useSaudiRiyalFont ? const ['SaudiRiyal'] : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingGridItem(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              '⃁ ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
                fontFamilyFallback: const ['SaudiRiyal'],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String title, List<Widget> children) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            const Divider(height: 1),
            SizedBox(height: 8.h),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure CustomerDetailsController is active
    Get.find<CustomerDetailsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Customer Details'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          final customer = controller.customer.value;

          if (controller.isLoading.value && customer == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (controller.hasError.value && customer == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 54.sp, color: Colors.orange),
                    SizedBox(height: 16.h),
                    Text(
                      'Customer details could not be loaded.',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => controller.fetchCustomerDetails(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (customer == null) {
            return const Center(child: Text('No details loaded.'));
          }

          // Build dynamic layout structure
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Overview Card
                _buildDetailsCard('Customer Profile', [
                  _buildFieldRow(Icons.pin_outlined, 'Customer No.', customer.customerNo),
                  _buildFieldRow(Icons.person_outline_rounded, 'English Name', customer.name),
                  _buildFieldRow(Icons.translate_outlined, 'Arabic Name (Name 2)', customer.name2 ?? ''),
                  _buildFieldRow(Icons.assignment_ind_outlined, 'Contact Person', customer.contactPersonName ?? ''),
                  _buildFieldRow(Icons.storefront_outlined, 'Salesperson Code', customer.salesPersonCode ?? ''),
                ]),

                // 2. Financial & Registration Card
                _buildDetailsCard('Financial Details', [
                  _buildFieldRow(
                    Icons.account_balance_wallet_outlined,
                    'Balance',
                    customer.balance != null ? '⃁ ${customer.balance!.toStringAsFixed(2)}' : '⃁ 0.00',
                    useSaudiRiyalFont: true,
                  ),
                  _buildFieldRow(
                    Icons.speed_outlined,
                    'Credit Limit',
                    customer.creditLimit != null ? '⃁ ${customer.creditLimit!.toStringAsFixed(2)}' : 'No Credit Limit',
                    useSaudiRiyalFont: true,
                  ),
                  _buildFieldRow(Icons.assignment_outlined, 'VAT Registration Number', customer.vatRegistrationNo ?? ''),
                  Obx(() {
                    final aging = controller.agingDetails.value;
                    if (controller.isLoadingAging.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }
                    if (aging == null) {
                      return const SizedBox.shrink();
                    }

                    final currentAmt = double.tryParse(aging['currentAmount']?.toString() ?? '0.0') ?? 0.0;
                    final day31To60 = double.tryParse(aging['day31To60Amount']?.toString() ?? '0.0') ?? 0.0;
                    final day61To90 = double.tryParse(aging['day61To90Amount']?.toString() ?? '0.0') ?? 0.0;
                    final over90 = double.tryParse(aging['over90Amount']?.toString() ?? '0.0') ?? 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 12.h),
                        const Divider(height: 1),
                        SizedBox(height: 12.h),
                        Text(
                          'Aging Breakdown',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAgingGridItem('0-30 DAYS', currentAmt, const Color(0xFF2EC4B6)),
                            _buildAgingGridItem('31-60 DAYS', day31To60, const Color(0xFFFFBF00)),
                            _buildAgingGridItem('61-90 DAYS', day61To90, const Color(0xFFFF9F1C)),
                            _buildAgingGridItem('>90 DAYS', over90, const Color(0xFFE71D36)),
                          ],
                        ),
                      ],
                    );
                  }),
                ]),

                // 3. Contact Info Card
                _buildDetailsCard('Contact Info', [
                  _buildFieldRow(Icons.phone_iphone_outlined, 'Mobile Number', customer.mobileNo ?? ''),
                  _buildFieldRow(Icons.alternate_email_outlined, 'Email Address', customer.email ?? ''),
                ]),

                // 4. Address Details Card
                _buildDetailsCard('Address & Location', [
                  _buildFieldRow(Icons.location_on_outlined, 'Street Address', customer.address ?? ''),
                  _buildFieldRow(Icons.home_outlined, 'Building Number', customer.buildingNo ?? ''),
                  _buildFieldRow(Icons.signpost_outlined, 'District', customer.district ?? ''),
                  _buildFieldRow(Icons.location_city_outlined, 'City', customer.city ?? ''),
                  _buildFieldRow(Icons.local_post_office_outlined, 'Postal Code', customer.postalCode ?? ''),
                ]),
                
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: Obx(() {
        final customer = controller.customer.value;
        if (customer == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed('/payment-receipts/create', arguments: customer);
          },
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_card_rounded),
          label: const Text('Collect Payment'),
        );
      }),
    );
  }
}
