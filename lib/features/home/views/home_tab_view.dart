import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/dashboard_card.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_cards.dart';
import '../../../core/constants/app_constants.dart';

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  IconData _resolveIcon(String? iconName) {
    if (iconName == null) return Icons.dashboard_customize_outlined;

    switch (iconName.toLowerCase()) {
      case 'assessment':
      case 'chart':
        return Icons.insert_chart_outlined_rounded;
      case 'people':
      case 'employees':
        return Icons.people_outline_rounded;
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'payment':
      case 'payments':
        return Icons.payment_outlined;
      case 'security':
      case 'lock':
        return Icons.security_outlined;
      case 'settings':
      case 'config':
        return Icons.settings_outlined;
      case 'assignment':
      case 'task':
        return Icons.assignment_outlined;
      case 'notification':
      case 'bell':
        return Icons.notifications_none_rounded;
      default:
        return Icons.widgets_outlined;
    }
  }

  Color _resolveColor(String? colorName) {
    if (colorName == null) return AppTheme.primaryColor;

    if (colorName.startsWith('#')) {
      try {
        final hex = colorName.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        return AppTheme.primaryColor;
      }
    }

    switch (colorName.toLowerCase()) {
      case 'blue':
        return const Color(0xFF0052CC);
      case 'green':
        return const Color(0xFF36B37E);
      case 'orange':
      case 'warning':
        return const Color(0xFFFFAB00);
      case 'red':
      case 'error':
        return const Color(0xFFFF5630);
      case 'purple':
        return const Color(0xFF6554C0);
      case 'teal':
        return const Color(0xFF00B8D9);
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildCardWidget(DashboardCard card) {
    final double cardHeight = _resolveHeight(card.cardHeight);

    if (card.cardCode.toUpperCase() == 'RCNT_PYMNTS') {
      return RecentPaymentsCard(
        card: card,
        height: cardHeight,
      );
    }

    switch (card.cardType.toUpperCase()) {
      case 'AGING':
        return AgingCard(
          card: card,
          height: cardHeight,
        );

      case 'LIST':
        return ListCard(
          card: card,
          height: cardHeight,
        );

      case 'CHART':
        return ChartCard(
          card: card,
          height: cardHeight,
        );

      case 'PROGRESS':
        return ProgressCard(
          card: card,
          height: cardHeight,
        );

      case 'ANNOUNCEMENT':
        return AnnouncementCard(
          card: card,
          height: cardHeight,
        );

      case 'QUICK_ACTION':
        return QuickActionCard(
          card: card,
          height: cardHeight,
        );

      case 'METRIC':
      default:
        return MetricCard(
          card: card,
          height: cardHeight,
        );
    }
  }

  double _resolveHeight(String heightType) {
    final isTablet = Get.context != null &&
        MediaQuery.of(Get.context!).size.shortestSide >= 600;

    switch (heightType.toUpperCase()) {
      case 'MEDIUM':
        return isTablet ? 220.h : 200.h;

      case 'LARGE':
        return isTablet ? 320.h : 300.h;

      case 'SMALL':
      default:
        return isTablet ? 180.h : 145.h;
    }
  }

  List<Widget> _buildDashboardRows(List<DashboardCard> cards) {
    final List<Widget> rows = [];
    int i = 0;

    while (i < cards.length) {
      final card = cards[i];

      if (card.cardWidth.toUpperCase() == 'FULL') {
        rows.add(_buildCardWidget(card));
        i++;
      } else {
        // It is HALF. Check if there is another HALF card next.
        if (i + 1 < cards.length &&
            cards[i + 1].cardWidth.toUpperCase() == 'HALF') {
          rows.add(
            Row(
              children: [
                Expanded(
                  child: _buildCardWidget(card),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildCardWidget(cards[i + 1]),
                ),
              ],
            ),
          );

          i += 2;
        } else {
          // Only one HALF card left
          rows.add(
            Row(
              children: [
                Expanded(
                  child: _buildCardWidget(card),
                ),
                SizedBox(width: 16.w),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          );

          i++;
        }
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is instantiated
    Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.refreshDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Welcome Banner Header Section
              SliverToBoxAdapter(
                child: Obx(() {
                  final user = controller.currentUser.value;

                  if (user == null) {
                    return const SizedBox.shrink();
                  }

                  // Get initials for profile picture fallback
                  final String initials = user.userName.trim().isNotEmpty
                      ? user.userName.substring(0, 2).toUpperCase()
                      : "U";

                  final String formattedDate =
                      DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

                  // Calculate time-based greeting
                  final hour = DateTime.now().hour;
                  final String greeting;

                  if (hour >= 5 && hour < 12) {
                    greeting = "Good Morning,";
                  } else if (hour >= 12 && hour < 17) {
                    greeting = "Good Afternoon,";
                  } else {
                    greeting = "Good Evening,";
                  }

                  return Container(
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      24.h,
                      24.w,
                      20.h,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Date Display
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Welcome & Avatar Block
                        Row(
                          children: [
                            // Initials Avatar with brand style
                            Container(
                              width: 54.w,
                              height: 54.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    Color(0xFF0073E6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: user.profileImageUrl != null &&
                                        user.profileImageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: user.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              fontSize: 18.sp,
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
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(width: 16.w),

                            // User Profile texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),

                                  SizedBox(height: 2.h),

                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      user.employeeNameEnglish ?? user.userName,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryColor,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),

                                  SizedBox(height: 4.h),

                                  Text(
                                    "${user.designationName ?? 'Staff'} • ${user.departmentName ?? 'General'}",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Notification Bell
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteNames.notifications);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: AppTheme.primaryColor,
                                      size: 24.sp,
                                    ),
                                  ),

                                  Obx(() {
                                    if (controller
                                            .unreadNotificationCount.value >
                                        0) {
                                      return Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            controller.unreadNotificationCount
                                                        .value >
                                                    99
                                                ? "99+"
                                                : controller
                                                    .unreadNotificationCount
                                                    .value
                                                    .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Micro Metadata Card row
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ID: ${user.employeeCode}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Role: ${user.roleName ?? 'None'}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Title Header
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  24.h,
                  24.w,
                  12.h,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'home'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ),

              // Dashboard Grid
              Obx(() {
                final cards = controller.dashboardCards;

                if (cards.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard_outlined,
                              size: 48.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'no_data'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final rows = _buildDashboardRows(cards);

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: rows[index],
                        );
                      },
                      childCount: rows.length,
                    ),
                  ),
                );
              }),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 24.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}