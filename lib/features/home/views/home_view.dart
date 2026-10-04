import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/bottom_navigation_controller.dart';
import 'home_tab_view.dart';
import 'modules_tab_view.dart';
import 'package:coresphere_mobile/features/hr/views/pending_approvals_view.dart';
import 'profile_tab_view.dart';

class HomeView extends GetView<BottomNavigationController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Widget> tabPages = [
      const HomeTabView(),
      const ModulesTabView(),
      const PendingApprovalsView(),
      const ProfileTabView(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: tabPages,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_outlined),
                activeIcon: const Icon(Icons.grid_view),
                label: 'modules'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.playlist_add_check_outlined),
                activeIcon: const Icon(Icons.playlist_add_check),
                label: 'approvals'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: 'profile'.tr,
              ),
            ],
          )),
    );
  }
}
