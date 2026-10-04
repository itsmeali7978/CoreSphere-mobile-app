import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/customer_form_controller.dart';

class CustomerFormView extends GetView<CustomerFormController> {
  const CustomerFormView({super.key});

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.secondaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
              errorText: errorText,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure CustomerFormController is active
    Get.find<CustomerFormController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? 'Edit Customer' : 'Create Customer')),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Customer Profile Overview
                  Obx(() => _buildTextField(
                        controller: controller.customerNoController,
                        label: 'Customer Number',
                        icon: Icons.pin_outlined,
                        enabled: !controller.isEditMode.value, // Read-only if editing
                        errorText: controller.validationErrors['customerNo'],
                        hintText: 'Leave blank to auto-generate',
                      )),
                  
                  Obx(() => _buildTextField(
                        controller: controller.nameController,
                        label: 'Customer Name (English) *',
                        icon: Icons.person_outline_rounded,
                        errorText: controller.validationErrors['name'],
                      )),
                  
                  _buildTextField(
                    controller: controller.name2Controller,
                    label: 'Arabic Name / Alternative Name',
                    icon: Icons.translate_outlined,
                  ),

                  _buildTextField(
                    controller: controller.contactPersonNameController,
                    label: 'Contact Person Name',
                    icon: Icons.assignment_ind_outlined,
                  ),

                  _buildTextField(
                    controller: controller.salesPersonCodeController,
                    label: 'Salesperson Code',
                    icon: Icons.storefront_outlined,
                  ),

                  const Divider(),
                  SizedBox(height: 12.h),

                  // Section 2: Contact Info
                  Obx(() => _buildTextField(
                        controller: controller.mobileNoController,
                        label: 'Mobile Phone Number',
                        icon: Icons.phone_iphone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
                        errorText: controller.validationErrors['mobileNo'],
                      )),

                  Obx(() => _buildTextField(
                        controller: controller.emailController,
                        label: 'Email Address',
                        icon: Icons.alternate_email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.validationErrors['email'],
                      )),

                  const Divider(),
                  SizedBox(height: 12.h),

                  // Section 3: Compliance & Pricing
                  _buildTextField(
                    controller: controller.vatRegistrationNoController,
                    label: 'VAT Registration Number',
                    icon: Icons.assignment_outlined,
                  ),

                  _buildTextField(
                    controller: controller.creditLimitController,
                    label: 'Credit Limit (﷼)',
                    icon: Icons.speed_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                  ),

                  const Divider(),
                  SizedBox(height: 12.h),

                  // Section 4: Address Details
                  _buildTextField(
                    controller: controller.addressController,
                    label: 'Street Address',
                    icon: Icons.location_on_outlined,
                  ),
                  
                  _buildTextField(
                    controller: controller.buildingNoController,
                    label: 'Building Number',
                    icon: Icons.home_outlined,
                  ),

                  _buildTextField(
                    controller: controller.districtController,
                    label: 'District',
                    icon: Icons.signpost_outlined,
                  ),

                  _buildTextField(
                    controller: controller.cityController,
                    label: 'City',
                    icon: Icons.location_city_outlined,
                  ),

                  _buildTextField(
                    controller: controller.postalCodeController,
                    label: 'Postal Code',
                    icon: Icons.local_post_office_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  SizedBox(height: 24.h),

                  // Submit button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.submitForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(height: 36.h),
                ],
              ),
            ),
            
            // Full screen loader block overlay
            Obx(() {
              if (controller.isLoading.value) {
                return const ModalBarrier(
                  dismissible: false,
                  color: Colors.transparent,
                );
              }
              return const SizedBox.shrink();
            })
          ],
        ),
      ),
    );
  }
}
