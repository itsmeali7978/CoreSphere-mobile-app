import 'package:get/get.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_receipt_repository.dart';
import '../controllers/create_receipt_controller.dart';
import '../controllers/receipt_details_controller.dart';
import '../controllers/receipt_history_controller.dart';
import '../controllers/receipt_preview_controller.dart';

class PaymentReceiptsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(() => CustomerRepository());
    }
    if (!Get.isRegistered<PaymentReceiptRepository>()) {
      Get.lazyPut<PaymentReceiptRepository>(() => PaymentReceiptRepository());
    }

    Get.lazyPut<ReceiptHistoryController>(() => ReceiptHistoryController());
    Get.lazyPut<CreateReceiptController>(() => CreateReceiptController());
    Get.lazyPut<ReceiptDetailsController>(() => ReceiptDetailsController());
    Get.lazyPut<ReceiptPreviewController>(() => ReceiptPreviewController());
  }
}
