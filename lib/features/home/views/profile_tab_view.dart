import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class ProfileTabView extends GetView<ProfileController> {
  const ProfileTabView({super.key});

  Widget _buildInfoRow(IconData icon, String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      value.isNotEmpty ? value : 'Not Specified',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 36.w,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('my_profile'.tr),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          final user = controller.currentUser.value;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final String initials = user.userName.trim().isNotEmpty
              ? user.userName.substring(0, 2).toUpperCase()
              : "U";

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Avatar Header Card
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () => controller.showImageSourceSelection(context),
                              child: Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryColor, Color(0xFF0073E6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: user.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Center(
                                            child: Text(
                                              initials,
                                              style: TextStyle(
                                                fontSize: 26.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              fontSize: 26.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.showImageSourceSelection(context),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          user.employeeNameEnglish ?? user.userName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user.roleName ?? 'Enterprise User',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Employee Details Card
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'employee_information'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                        _buildInfoRow(Icons.pin_outlined, 'employee_code'.tr, user.employeeCode),
                        _buildInfoRow(Icons.badge_outlined, 'english_name'.tr, user.employeeNameEnglish ?? ''),
                        _buildInfoRow(Icons.translate_outlined, 'arabic_name'.tr, user.employeeNameArabic ?? ''),
                        _buildInfoRow(Icons.corporate_fare_outlined, 'department'.tr, user.departmentName ?? ''),
                        _buildInfoRow(Icons.assignment_ind_outlined, 'designation'.tr, user.designationName ?? ''),
                        _buildInfoRow(Icons.event_available_outlined, 'days_since_last_vacation'.tr, '${user.daysSinceLastVacation ?? 0} ${'days'.tr}'),
                        _buildInfoRow(Icons.calendar_month_outlined, 'resumption_date'.tr, user.resumptionDate != null ? DateFormat('yyyy-MM-dd').format(user.resumptionDate!) : '-'),
                        _buildInfoRow(Icons.flag_outlined, 'nationality'.tr, user.nationality?.isNotEmpty == true ? user.nationality! : (user.isSaudiNational == true ? 'Saudi' : '')),
                        _buildInfoRow(Icons.phone_iphone_outlined, 'mobile_number'.tr, user.mobileNo ?? ''),
                        _buildInfoRow(Icons.alternate_email_outlined, 'email_address'.tr, user.email ?? '', showDivider: false),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 3. System & Device Metadata Card
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'device_and_system_security'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                        _buildInfoRow(Icons.info_outline_rounded, 'app_version'.tr, controller.appVersion.value),
                        _buildInfoRow(Icons.phonelink_setup_outlined, 'current_device'.tr, controller.deviceInfo.value),
                        _buildInfoRow(Icons.login_outlined, 'last_system_login'.tr, controller.lastLoginFormatted.value, showDivider: false),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Language Settings Card
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'language'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.language, size: 24.sp, color: AppTheme.primaryColor),
                          title: Text('select_language'.tr, style: TextStyle(fontSize: 14.sp)),
                          trailing: DropdownButton<String>(
                            value: Get.locale?.languageCode ?? 'en',
                            underline: const SizedBox(),
                            items: [
                              DropdownMenuItem(value: 'en', child: Text('english'.tr)),
                              DropdownMenuItem(value: 'ar', child: Text('arabic'.tr)),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.changeLanguage(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // 4. Action Buttons Footer
                ElevatedButton.icon(
                  onPressed: controller.isRefreshing.value
                      ? null
                      : () => controller.refreshProfileData(),
                  icon: controller.isRefreshing.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text('refresh_cache'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                OutlinedButton.icon(
                  onPressed: () => _showChangePasswordBottomSheet(context),
                  icon: const Icon(Icons.password_outlined),
                  label: Text('change_password'.tr),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                ElevatedButton.icon(
                  onPressed: () => controller.logout(),
                  icon: const Icon(Icons.logout),
                  label: Text('logout'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isCurrentObscure = true.obs;
    final isNewObscure = true.obs;
    final isConfirmObscure = true.obs;
    final errorMessage = ''.obs;

    Get.bottomSheet(
      Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(),
                SizedBox(height: 12.h),

                // Current Password Field
                Obx(() => TextField(
                  controller: currentPasswordController,
                  obscureText: isCurrentObscure.value,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isCurrentObscure.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => isCurrentObscure.toggle(),
                    ),
                  ),
                )),
                SizedBox(height: 16.h),

                // New Password Field
                Obx(() => TextField(
                  controller: newPasswordController,
                  obscureText: isNewObscure.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isNewObscure.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => isNewObscure.toggle(),
                    ),
                  ),
                )),
                SizedBox(height: 16.h),

                // Confirm New Password Field
                Obx(() => TextField(
                  controller: confirmPasswordController,
                  obscureText: isConfirmObscure.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmObscure.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => isConfirmObscure.toggle(),
                    ),
                  ),
                )),
                SizedBox(height: 16.h),

                // Error Message Display
                Obx(() {
                  if (errorMessage.value.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      errorMessage.value,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
                SizedBox(height: 8.h),

                // Submit Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isChangingPassword.value
                      ? null
                      : () async {
                          errorMessage.value = '';
                          final error = await controller.changePassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                            confirmNewPassword: confirmPasswordController.text,
                          );
                          if (error == null) {
                            Get.back(); // Close bottom sheet
                          } else {
                            errorMessage.value = error;
                          }
                        },
                  child: controller.isChangingPassword.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Update Password'),
                )),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
