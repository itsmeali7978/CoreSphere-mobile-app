import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Logo Section
                      Column(
                        children: [
                          SizedBox(height: 48.h),
                          // Premium Logo Container
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.blur_on_rounded,
                                    size: 48.sp,
                                    color: AppTheme.primaryColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Company/App Title
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Please sign in to your enterprise account',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      // Input Fields & Credentials Section
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 36.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username field
                            Obx(() => TextField(
                              controller: controller.usernameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              enabled: !controller.isLoading.value,
                              decoration: InputDecoration(
                                labelText: 'username'.tr,
                                hintText: 'username'.tr,
                                errorText: controller.usernameError.value,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            )),
                            SizedBox(height: 20.h),

                            // Password field
                            Obx(() => TextField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible.value,
                              textInputAction: TextInputAction.done,
                              enabled: !controller.isLoading.value,
                              onSubmitted: (_) => controller.login(),
                              decoration: InputDecoration(
                                labelText: 'password'.tr,
                                hintText: 'password'.tr,
                                errorText: controller.passwordError.value,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            )),
                            SizedBox(height: 32.h),

                            // Login Button
                            Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.login(),
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'login'.tr,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            )),
                          ],
                        ),
                      ),

                      // Version Indicator & Footer
                      Column(
                        children: [
                          Text(
                            'CoreSphere Secure Login',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
