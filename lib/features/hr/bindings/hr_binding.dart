import 'package:get/get.dart';
import '../../../data/repositories/approval_repository.dart';
import '../controllers/my_requests_controller.dart';
import '../controllers/pending_approvals_controller.dart';
import '../controllers/create_request_controller.dart';
import '../controllers/request_details_controller.dart';

class HrBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApprovalRepository>()) {
      Get.lazyPut<ApprovalRepository>(() => ApprovalRepository());
    }

    // Register controllers based on the current route or lazy put all of them
    // It's safer to lazy put them if they are accessed from multiple places.
    // However, since we use Get.put() in the Views, lazyPut is better to provide the dependencies if needed.
    // Or we can just let Get.put() in the view handle it.
  }
}
