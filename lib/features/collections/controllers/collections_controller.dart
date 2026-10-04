import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/customer_payment_receipt.dart';
import '../../../data/repositories/payment_receipt_repository.dart';

class CollectionsController extends GetxController {
  late final PaymentReceiptRepository _receiptRepo;
  final StorageService _storageService = Get.find<StorageService>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final RxList<CustomerPaymentReceipt> receipts = <CustomerPaymentReceipt>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedEmployeeCode = ''.obs;

  final TextEditingController employeeSearchController = TextEditingController();

  List<CustomerPaymentReceipt> get displayedReceipts {
    List<CustomerPaymentReceipt> list = receipts;

    final filterCode = (selectedEmployeeCode.value.isNotEmpty
            ? selectedEmployeeCode.value
            : employeeSearchController.text)
        .trim()
        .toLowerCase();

    if (filterCode.isNotEmpty) {
      list = list.where((r) {
        final empCodeMatches = r.employeeCode.toLowerCase().contains(filterCode);
        final collectedByMatches = r.collectedBy?.toLowerCase().contains(filterCode) ?? false;
        return empCodeMatches || collectedByMatches;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((r) {
        final receiptNoMatches = r.receiptNo.toLowerCase().contains(query);
        final customerNoMatches = r.customerNo.toLowerCase().contains(query);
        final nameMatches = r.customerName?.toLowerCase().contains(query) ?? false;
        final name2Matches = r.customerName2?.toLowerCase().contains(query) ?? false;
        final empCodeMatches = r.employeeCode.toLowerCase().contains(query);
        return receiptNoMatches || customerNoMatches || nameMatches || name2Matches || empCodeMatches;
      }).toList();
    }

    return list;
  }

  int _currentPage = 1;
  final int _pageSize = 50;
  bool _hasMore = true;
  Timer? _debounce;
  Timer? _empDebounce;

  @override
  void onInit() {
    super.onInit();
    _receiptRepo = Get.isRegistered<PaymentReceiptRepository>()
        ? Get.find<PaymentReceiptRepository>()
        : Get.put(PaymentReceiptRepository());

    loadCollections(isRefresh: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _empDebounce?.cancel();
    employeeSearchController.dispose();
    super.onClose();
  }

  Future<void> loadCollections({bool isRefresh = false}) async {
    if (isLoading.value || isLoadMore.value) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      hasError.value = false;
    }

    if (!_hasMore && !isRefresh) return;

    if (!_networkService.isOnline.value) {
      AppToast.show('Offline Mode: Internet connection required for collections.', backgroundColor: Colors.orangeAccent);
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
        status: 0, // Uncollected / pending collection
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        employeeCode: selectedEmployeeCode.value.isNotEmpty ? selectedEmployeeCode.value : null,
      );

      if (pagedResponse.success) {
        final newItems = pagedResponse.data;

        if (isRefresh) {
          receipts.assignAll(newItems);
        } else {
          receipts.addAll(newItems);
        }

        _hasMore = _currentPage < pagedResponse.totalPages;
        if (_hasMore) _currentPage++;
      } else {
        hasError.value = true;
      }
    } catch (e, stack) {
      _logger.error("Exception fetching payment collections", e.toString(), stack);
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  void loadMore() {
    if (!_hasMore || isLoadMore.value || isLoading.value) return;
    loadCollections(isRefresh: false);
  }

  void updateSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = query;
      loadCollections(isRefresh: true);
    });
  }

  void setEmployeeFilter(String employeeCode) {
    if (selectedEmployeeCode.value == employeeCode) return;
    employeeSearchController.text = employeeCode;
    selectedEmployeeCode.value = employeeCode;
    loadCollections(isRefresh: true);
  }

  void updateEmployeeSearch(String query) {
    if (_empDebounce?.isActive ?? false) _empDebounce!.cancel();
    _empDebounce = Timer(const Duration(milliseconds: 350), () {
      selectedEmployeeCode.value = query.trim();
      loadCollections(isRefresh: true);
    });
  }

  void clearEmployeeFilter() {
    _empDebounce?.cancel();
    employeeSearchController.clear();
    selectedEmployeeCode.value = '';
    loadCollections(isRefresh: true);
  }

  Future<void> receivePayment(CustomerPaymentReceipt receipt) async {
    if (isSubmitting.value) return;

    if (!_networkService.isOnline.value) {
      AppToast.show('Offline: Internet connection required.', backgroundColor: Colors.orangeAccent);
      return;
    }

    isSubmitting.value = true;
    try {
      final currentUserCode = await _storageService.getEmployeeCode() ?? 'EMP001';
      final result = await _receiptRepo.receivePayment(
        receipt.receiptId,
        collectedBy: currentUserCode,
      );

      if (result.success) {
        AppToast.show('Payment for receipt ${receipt.receiptNo} marked as Received.', backgroundColor: Colors.green);
        receipts.removeWhere((r) => r.receiptId == receipt.receiptId);
      } else {
        final errMsg = result.message.isNotEmpty ? result.message : 'Failed to process Receive Payment.';
        AppToast.show(errMsg, backgroundColor: Colors.redAccent);
      }
    } catch (e, stack) {
      _logger.error("Exception during Receive Payment operation", e.toString(), stack);
      AppToast.show('An error occurred while marking payment as received.', backgroundColor: Colors.redAccent);
    } finally {
      isSubmitting.value = false;
    }
  }
}
