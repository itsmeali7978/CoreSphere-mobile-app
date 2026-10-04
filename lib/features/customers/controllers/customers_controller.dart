import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../home/controllers/home_controller.dart';

enum CustomerFilterMode { myCustomers, allCustomers }
enum CustomerSortMode { none, balanceAsc, balanceDesc }

class CustomersController extends GetxController {
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final AppLogger _logger = Get.find<AppLogger>();

  static const String _cacheKey = 'cached_customers_list';
  static const int _pageSize = 15;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;

  // Default filter mode is "My Customers"
  final Rx<CustomerFilterMode> filterMode = CustomerFilterMode.myCustomers.obs;

  // Default sort mode is "None"
  final Rx<CustomerSortMode> sortMode = CustomerSortMode.none.obs;

  List<Customer> get sortedCustomers {
    var list = List<Customer>.from(customers);
    if (sortMode.value == CustomerSortMode.balanceAsc) {
      list.sort((a, b) => (a.balance ?? 0.0).compareTo(b.balance ?? 0.0));
    } else if (sortMode.value == CustomerSortMode.balanceDesc) {
      list.sort((a, b) => (b.balance ?? 0.0).compareTo(a.balance ?? 0.0));
    }
    return list;
  }

  void setSortMode(CustomerSortMode mode) {
    if (sortMode.value == mode) return;
    sortMode.value = mode;
    loadCustomers(isRefresh: true);
  }

  int _currentPage = 1;
  bool _hasMore = true;

  // Enforced permission flags for UI visibility
  bool get canCreate => _permissionService.canCreate('CUSTOMERS');
  bool get canEdit => _permissionService.canEdit('CUSTOMERS');
  bool get canDelete => _permissionService.canDelete('CUSTOMERS');

  @override
  void onInit() {
    super.onInit();
    // Load cached records immediately for fast UI response
    _loadFromOfflineCache();
    loadCustomers(isRefresh: true);

    // Debounce search inputs to optimize API traffic
    debounce(searchQuery, (_) => loadCustomers(isRefresh: true),
        time: const Duration(milliseconds: 600));
  }

  void setFilterMode(CustomerFilterMode mode) {
    if (filterMode.value == mode) return;
    filterMode.value = mode;
    loadCustomers(isRefresh: true);
  }

  void _loadFromOfflineCache() {
    try {
      final String? cachedJson = _prefsService.sharedPreferences.getString(_cacheKey);
      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        customers.value = decoded.map((c) => Customer.fromJson(c)).toList();
        _logger.debug("Customers offline cache loaded successfully: ${customers.length} records");
      }
    } catch (e, stack) {
      _logger.error("Failed to load offline customers cache", e.toString(), stack);
    }
  }

  Future<void> _saveToOfflineCache() async {
    try {
      // Only cache page 1 results to keep cache lightweight
      final List<Map<String, dynamic>> rawList =
          customers.take(30).map((c) => c.toJson()).toList();
      await _prefsService.sharedPreferences.setString(_cacheKey, jsonEncode(rawList));
    } catch (e) {
      _logger.error("Failed to save offline customers cache", e.toString());
    }
  }

  Future<void> loadCustomers({bool isRefresh = false}) async {
    if (isLoading.value || isLoadMore.value) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      hasError.value = false;
    }

    // 1. Connectivity Check
    if (!_networkService.isOnline.value) {
      _logger.warning("Customers list fetch failed: Network is offline.");
      if (isRefresh) {
        _loadFromOfflineCache();
      }
      _showToast('Offline Mode: Showing cached customer records. Check internet connectivity.', Colors.orangeAccent);
      return;
    }

    if (isRefresh) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      // Determine SalespersonCode for "My Customers" filter mode
      String? targetSalespersonCode;
      if (filterMode.value == CustomerFilterMode.myCustomers) {
        if (Get.isRegistered<HomeController>()) {
          final currentUser = Get.find<HomeController>().currentUser.value;
          if (currentUser != null) {
            targetSalespersonCode = currentUser.empSalesmanCode?.isNotEmpty == true
                ? currentUser.empSalesmanCode
                : (currentUser.employeeCode.isNotEmpty == true ? currentUser.employeeCode : null);
          }
        }
      }

      String? targetSortColumn;
      String? targetSortDirection;

      if (sortMode.value == CustomerSortMode.balanceAsc) {
        targetSortColumn = 'Balance';
        targetSortDirection = 'asc';
      } else if (sortMode.value == CustomerSortMode.balanceDesc) {
        targetSortColumn = 'Balance';
        targetSortDirection = 'desc';
      }

      // 2. Fetch Paged Customers
      final pagedResponse = await _customerRepo.getCustomers(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        salespersonCode: targetSalespersonCode,
        sortColumn: targetSortColumn,
        sortDirection: targetSortDirection,
      );

      if (pagedResponse.success) {
        final newItems = pagedResponse.data;

        if (isRefresh) {
          customers.assignAll(newItems);
          _saveToOfflineCache();
        } else {
          customers.addAll(newItems);
        }

        _hasMore = newItems.length >= _pageSize;
        _currentPage++;
      } else {
        hasError.value = isRefresh;
        _showToast(pagedResponse.message.isNotEmpty ? pagedResponse.message : 'Failed to retrieve customers.', Colors.redAccent);
      }
    } catch (e, stack) {
      _logger.error("Error occurred fetching customers", e.toString(), stack);
      hasError.value = isRefresh;
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoading.value || isLoadMore.value) return;
    await loadCustomers(isRefresh: false);
  }

  void updateSearch(String val) {
    searchQuery.value = val;
  }

  Future<void> deleteCustomerRecord(String customerNo) async {
    if (!canDelete) {
      _showToast('Unauthorized: You do not have permission to delete customer records.', Colors.red);
      return;
    }

    if (!_networkService.isOnline.value) {
      _showToast('Offline: Cannot delete customer record while offline.', Colors.orangeAccent);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete customer $customerNo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // close dialog
              isLoading.value = true;
              try {
                final result = await _customerRepo.deleteCustomer(customerNo);
                if (result.success) {
                  customers.removeWhere((c) => c.customerNo == customerNo);
                  _saveToOfflineCache();
                  _showToast('Customer $customerNo deleted successfully.', Colors.green);
                } else {
                  _showToast(result.message, Colors.red);
                }
              } catch (e) {
                _logger.error("Failed to delete customer", e.toString());
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }
}
