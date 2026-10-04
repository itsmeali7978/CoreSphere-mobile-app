import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/user.dart';
import '../../../data/models/dashboard_card.dart';
import '../../../data/repositories/authentication_repository.dart';
import '../../authentication/controllers/authentication_controller.dart';
import 'modules_controller.dart';
import '../../../core/services/push_notification_service.dart';

import '../../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();
  final AppLogger _logger = Get.find<AppLogger>();

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<DashboardCard> dashboardCards = <DashboardCard>[].obs;
  final RxInt unreadNotificationCount = 0.obs;
  final RxBool isLoading = false.obs;

  Timer? _autoSyncTimer;

  void onInit() {
    super.onInit();
    loadCachedData();
    fetchUnreadNotificationCount();
    // Start silent background auto-sync timer (fetches backend changes every 30 seconds)
    _startSilentAutoSyncTimer();
  }

  @override
  void onClose() {
    _autoSyncTimer?.cancel();
    super.onClose();
  }

  static List<DashboardCard> _getDefaultDashboardCards() {
    return [
      DashboardCard(
        dashboardCardId: 1,
        cardCode: 'AGE_AMNT',
        cardTitle: 'due_amount'.tr,
        cardDescription: 'Customer aging balances summary',
        iconName: 'money',
        iconColor: '#FF9800',
        displayOrder: 1,
        cardType: 'AGING',
        cardWidth: 'FULL',
        cardHeight: 'MEDIUM',
        dataEndpoint: '/api/customer-aging/dashboard-summary',
        allowRefresh: true,
      ),
      DashboardCard(
        dashboardCardId: 2,
        cardCode: 'RCNT_PYMNTS',
        cardTitle: 'recent_payments'.tr,
        cardDescription: 'Recent customer payment receipt logs',
        iconName: 'receipt',
        iconColor: '#0B192C',
        displayOrder: 2,
        cardType: 'LIST',
        cardWidth: 'FULL',
        cardHeight: 'LARGE',
        dataEndpoint: '/api/customerpaymentreceipts',
        maxItems: 10,
        allowRefresh: true,
      ),
      DashboardCard(
        dashboardCardId: 3,
        cardCode: 'TOTAL_CUSTOMERS',
        cardTitle: 'total_customers'.tr,
        cardDescription: 'Total customer accounts registered',
        iconName: 'customers',
        iconColor: '#2EC4B6',
        displayOrder: 3,
        cardType: 'METRIC',
        cardWidth: 'HALF',
        cardHeight: 'SMALL',
        dataEndpoint: '/api/dashboard/stats',
        allowRefresh: true,
      ),
      DashboardCard(
        dashboardCardId: 4,
        cardCode: 'TOTAL_EMPLOYEES',
        cardTitle: 'total_employees'.tr,
        cardDescription: 'Total employees registered',
        iconName: 'employees',
        iconColor: '#0B192C',
        displayOrder: 4,
        cardType: 'METRIC',
        cardWidth: 'HALF',
        cardHeight: 'SMALL',
        dataEndpoint: '/api/dashboard/stats',
        allowRefresh: true,
      ),
      DashboardCard(
        dashboardCardId: 5,
        cardCode: 'FAILED_ERP_SYNC',
        cardTitle: 'failed_erp_syncs'.tr,
        cardDescription: 'Sync error count',
        iconName: 'sync_problem',
        iconColor: '#FF5630',
        displayOrder: 5,
        cardType: 'METRIC',
        cardWidth: 'HALF',
        cardHeight: 'SMALL',
        dataEndpoint: '/api/dashboard/stats',
        allowRefresh: true,
      ),
      DashboardCard(
        dashboardCardId: 6,
        cardCode: 'ANCMNT_CRD',
        cardTitle: 'anouncements'.tr,
        cardDescription: 'System updates and announcements',
        iconName: 'campaign',
        iconColor: '#6554C0',
        displayOrder: 6,
        cardType: 'ANNOUNCEMENT',
        cardWidth: 'FULL',
        cardHeight: 'MEDIUM',
        allowRefresh: true,
      ),
    ];
  }

  void loadCachedData() {
    try {
      final cache = _prefsService.getAppInitializationData();
      if (cache != null) {
        currentUser.value = cache.user;
        if (cache.dashboardCards != null && cache.dashboardCards!.isNotEmpty) {
          dashboardCards.value = cache.dashboardCards!;
        } else {
          dashboardCards.value = _getDefaultDashboardCards();
        }
      } else {
        dashboardCards.value = _getDefaultDashboardCards();
      }
      _logger.debug("HomeController successfully loaded dashboard cards: ${dashboardCards.length}");
    } catch (e, stack) {
      _logger.error("Failed to load cached dashboard data", e.toString(), stack);
      dashboardCards.value = _getDefaultDashboardCards();
    }
  }

  void _startSilentAutoSyncTimer() {
    // Perform initial silent sync after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      silentAutoSync();
      fetchUnreadNotificationCount();
    });

    // Periodic silent sync and notification count check every 10 seconds
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      silentAutoSync();
      fetchUnreadNotificationCount();
    });
  }

  /// Silently fetches the latest application context, user profile, modules, and permissions in the background without UI disruption.
  Future<void> silentAutoSync() async {
    if (!_networkService.isOnline.value) return;

    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final result = await _authRepository.refresh();
      if (result.success && result.data != null) {
        final refreshResponse = result.data!;
        
        // 1. Update local cache
        await _prefsService.saveAppInitializationData(refreshResponse);
        
        // 2. Update reactive values
        if (refreshResponse.user != null) {
          currentUser.value = refreshResponse.user;
        }
        if (refreshResponse.dashboardCards != null && refreshResponse.dashboardCards!.isNotEmpty) {
          dashboardCards.value = refreshResponse.dashboardCards!;
        }

        // 3. Update global authentication session
        if (refreshResponse.user != null) {
          Get.find<AuthenticationController>().updateCurrentUser(refreshResponse.user!);
        }

        // 4. Update Modules tab dynamically if registered
        if (Get.isRegistered<ModulesController>()) {
          Get.find<ModulesController>().loadModules();
        }

        _logger.debug("Silent background auto-sync completed successfully.");
      }
    } catch (e) {
      // Fail silently without disrupting user experience
      _logger.warning("Silent auto-sync skipped/failed: $e");
    }
  }

  Future<void> refreshDashboard() async {
    if (isLoading.value) return;

    // 1. Check Internet Connectivity
    if (!_networkService.isOnline.value) {
      _logger.warning("Pull-to-refresh failed: Offline mode.");
      _showToast('Offline: No internet connection. Displaying cached data.', Colors.orangeAccent);
      return;
    }

    isLoading.value = true;
    _logger.info("Executing manual refresh app context update...");

    try {
      await silentAutoSync();
      _showToast('Dashboard updated successfully.', Colors.green);
    } catch (e, stack) {
      _logger.error("Exception during manual refresh", e.toString(), stack);
      _showToast('An error occurred during update. Please try again.', Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }

  Future<void> fetchUnreadNotificationCount() async {
    if (!_networkService.isOnline.value) return;
    try {
      final response = await Get.find<ApiClient>().get('/Notifications/unread-count');
      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final int newCount = response.data['data'] ?? 0;
          if (newCount > unreadNotificationCount.value) {
            _checkAndShowNewNotificationAlert();
          }
          unreadNotificationCount.value = newCount;
        }
      }
    } catch (e) {
      _logger.error("Failed to fetch unread notification count", e.toString());
    }
  }

  Future<void> _checkAndShowNewNotificationAlert() async {
    try {
      final response = await Get.find<ApiClient>().get('/Notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List items = response.data['data'] ?? [];
        if (items.isNotEmpty) {
          final first = items.first;
          final bool isUnread = first['isRead'] == false;
          final int notificationId = first['notificationId'] ?? 0;
          final String title = (first['title'] ?? 'New Request to Approve').toString();
          final String message = (first['message'] ?? 'You have a new request pending approval.').toString();
          final String type = (first['type'] ?? 'APPROVAL_REQUEST').toString();
          final dynamic relatedId = first['relatedId'];

          if (isUnread && Get.isRegistered<PushNotificationService>()) {
            Get.find<PushNotificationService>().displayBannerAndAlert(
              title: title,
              body: message,
              notificationId: notificationId,
              data: {
                'title': title,
                'body': message,
                'type': type,
                'relatedId': relatedId?.toString() ?? '',
              },
            );
          }
        }
      }
    } catch (e) {
      _logger.error("Failed to fetch recent notifications for alert", e.toString());
    }
  }
}
