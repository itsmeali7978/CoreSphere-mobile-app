import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/payment_receipt_repository.dart';

class CreateReceiptController extends GetxController {
  final PaymentReceiptRepository _receiptRepo = Get.find<PaymentReceiptRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  final remarksController = TextEditingController();
  final searchController = TextEditingController();

  final Rxn<Customer> selectedCustomer = Rxn<Customer>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedPaymentMethod = 'CASH'.obs;
  final RxString selectedPaymentAgainst = 'Partial Payment'.obs;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<Customer> filteredCustomers = <Customer>[].obs;
  final RxBool isLoadingCustomers = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSubmitting = false.obs;

  // Validation observables
  final RxnString customerError = RxnString();
  final RxnString amountError = RxnString();

  final List<Map<String, String>> paymentMethods = const [
    {'code': 'CASH', 'name': 'Cash'},
    {'code': 'BANK', 'name': 'Bank Transfer'},
    {'code': 'CHEQUE', 'name': 'Check / Cheque'},
    {'code': 'CARD', 'name': 'Credit / Debit Card'},
  ];

  @override
  void onInit() {
    super.onInit();
    
    // Check if a customer was passed in navigation arguments
    final args = Get.arguments;
    if (args is Customer) {
      selectedCustomer.value = args;
    }

    _loadCustomers();
    debounce(searchQuery, (String query) {
      searchCustomers(query);
    }, time: const Duration(milliseconds: 350));
  }

  @override
  void onClose() {
    amountController.dispose();
    referenceController.dispose();
    remarksController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadCustomers() async {
    isLoadingCustomers.value = true;
    try {
      final pagedResponse = await _customerRepo.getCustomers(page: 1, pageSize: 100);
      if (pagedResponse.success) {
        customers.assignAll(pagedResponse.data);
        filteredCustomers.assignAll(pagedResponse.data);
      }
    } catch (e) {
      _logger.error("Failed to load customers for receipt creation", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      filteredCustomers.assignAll(customers);
      return;
    }

    isSearching.value = true;
    try {
      final pagedResponse = await _customerRepo.getCustomers(
        page: 1,
        pageSize: 100,
        searchQuery: query,
      );
      if (pagedResponse.success) {
        filteredCustomers.assignAll(pagedResponse.data);
      }
    } catch (e) {
      _logger.error("Failed to search customers", e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  void setDate(DateTime date) {
    final now = DateTime.now();
    selectedDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );
  }

  void setCustomer(Customer customer) {
    selectedCustomer.value = customer;
    customerError.value = null;
    searchQuery.value = '';
    searchController.clear();
    filteredCustomers.assignAll(customers);
  }

  void setPaymentMethod(String code) {
    selectedPaymentMethod.value = code;
  }

  bool _validateForm() {
    bool isValid = true;

    if (selectedCustomer.value == null) {
      customerError.value = 'Please select a customer.';
      isValid = false;
    } else {
      customerError.value = null;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      amountError.value = 'Amount is required.';
      isValid = false;
    } else {
      final parsedAmount = double.tryParse(amountText);
      if (parsedAmount == null || parsedAmount <= 0) {
        amountError.value = 'Please enter a valid positive amount.';
        isValid = false;
      } else {
        amountError.value = null;
      }
    }

    return isValid;
  }

  Future<void> submitReceipt() async {
    if (!_validateForm()) return;

    if (!_networkService.isOnline.value) {
      AppToast.show('Offline: Internet connection required to create payment receipts.', backgroundColor: Colors.orangeAccent);
      return;
    }

    isSubmitting.value = true;
    _logger.info("Submitting new customer payment receipt...");

    try {
      final employeeCode = await _storageService.getEmployeeCode() ?? 'EMP001';
      final double amount = double.parse(amountController.text.trim());

      final result = await _receiptRepo.createReceipt(
        customerNo: selectedCustomer.value!.customerNo,
        employeeCode: employeeCode,
        receiptDate: selectedDate.value,
        amount: amount,
        paymentMethodCode: selectedPaymentMethod.value,
        referenceNo: referenceController.text.trim().isNotEmpty ? referenceController.text.trim() : null,
        remarks: remarksController.text.trim().isNotEmpty ? remarksController.text.trim() : null,
        paymentAgainst: selectedPaymentAgainst.value,
      );

      if (result.success && result.data != null) {
        final newReceipt = result.data!;
        AppToast.show('Receipt ${newReceipt.receiptNo} created successfully!', backgroundColor: Colors.green);
        _logger.info("Receipt ${newReceipt.receiptNo} created with ID ${newReceipt.receiptId}.");

        Get.offNamed(RouteNames.paymentReceiptDetails, arguments: newReceipt);
      } else {
        final errMsg = result.message.isNotEmpty ? result.message : 'Failed to create payment receipt.';
        AppToast.show(errMsg, backgroundColor: Colors.redAccent);
      }
    } catch (e, stack) {
      _logger.error("Exception creating receipt", e.toString(), stack);
      AppToast.show('An unexpected error occurred. Please try again.', backgroundColor: Colors.redAccent);
    } finally {
      isSubmitting.value = false;
    }
  }
}
