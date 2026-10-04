import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/customer_payment_receipt.dart';
import '../../../data/repositories/payment_receipt_repository.dart';

class ReceiptHistoryController extends GetxController {
  final PaymentReceiptRepository _receiptRepo = Get.find<PaymentReceiptRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();

  static const String _offlineCacheKey = 'cached_payment_receipts_list';

  final RxList<CustomerPaymentReceipt> receipts = <CustomerPaymentReceipt>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isOffline = false.obs;
  final RxString searchQuery = ''.obs;

  // Permissions
  final RxBool canCreate = false.obs;
  final RxBool canPrint = false.obs;
  final RxBool canShare = false.obs;
  final RxBool canEmail = false.obs;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    loadReceipts(isRefresh: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void _checkPermissions() {
    // Module permissions are checked via PermissionService
    canCreate.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'CREATE') ||
        _permissionService.hasPermission('RECEIPT', 'CREATE') ||
        _permissionService.hasPermission('CUSTOMER_PAYMENT_RECEIPTS', 'CREATE');

    canPrint.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'PRINT') ||
        _permissionService.hasPermission('RECEIPT', 'PRINT');

    canShare.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'SHARE') ||
        _permissionService.hasPermission('RECEIPT', 'SHARE');

    canEmail.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'EMAIL') ||
        _permissionService.hasPermission('RECEIPT', 'EMAIL');
  }

  Future<void> loadReceipts({bool isRefresh = false}) async {
    if (isLoading.value || isLoadMore.value) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      hasError.value = false;
    }

    if (!_hasMore && !isRefresh) return;

    isOffline.value = !_networkService.isOnline.value;

    if (isOffline.value) {
      _logger.warning("Fetch receipts failed: Network is offline.");
      if (isRefresh) {
        _loadFromOfflineCache();
      }
      AppToast.show('Offline Mode: Displaying cached receipts.', backgroundColor: Colors.orangeAccent);
      return;
    }

    if (isRefresh) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      final pagedResponse = await _receiptRepo.getReceipts(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (pagedResponse.success) {
        final newItems = pagedResponse.data;

        if (isRefresh) {
          receipts.assignAll(newItems);
          _saveToOfflineCache();
        } else {
          receipts.addAll(newItems);
        }

        _hasMore = _currentPage < pagedResponse.totalPages;
        if (_hasMore) _currentPage++;
      } else {
        hasError.value = true;
        if (isRefresh && receipts.isEmpty) {
          _loadFromOfflineCache();
        }
      }
    } catch (e, stack) {
      _logger.error("Exception during receipts fetch", e.toString(), stack);
      hasError.value = true;
      if (isRefresh && receipts.isEmpty) {
        _loadFromOfflineCache();
      }
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  void loadMore() {
    if (!_hasMore || isLoadMore.value || isLoading.value) return;
    loadReceipts(isRefresh: false);
  }

  void updateSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = query;
      loadReceipts(isRefresh: true);
    });
  }

  void _loadFromOfflineCache() {
    try {
      final cachedJsonStr = _prefsService.sharedPreferences.getString(_offlineCacheKey);
      if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJsonStr);
        final cachedList = decoded.map((e) => CustomerPaymentReceipt.fromJson(e)).toList();
        receipts.assignAll(cachedList);
        _logger.debug("Successfully loaded ${receipts.length} receipts from offline cache.");
      }
    } catch (e) {
      _logger.error("Failed to load receipts offline cache", e.toString());
    }
  }

  void _saveToOfflineCache() {
    try {
      final jsonList = receipts.map((e) => e.toJson()).toList();
      _prefsService.sharedPreferences.setString(_offlineCacheKey, jsonEncode(jsonList));
      _logger.debug("Saved ${receipts.length} receipts to offline cache.");
    } catch (e) {
      _logger.error("Failed to save receipts offline cache", e.toString());
    }
  }
}
