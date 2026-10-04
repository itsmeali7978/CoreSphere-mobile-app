import 'package:get/get.dart';
import '../../../data/repositories/customer_repository.dart';
import '../controllers/customers_controller.dart';
import '../controllers/customer_details_controller.dart';
import '../controllers/customer_form_controller.dart';
import '../controllers/customer_aging_bucket_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<CustomerRepository>(() => CustomerRepository(), fenix: true);

    // Controllers
    Get.lazyPut<CustomersController>(() => CustomersController(), fenix: true);
    Get.lazyPut<CustomerDetailsController>(() => CustomerDetailsController(), fenix: true);
    Get.lazyPut<CustomerFormController>(() => CustomerFormController(), fenix: true);
    Get.lazyPut<CustomerAgingBucketController>(() => CustomerAgingBucketController(), fenix: true);
  }
}
