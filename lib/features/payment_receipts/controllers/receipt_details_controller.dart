import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/customer_payment_receipt.dart';
import '../../../data/repositories/payment_receipt_repository.dart';

class ReceiptDetailsController extends GetxController {
  final PaymentReceiptRepository _receiptRepo = Get.find<PaymentReceiptRepository>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final Rxn<CustomerPaymentReceipt> receipt = Rxn<CustomerPaymentReceipt>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  // Permissions
  final RxBool canPrint = false.obs;
  final RxBool canShare = false.obs;
  final RxBool canEmail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    _loadDetails();
  }

  void _checkPermissions() {
    canPrint.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'PRINT') ||
        _permissionService.hasPermission('RECEIPT', 'PRINT');

    canShare.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'SHARE') ||
        _permissionService.hasPermission('RECEIPT', 'SHARE');

    canEmail.value = _permissionService.hasPermission('CUSTOMERPAYMENTRECEIPT', 'EMAIL') ||
        _permissionService.hasPermission('RECEIPT', 'EMAIL');
  }

  Future<void> _loadDetails() async {
    final args = Get.arguments;
    if (args is CustomerPaymentReceipt) {
      receipt.value = args;
      // Fetch fresh details from API if online
      if (_networkService.isOnline.value) {
        _fetchFreshDetails(args.receiptId);
      }
      return;
    }

    if (args is int) {
      _fetchFreshDetails(args);
      return;
    }

    hasError.value = true;
    AppToast.show('No receipt identifier provided.', backgroundColor: Colors.redAccent);
  }

  Future<void> _fetchFreshDetails(int id) async {
    isLoading.value = true;
    try {
      final result = await _receiptRepo.getReceiptById(id);
      if (result.success && result.data != null) {
        receipt.value = result.data;
      } else {
        if (receipt.value == null) {
          hasError.value = true;
        }
      }
    } catch (e, stack) {
      _logger.error("Failed to load details for receipt $id", e.toString(), stack);
      if (receipt.value == null) {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    hasError.value = false;
    final args = Get.arguments;
    if (args is CustomerPaymentReceipt) {
      _fetchFreshDetails(args.receiptId);
    } else if (args is int) {
      _fetchFreshDetails(args);
    }
  }
}
