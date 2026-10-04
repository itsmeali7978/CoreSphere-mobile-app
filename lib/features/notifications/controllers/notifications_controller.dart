import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../home/controllers/home_controller.dart';

class NotificationsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AppLogger _logger = Get.find<AppLogger>();
  final NetworkService _networkService = Get.find<NetworkService>();

  final RxList<dynamic> notifications = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (!_networkService.isOnline.value) return;
    
    isLoading.value = true;
    try {
      final response = await _apiClient.get('/Notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        notifications.assignAll(response.data['data'] ?? []);
        _updateHomeBadge();
      }
    } catch (e) {
      _logger.error("Error fetching notifications", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiClient.post('/Notifications/mark-read/$id', data: {});
      if (response.statusCode == 200) {
        final index = notifications.indexWhere((n) => n['notificationId'] == id);
        if (index != -1) {
          final updated = Map<String, dynamic>.from(notifications[index]);
          updated['isRead'] = true;
          notifications[index] = updated;
          _updateHomeBadge();
        }
      }
    } catch (e) {
      _logger.error("Error marking notification as read", e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.post('/Notifications/mark-all-read', data: {});
      if (response.statusCode == 200) {
        for (int i = 0; i < notifications.length; i++) {
          final updated = Map<String, dynamic>.from(notifications[i]);
          updated['isRead'] = true;
          notifications[i] = updated;
        }
        _updateHomeBadge();
      }
    } catch (e) {
      _logger.error("Error marking all notifications as read", e.toString());
    }
  }

  void _updateHomeBadge() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.unreadNotificationCount.value = notifications.where((n) => n['isRead'] == false).length;
    }
  }
}
