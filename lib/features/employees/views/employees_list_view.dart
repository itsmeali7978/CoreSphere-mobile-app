import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/employee.dart';
import '../controllers/employees_controller.dart';

class EmployeesListView extends GetView<EmployeesController> {
  const EmployeesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Employees Directory'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final int filterCount = controller.activeFiltersCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  tooltip: 'Filter Employees',
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (filterCount > 0)
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        '$filterCount',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. Permission Access Check
          if (!controller.canView.value) {
            return _buildAccessDeniedState();
          }

          return Column(
            children: [
              // Search & Filter Header
              _buildSearchHeader(context),

              // Active Filters Bar
              if (controller.hasActiveFilters) _buildActiveFilterChips(),

              // Content Body
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: () => controller.refreshEmployees(),
                  child: _buildContent(scrollController),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by Code, Name, Department...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () {
                          controller.searchQuery.value = '';
                          controller.loadEmployees(isRefresh: true);
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            final bool active = controller.hasActiveFilters;
            return Material(
              color: active ? AppTheme.primaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => _showFilterBottomSheet(context),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    Icons.tune_rounded,
                    color: active ? Colors.white : Colors.grey.shade700,
                    size: 22.sp,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 4.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Filters:',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          if (controller.statusFilter.value != 'All')
            Chip(
              label: Text('Status: ${controller.statusFilter.value}'),
              labelStyle: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
              backgroundColor: controller.statusFilter.value == 'Active' ? Colors.green.shade700 : Colors.red.shade700,
              deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
              onDeleted: () => controller.setStatusFilter('All'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          if (controller.nationalityFilter.value != 'All')
            Chip(
              label: Text('Nationality: ${controller.nationalityFilter.value}'),
              labelStyle: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
              backgroundColor: controller.nationalityFilter.value == 'Saudi' ? Colors.teal.shade700 : Colors.indigo.shade700,
              deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
              onDeleted: () => controller.setNationalityFilter('All'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          TextButton(
            onPressed: () => controller.resetFilters(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50.w, 24.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Clear All',
              style: TextStyle(fontSize: 11.sp, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Filter Employees',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 12.h),

              // 1. Account Status Filter
              Text(
                'Employment Status',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              SizedBox(height: 8.h),
              Obx(() => Wrap(
                    spacing: 8.w,
                    children: [
                      _buildChoiceChip(
                        label: 'All Statuses',
                        selected: controller.statusFilter.value == 'All',
                        onSelected: (_) => controller.setStatusFilter('All'),
                      ),
                      _buildChoiceChip(
                        label: 'Active Only',
                        selected: controller.statusFilter.value == 'Active',
                        activeColor: Colors.green.shade700,
                        onSelected: (_) => controller.setStatusFilter('Active'),
                      ),
                      _buildChoiceChip(
                        label: 'Inactive Only',
                        selected: controller.statusFilter.value == 'Inactive',
                        activeColor: Colors.red.shade700,
                        onSelected: (_) => controller.setStatusFilter('Inactive'),
                      ),
                    ],
                  )),
              SizedBox(height: 20.h),

              // 2. Nationality Filter (isSaudiNational)
              Text(
                'Nationality (Saudi National)',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              SizedBox(height: 8.h),
              Obx(() => Wrap(
                    spacing: 8.w,
                    children: [
                      _buildChoiceChip(
                        label: 'All Nationalities',
                        selected: controller.nationalityFilter.value == 'All',
                        onSelected: (_) => controller.setNationalityFilter('All'),
                      ),
                      _buildChoiceChip(
                        label: 'Saudi National 🇸🇦',
                        selected: controller.nationalityFilter.value == 'Saudi',
                        activeColor: Colors.teal.shade700,
                        onSelected: (_) => controller.setNationalityFilter('Saudi'),
                      ),
                      _buildChoiceChip(
                        label: 'Non-Saudi 🌐',
                        selected: controller.nationalityFilter.value == 'Non-Saudi',
                        activeColor: Colors.indigo.shade700,
                        onSelected: (_) => controller.setNationalityFilter('Non-Saudi'),
                      ),
                    ],
                  )),
              SizedBox(height: 24.h),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetFilters();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? activeColor,
  }) {
    final Color color = activeColor ?? AppTheme.primaryColor;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.sp,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (controller.hasError.value && controller.employees.isEmpty) {
      return _buildErrorState();
    }

    final displayList = controller.filteredEmployees;

    if (displayList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: displayList.length + (controller.isLoadMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayList.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final employee = displayList[index];
        return _buildEmployeeCard(employee);
      },
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final String displayName = employee.employeeNameEnglish?.isNotEmpty == true
        ? employee.employeeNameEnglish!
        : (employee.employeeNameArabic?.isNotEmpty == true ? employee.employeeNameArabic! : 'No Name');

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Get.toNamed(RouteNames.employeeDetails, arguments: employee);
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name & Status Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (employee.employeeNameArabic != null && employee.employeeNameArabic!.isNotEmpty)
                          Text(
                            employee.employeeNameArabic!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(employee.isActive),
                      SizedBox(height: 4.h),
                      _buildNationalityChip(employee.isSaudiNational),
                    ],
                  ),
                ],
              ),
              Divider(height: 20.h, color: Colors.grey.shade200),

              // Attributes Grid / Metadata
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      Icons.badge_outlined,
                      'Code',
                      employee.employeeCode,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      Icons.business_outlined,
                      'Department',
                      employee.departmentName ?? 'N/A',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      Icons.work_outline,
                      'Designation',
                      employee.designationName ?? 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      Icons.phone_outlined,
                      'Mobile',
                      employee.mobileNo ?? 'N/A',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      Icons.flag_outlined,
                      'Nationality',
                      employee.nationality?.isNotEmpty == true
                          ? employee.nationality!
                          : (employee.isSaudiNational ? 'Saudi' : 'N/A'),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey.shade500),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildNationalityChip(bool isSaudi) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isSaudi ? Colors.teal.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSaudi ? Colors.teal.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSaudi ? '🇸🇦 Saudi' : '🌐 Non-Saudi',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isSaudi ? Colors.teal.shade800 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDeniedState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64.sp, color: Colors.redAccent),
            SizedBox(height: 16.h),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            SizedBox(height: 8.h),
            Text(
              'You do not have permission to access the Employees module.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'No Employees Found',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try adjusting your search or filter criteria.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, size: 64.sp, color: Colors.red.shade400),
              SizedBox(height: 16.h),
              Text(
                'Failed to Load Employees',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 8.h),
              ElevatedButton.icon(
                onPressed: () => controller.loadEmployees(isRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
