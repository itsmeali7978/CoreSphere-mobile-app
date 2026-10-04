import 'package:get/get.dart';
import '../../features/authentication/bindings/authentication_binding.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/splash_view.dart';
import '../../features/home/views/initialize_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/customers/bindings/customer_binding.dart';
import '../../features/customers/views/customers_list_view.dart';
import '../../features/customers/views/customer_details_view.dart';
import '../../features/customers/views/customer_form_view.dart';
import '../../features/customers/views/customer_aging_bucket_view.dart';
import '../../features/employees/bindings/employees_binding.dart';
import '../../features/employees/bindings/employee_details_binding.dart';
import '../../features/employees/views/employees_list_view.dart';
import '../../features/employees/views/employee_details_view.dart';
import '../../features/payment_receipts/bindings/payment_receipts_binding.dart';
import '../../features/payment_receipts/views/create_receipt_view.dart';
import '../../features/payment_receipts/views/receipt_details_view.dart';
import '../../features/payment_receipts/views/receipt_history_view.dart';
import '../../features/payment_receipts/views/receipt_preview_view.dart';
import '../../features/collections/bindings/collections_binding.dart';
import '../../features/collections/views/collections_view.dart';
import '../../features/collections/views/collections_view.dart';
import '../../features/home/bindings/splash_binding.dart';
import '../../features/hr/views/my_requests_view.dart';
import '../../features/hr/views/pending_approvals_view.dart';
import '../../features/hr/views/create_request_view.dart';
import '../../features/hr/views/request_details_view.dart';
import '../../features/hr/views/request_preview_view.dart';
import '../../features/hr/bindings/hr_binding.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../constants/app_constants.dart';

class AppPages {
  static const initial = RouteNames.splash;

  static final routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: RouteNames.initialize,
      page: () => const InitializeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouteNames.customers,
      page: () => const CustomersListView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: RouteNames.customerDetails,
      page: () => const CustomerDetailsView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: RouteNames.customerForm,
      page: () => const CustomerFormView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: RouteNames.employees,
      page: () => const EmployeesListView(),
      binding: EmployeesBinding(),
    ),
    GetPage(
      name: RouteNames.employeeDetails,
      page: () => const EmployeeDetailsView(),
      binding: EmployeeDetailsBinding(),
    ),
    GetPage(
      name: RouteNames.paymentReceipts,
      page: () => const ReceiptHistoryView(),
      binding: PaymentReceiptsBinding(),
    ),
    GetPage(
      name: RouteNames.paymentReceiptCreate,
      page: () => const CreateReceiptView(),
      binding: PaymentReceiptsBinding(),
    ),
    GetPage(
      name: RouteNames.paymentReceiptDetails,
      page: () => const ReceiptDetailsView(),
      binding: PaymentReceiptsBinding(),
    ),
    GetPage(
      name: RouteNames.paymentReceiptPreview,
      page: () => const ReceiptPreviewView(),
      binding: PaymentReceiptsBinding(),
    ),
    GetPage(
      name: RouteNames.customerAgingBucket,
      page: () => const CustomerAgingBucketView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: RouteNames.collections,
      page: () => const CollectionsView(),
      binding: CollectionsBinding(),
    ),
    GetPage(
      name: RouteNames.myRequests,
      page: () => const MyRequestsView(),
      binding: HrBinding(),
    ),
    GetPage(
      name: RouteNames.pendingApprovals,
      page: () => const PendingApprovalsView(),
      binding: HrBinding(),
    ),
    GetPage(
      name: RouteNames.createRequest,
      page: () => const CreateRequestView(),
      binding: HrBinding(),
    ),
    GetPage(
      name: RouteNames.requestDetails,
      page: () => const RequestDetailsView(),
      binding: HrBinding(),
    ),
    GetPage(
      name: RouteNames.requestPreview,
      page: () => const RequestPreviewView(),
      binding: HrBinding(),
    ),
    GetPage(
      name: RouteNames.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}
