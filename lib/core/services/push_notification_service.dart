import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../routes/app_pages.dart';
import 'logger_service.dart';
import 'permission_service.dart';
import 'prefs_service.dart';
import '../../data/repositories/authentication_repository.dart';
import '../../features/authentication/controllers/authentication_controller.dart';
import '../../features/home/controllers/bottom_navigation_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/hr/controllers/pending_approvals_controller.dart';
import '../../features/hr/controllers/my_requests_controller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background processing here
  print("Handling a background message: ${message.messageId}");
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AppLogger _logger = Get.find<AppLogger>();

  String? fcmToken;

  Future<PushNotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _setupFCM();

    return this;
  }

  Future<void> _setupFCM() async {
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      fcmToken = await _fcm.getToken();
      _logger.info("FCM Token: $fcmToken");

      if (fcmToken != null) {
        await registerCurrentToken();
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        fcmToken = newToken;
        _logger.info("FCM Token Refreshed: $newToken");
        await registerCurrentToken();
      });

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'coresphere_main_channel',
        'CoreSphere Notifications',
        description: 'High importance notifications for CoreSphere requests and approvals',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }

      const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );
      
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              _handleNotificationTap(jsonDecode(response.payload!));
            } catch (_) {
              _handleNotificationTap({});
            }
          } else {
            _handleNotificationTap({});
          }
        },
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.info("Got a message whilst in the foreground!");
        final title = (message.notification?.title ?? message.data['title'] ?? 'New Notification').toString();
        final body = (message.notification?.body ?? message.data['body'] ?? 'You have a new request update.').toString();

        displayBannerAndAlert(
          title: title,
          body: body,
          data: message.data,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.info("A new onMessageOpenedApp event was published!");
        _handleNotificationTap(message.data);
      });

      // Handle terminated state launch by tapping a notification
      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _logger.info("App opened from terminated state via notification!");
        Future.delayed(const Duration(milliseconds: 1000), () {
          _handleNotificationTap(initialMessage.data);
        });
      }
    } catch (e) {
      _logger.error("Error setting up FCM: $e");
    }
  }

  final Set<int> _shownNotificationIds = {};

  void displayBannerAndAlert({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int? notificationId,
  }) {
    if (notificationId != null) {
      if (_shownNotificationIds.contains(notificationId)) return;
      _shownNotificationIds.add(notificationId);
    }

    final payloadData = data ?? {};

    // 1. Show Popdown Heads-up Local Notification Banner
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'coresphere_main_channel',
      'CoreSphere Notifications',
      channelDescription: 'High importance notifications for CoreSphere requests and approvals',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _localNotifications.show(
      id: notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: jsonEncode(payloadData),
    );

    // 2. Show In-App Snackbar Banner Alert
    try {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        backgroundColor: const Color(0xFF1E293B).withOpacity(0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.notifications_active, color: Color(0xFF38BDF8)),
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.back();
            _handleNotificationTap(payloadData);
          },
          child: const Text(
            'VIEW',
            style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      _logger.error("Error displaying foreground in-app alert", e.toString());
    }

    // 3. Live refresh active controllers in background
    _autoRefreshActiveControllers();
  }

  void _autoRefreshActiveControllers() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchUnreadNotificationCount();
      }
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().fetchNotifications();
      }
      if (Get.isRegistered<PendingApprovalsController>()) {
        Get.find<PendingApprovalsController>().fetchPendingApprovals();
      }
      if (Get.isRegistered<MyRequestsController>()) {
        Get.find<MyRequestsController>().fetchRequests();
      }
    } catch (_) {}
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    try {
      _logger.info("Notification tapped with payload: $data");
      
      // Delay slightly to ensure GetX navigation stack & user session are ready
      Future.delayed(const Duration(milliseconds: 300), () {
        _executeRedirection(data);
      });
    } catch (e, stack) {
      _logger.error("Error handling notification tap redirection", e.toString(), stack);
    }
  }

  void _executeRedirection(Map<String, dynamic> data) {
    try {
      // 1. Verify user authentication status
      final authController = Get.isRegistered<AuthenticationController>() ? Get.find<AuthenticationController>() : null;
      if (authController != null && !authController.isLoggedIn.value) {
        _logger.warning("User is not logged in. Redirecting to Login...");
        Get.offAllNamed(RouteNames.login);
        return;
      }

      // 2. Determine if user has approval rights (Manager / HR / Admin / Approver)
      bool isApproverUser = false;

      final prefsService = Get.isRegistered<PrefsService>() ? Get.find<PrefsService>() : null;
      final initData = prefsService?.getAppInitializationData();
      final user = initData?.user;

      if (user != null) {
        final roleName = user.roleName?.toLowerCase() ?? '';
        final roleId = user.roleId;
        final username = user.userName.toLowerCase();

        if (roleId == 1 ||
            roleName == 'admin' ||
            username == 'admin' ||
            roleName.contains('manager') ||
            roleName.contains('hr') ||
            roleName.contains('approver')) {
          isApproverUser = true;
        }
      }

      if (!isApproverUser && Get.isRegistered<PermissionService>()) {
        final permService = Get.find<PermissionService>();
        isApproverUser = permService.canApprove('LEAVES') ||
            permService.canApprove('HR') ||
            permService.canApprove('APPROVALS') ||
            permService.canViewModule('MOD_PENDING_APPROVALS') ||
            permService.canViewModule('APPROVALS');
      }

      final String notificationType = (data['type'] ?? data['Type'] ?? '').toString().toUpperCase();

      bool shouldGoToApprovals = false;

      if (notificationType == 'APPROVAL_REQUEST') {
        // Someone submitted a request pending approval -> Route Approvers to Approvals Tab
        shouldGoToApprovals = true;
      } else if (notificationType.startsWith('APPROVAL_') || notificationType.contains('APPROVED') || notificationType.contains('REJECTED')) {
        // Update on user's own submitted request (Accepted/Rejected/Progressed) -> Route to My Requests
        shouldGoToApprovals = false;
      } else if (isApproverUser) {
        shouldGoToApprovals = true;
      }

      if (shouldGoToApprovals) {
        _logger.info("Redirecting to Approvals Tab & refreshing...");
        
        // 1. Mount HomeView with tabIndex 2
        Get.offAllNamed(RouteNames.home, arguments: {'tabIndex': 2});

        // 2. Safely switch tab & trigger refresh after HomeView initializes
        Future.delayed(const Duration(milliseconds: 400), () {
          if (Get.isRegistered<BottomNavigationController>()) {
            Get.find<BottomNavigationController>().changeIndex(2);
          }
          final pendingController = Get.isRegistered<PendingApprovalsController>()
              ? Get.find<PendingApprovalsController>()
              : Get.put(PendingApprovalsController());
          pendingController.fetchPendingApprovals();
        });
      } else {
        _logger.info("Redirecting to My Requests Page & refreshing...");
        
        // 1. Mount HomeView first
        Get.offAllNamed(RouteNames.home);

        // 2. Wait for HomeView to finish mounting, then navigate to My Requests
        Future.delayed(const Duration(milliseconds: 400), () {
          Get.toNamed(RouteNames.myRequests);

          Future.delayed(const Duration(milliseconds: 300), () {
            final myRequestsController = Get.isRegistered<MyRequestsController>()
                ? Get.find<MyRequestsController>()
                : Get.put(MyRequestsController());
            myRequestsController.fetchRequests();
          });
        });
      }
    } catch (e, stack) {
      _logger.error("Error executing redirection after notification tap", e.toString(), stack);
    }
  }

  Future<void> registerCurrentToken() async {
    try {
      fcmToken ??= await _fcm.getToken();
      if (fcmToken != null && Get.isRegistered<AuthenticationRepository>()) {
        await Get.find<AuthenticationRepository>().registerDevice(fcmToken!);
        _logger.info("FCM Device registered successfully with backend API.");
      }
    } catch (e) {
      _logger.error("Failed to register current FCM token: $e");
    }
  }
}
