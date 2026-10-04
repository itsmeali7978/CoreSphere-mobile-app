class AppConstants {
  static const String appName = 'CoreSphere ERP';
}

class StorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String userId = 'user_id';
  static const String employeeCode = 'employee_code';
  
  // Local storage keys (shared_prefs)
  static const String userProfile = 'pref_user_profile';
  static const String dashboardCards = 'pref_dashboard_cards';
  static const String modules = 'pref_modules';
  static const String permissions = 'pref_permissions';
  static const String appConfig = 'pref_app_config';
  static const String language = 'pref_language';
}

class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String initialize = '/initialize';
  static const String home = '/home';
  static const String customers = '/customers';
  static const String customerDetails = '/customers/details';
  static const String customerForm = '/customers/form';
  static const String employees = '/employees';
  static const String employeeDetails = '/employees/details';
  static const String paymentReceipts = '/payment-receipts';
  static const String paymentReceiptCreate = '/payment-receipts/create';
  static const String paymentReceiptDetails = '/payment-receipts/details';
  static const String paymentReceiptPreview = '/payment-receipts/preview';
  static const String customerAgingBucket = '/customers/aging-bucket';
  static const String collections = '/collections';
  static const String myRequests = '/hr/my-requests';
  static const String pendingApprovals = '/hr/pending-approvals';
  static const String createRequest = '/hr/create-request';
  static const String requestDetails = '/hr/request-details';
  static const String requestPreview = '/hr/request-preview';
  static const String notifications = '/notifications';
}
