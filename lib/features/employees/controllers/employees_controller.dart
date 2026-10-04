import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../data/models/employee.dart';
import '../../../data/repositories/employee_repository.dart';

class EmployeesController extends GetxController {
  final EmployeeRepository _employeeRepo = Get.find<EmployeeRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool canView = true.obs;
  final RxString searchQuery = ''.obs;

  // Filters
  final RxString statusFilter = 'All'.obs; // 'All', 'Active', 'Inactive'
  final RxString nationalityFilter = 'All'.obs; // 'All', 'Saudi', 'Non-Saudi'

  void setStatusFilter(String value) {
    statusFilter.value = value;
  }

  void setNationalityFilter(String value) {
    nationalityFilter.value = value;
  }

  void resetFilters() {
    statusFilter.value = 'All';
    nationalityFilter.value = 'All';
  }

  bool get hasActiveFilters => statusFilter.value != 'All' || nationalityFilter.value != 'All';

  int get activeFiltersCount {
    int count = 0;
    if (statusFilter.value != 'All') count++;
    if (nationalityFilter.value != 'All') count++;
    return count;
  }

  List<Employee> get filteredEmployees {
    return employees.where((emp) {
      // 1. Status Filter (Active / Inactive)
      if (statusFilter.value == 'Active' && !emp.isActive) return false;
      if (statusFilter.value == 'Inactive' && emp.isActive) return false;

      // 2. Nationality Filter (Saudi / Non-Saudi via isSaudiNational)
      if (nationalityFilter.value == 'Saudi' && !emp.isSaudiNational) return false;
      if (nationalityFilter.value == 'Non-Saudi' && emp.isSaudiNational) return false;

      return true;
    }).toList();
  }

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  Timer? _debounceTimer;

  static const String _offlineCacheKey = 'cached_employees_list';

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    if (canView.value) {
      _loadFromOfflineCache();
      loadEmployees(isRefresh: true);
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _checkPermissions() {
    // Module authorization comes entirely from the backend RBAC
    canView.value = _permissionService.canViewModule('EMPLOYEES') ||
        _permissionService.canViewModule('MOD_EMPLOYEES');
    
    if (!canView.value) {
      _logger.warning("User does not have VIEW permission for EMPLOYEES module.");
    }
  }

  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      loadEmployees(isRefresh: true);
    });
  }

  Future<void> refreshEmployees() async {
    await loadEmployees(isRefresh: true);
  }

  Future<void> loadEmployees({bool isRefresh = false}) async {
    if (!canView.value) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      hasError.value = false;
    }

    isOffline.value = !_networkService.isOnline.value;

    // Offline handling
    if (isOffline.value) {
      _logger.warning("Fetch employees failed: Network is offline.");
      if (isRefresh) {
        _loadFromOfflineCache();
      }
      _showToast('Offline Mode: Displaying cached employee records.', Colors.orangeAccent);
      return;
    }

    if (isRefresh) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      final pagedResponse = await _employeeRepo.getEmployees(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (pagedResponse.success) {
        final newItems = pagedResponse.data;

        if (isRefresh) {
          employees.assignAll(newItems);
          _saveToOfflineCache();
        } else {
          employees.addAll(newItems);
        }

        _hasMore = newItems.length >= _pageSize;
        _currentPage++;
      } else {
        hasError.value = isRefresh;
        _showToast(
          pagedResponse.message.isNotEmpty ? pagedResponse.message : 'Failed to retrieve employees.',
          Colors.redAccent,
        );
      }
    } catch (e, stack) {
      _logger.error("Error occurred fetching employees", e.toString(), stack);
      hasError.value = isRefresh;
      _showToast('Network error loading employees.', Colors.redAccent);
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoading.value || isLoadMore.value || !canView.value) return;
    await loadEmployees(isRefresh: false);
  }

  void _loadFromOfflineCache() {
    try {
      final jsonString = _prefsService.sharedPreferences.getString(_offlineCacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final cachedList = decoded.map((item) => Employee.fromJson(item as Map<String, dynamic>)).toList();
        employees.assignAll(cachedList);
        _logger.debug("Loaded ${cachedList.length} employees from offline cache.");
      }
    } catch (e) {
      _logger.error("Failed to load employees offline cache", e.toString());
    }
  }

  void _saveToOfflineCache() {
    try {
      final jsonList = employees.map((e) => e.toJson()).toList();
      _prefsService.sharedPreferences.setString(_offlineCacheKey, jsonEncode(jsonList));
      _logger.debug("Saved ${employees.length} employees to offline cache.");
    } catch (e) {
      _logger.error("Failed to save employees offline cache", e.toString());
    }
  }

  void _showToast(String message, Color color) {
    AppToast.show(message, backgroundColor: color);
  }
}
