import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/module_navigation_service.dart';
import '../../../data/models/module.dart';
import '../controllers/modules_controller.dart';
import '../controllers/home_controller.dart';

class ModulesTabView extends GetView<ModulesController> {
  const ModulesTabView({super.key});

  IconData _resolveModuleIcon(String? iconName) {
    if (iconName == null) return Icons.folder_open_outlined;
    switch (iconName.toLowerCase()) {
      case 'customers':
      case 'customer':
        return Icons.corporate_fare_outlined;
      case 'receipts':
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'payments':
      case 'payment':
        return Icons.monetization_on_outlined;
      case 'employees':
      case 'employee':
        return Icons.badge_outlined;
      case 'leaves':
      case 'leave':
        return Icons.calendar_today_outlined;
      case 'users':
      case 'user':
        return Icons.manage_accounts_outlined;
      case 'roles':
      case 'role':
        return Icons.security_outlined;
      case 'permissions':
      case 'permission':
        return Icons.key_outlined;
      default:
        return Icons.arrow_circle_right_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    Get.find<ModulesController>();
    final navService = Get.find<ModuleNavigationService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('erp_modules'.tr),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async {
            if (Get.isRegistered<HomeController>()) {
              await Get.find<HomeController>().refreshDashboard();
            }
            controller.loadModules();
          },
          child: Obx(() {
            final categories = controller.groupedModules;
            // Access expandedIndex here to register it as a dependency of Obx
            final _ = controller.expandedIndex.value;

          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 64.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'no_modules_available'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'no_assigned_modules'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: categories.length,
            itemBuilder: (context, catIndex) {
              final entry = categories[catIndex];
              final categoryName = entry.key;
              final modulesList = entry.value;

              return Card(
                elevation: 0.5,
                margin: EdgeInsets.only(bottom: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: Key('${categoryName}_${controller.expandedIndex.value == catIndex}'),
                    initiallyExpanded: controller.expandedIndex.value == catIndex,
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                        controller.expandedIndex.value = catIndex;
                      } else if (controller.expandedIndex.value == catIndex) {
                        controller.expandedIndex.value = -1;
                      }
                    },
                    title: Text(
                      categoryName.toLowerCase().replaceAll(' ', '_').tr == categoryName.toLowerCase().replaceAll(' ', '_')
                          ? categoryName
                          : categoryName.toLowerCase().replaceAll(' ', '_').tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    leading: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primaryColor,
                      size: 22.sp,
                    ),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    children: [
                      Container(
                        color: Colors.grey.shade50,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: modulesList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                            indent: 56.w,
                          ),
                          itemBuilder: (context, modIndex) {
                            final module = modulesList[modIndex];
                            final nameKey = module.moduleName.toLowerCase().replaceAll(' ', '_');
                            final codeKey = module.moduleCode.toLowerCase().replaceAll('mod_', '').replaceAll(' ', '_');
                            final String displayTitle = nameKey.tr != nameKey
                                ? nameKey.tr
                                : (codeKey.tr != codeKey ? codeKey.tr : module.moduleName);

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                              leading: Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  _resolveModuleIcon(module.moduleCode),
                                  color: AppTheme.primaryColor,
                                  size: 18.sp,
                                ),
                              ),
                              title: Text(
                                displayTitle,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              subtitle: Text(
                                "${'code'.tr}: ${module.moduleCode}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14.sp,
                                color: Colors.grey.shade400,
                              ),
                              onTap: () => navService.navigateToModule(
                                module.moduleCode,
                                routeName: module.routeName,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    ),
  );
}
}
