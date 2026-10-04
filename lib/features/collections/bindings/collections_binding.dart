import 'package:get/get.dart';
import '../../../data/repositories/payment_receipt_repository.dart';
import '../controllers/collections_controller.dart';

class CollectionsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PaymentReceiptRepository>()) {
      Get.lazyPut<PaymentReceiptRepository>(() => PaymentReceiptRepository());
    }
    Get.lazyPut<CollectionsController>(() => CollectionsController());
  }
}
