import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customers_controller.dart';

class CustomerFormController extends GetxController {
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final NetworkService _networkService = Get.find<NetworkService>();
  final AppLogger _logger = Get.find<AppLogger>();

  final isEditMode = false.obs;
  final isLoading = false.obs;

  // Form Controllers
  late TextEditingController customerNoController;
  late TextEditingController nameController;
  late TextEditingController name2Controller;
  late TextEditingController addressController;
  late TextEditingController postalCodeController;
  late TextEditingController buildingNoController;
  late TextEditingController districtController;
  late TextEditingController cityController;
  late TextEditingController mobileNoController;
  late TextEditingController emailController;
  late TextEditingController vatRegistrationNoController;
  late TextEditingController contactPersonNameController;
  late TextEditingController salesPersonCodeController;
  late TextEditingController creditLimitController;

  // Dynamic Validation Error Alerts Map
  final RxMap<String, String> validationErrors = <String, String>{}.obs;

  late String _originalCustomerNo;

  @override
  void onInit() {
    super.onInit();
    _initFormControllers();
    _checkArguments();
  }

  void _initFormControllers() {
    customerNoController = TextEditingController();
    nameController = TextEditingController();
    name2Controller = TextEditingController();
    addressController = TextEditingController();
    postalCodeController = TextEditingController();
    buildingNoController = TextEditingController();
    districtController = TextEditingController();
    cityController = TextEditingController();
    mobileNoController = TextEditingController();
    emailController = TextEditingController();
    vatRegistrationNoController = TextEditingController();
    contactPersonNameController = TextEditingController();
    salesPersonCodeController = TextEditingController();
    creditLimitController = TextEditingController();
  }

  @override
  void onClose() {
    customerNoController.dispose();
    nameController.dispose();
    name2Controller.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    buildingNoController.dispose();
    districtController.dispose();
    cityController.dispose();
    mobileNoController.dispose();
    emailController.dispose();
    vatRegistrationNoController.dispose();
    contactPersonNameController.dispose();
    salesPersonCodeController.dispose();
    creditLimitController.dispose();
    super.onClose();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args is Customer) {
      isEditMode.value = true;
      _originalCustomerNo = args.customerNo;
      _populateFields(args);
    } else {
      isEditMode.value = false;
      _originalCustomerNo = '';
    }
  }

  void _populateFields(Customer c) {
    customerNoController.text = c.customerNo;
    nameController.text = c.name;
    name2Controller.text = c.name2 ?? '';
    addressController.text = c.address ?? '';
    postalCodeController.text = c.postalCode ?? '';
    buildingNoController.text = c.buildingNo ?? '';
    districtController.text = c.district ?? '';
    cityController.text = c.city ?? '';
    mobileNoController.text = c.mobileNo ?? '';
    emailController.text = c.email ?? '';
    vatRegistrationNoController.text = c.vatRegistrationNo ?? '';
    contactPersonNameController.text = c.contactPersonName ?? '';
    salesPersonCodeController.text = c.salesPersonCode ?? '';
    creditLimitController.text = c.creditLimit != null ? c.creditLimit.toString() : '';
  }

  bool _validateLocal() {
    validationErrors.clear();

    if (!isEditMode.value && customerNoController.text.trim().isEmpty) {
      // Allow empty if auto-numbering, otherwise warn
      // We will let backend auto number if left blank, but if typed it must follow logic
    }

    if (nameController.text.trim().isEmpty) {
      validationErrors['name'] = 'Customer name is required.';
    }

    final String email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      validationErrors['email'] = 'Invalid email address format.';
    }

    final String phone = mobileNoController.text.trim();
    if (phone.isNotEmpty && phone.length < 8) {
      validationErrors['mobileNo'] = 'Phone number must be at least 8 digits.';
    }

    return validationErrors.isEmpty;
  }

  Future<void> submitForm() async {
    if (!_validateLocal()) return;

    if (!_networkService.isOnline.value) {
      Get.snackbar(
        'Offline',
        'Cannot save changes while offline.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    _logger.info("Submitting customer form. EditMode: ${isEditMode.value}");

    final customerObj = Customer(
      customerNo: customerNoController.text.trim(),
      name: nameController.text.trim(),
      name2: name2Controller.text.trim().isNotEmpty ? name2Controller.text.trim() : null,
      address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
      postalCode: postalCodeController.text.trim().isNotEmpty ? postalCodeController.text.trim() : null,
      buildingNo: buildingNoController.text.trim().isNotEmpty ? buildingNoController.text.trim() : null,
      district: districtController.text.trim().isNotEmpty ? districtController.text.trim() : null,
      city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : null,
      mobileNo: mobileNoController.text.trim().isNotEmpty ? mobileNoController.text.trim() : null,
      email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
      vatRegistrationNo: vatRegistrationNoController.text.trim().isNotEmpty ? vatRegistrationNoController.text.trim() : null,
      contactPersonName: contactPersonNameController.text.trim().isNotEmpty ? contactPersonNameController.text.trim() : null,
      salesPersonCode: salesPersonCodeController.text.trim().isNotEmpty ? salesPersonCodeController.text.trim() : null,
      creditLimit: double.tryParse(creditLimitController.text.trim()),
    );

    try {
      if (isEditMode.value) {
        // Edit Customer
        final result = await _customerRepo.updateCustomer(_originalCustomerNo, customerObj);
        if (result.success) {
          Get.snackbar(
            'Success',
            'Customer updated successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Refresh customer list
          Get.find<CustomersController>().loadCustomers(isRefresh: true);
          Get.back(); // return to details or list
        } else {
          _handleApiErrors(result.message, result.errors);
        }
      } else {
        // Create Customer
        final result = await _customerRepo.createCustomer(customerObj);
        if (result.success) {
          Get.snackbar(
            'Success',
            'Customer created successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Refresh customer list
          Get.find<CustomersController>().loadCustomers(isRefresh: true);
          Get.back();
        } else {
          _handleApiErrors(result.message, result.errors);
        }
      }
    } catch (e, stack) {
      _logger.error("Failed to submit customer form", e.toString(), stack);
      Get.snackbar(
        'Submission Error',
        'An error occurred. Please verify form details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _handleApiErrors(String message, List<String>? errors) {
    if (message.contains("already exists")) {
      validationErrors['customerNo'] = 'Customer number already exists.';
      return;
    }

    if (errors != null && errors.isNotEmpty) {
      for (var err in errors) {
        final lowerErr = err.toLowerCase();
        if (lowerErr.contains("name")) {
          validationErrors['name'] = err;
        } else if (lowerErr.contains("email")) {
          validationErrors['email'] = err;
        } else if (lowerErr.contains("mobile") || lowerErr.contains("phone")) {
          validationErrors['mobileNo'] = err;
        }
      }
    } else {
      Get.snackbar(
        'Form Alert',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }
}
