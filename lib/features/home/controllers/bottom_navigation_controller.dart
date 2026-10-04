import 'package:get/get.dart';
import 'profile_controller.dart';
import 'home_controller.dart';

class BottomNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map && Get.arguments['tabIndex'] != null) {
      try {
        currentIndex.value = int.parse(Get.arguments['tabIndex'].toString());
      } catch (_) {}
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    // When user taps Profile tab (index 3), force fetch fresh profile data from server
    if (index == 3) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshProfileData();
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().silentAutoSync();
      }
    }
  }
}
