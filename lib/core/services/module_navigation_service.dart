import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/collections/bindings/collections_binding.dart';
import '../../features/collections/views/collections_view.dart';
import '../../features/customers/bindings/customer_binding.dart';
import '../../features/customers/views/customers_list_view.dart';
import '../../features/employees/bindings/employees_binding.dart';
import '../../features/employees/views/employees_list_view.dart';
import '../../features/payment_receipts/bindings/payment_receipts_binding.dart';
import '../../features/payment_receipts/views/receipt_history_view.dart';
import '../theme/app_theme.dart';
import '../utils/app_toast.dart';
import 'permission_service.dart';

import '../../../data/models/module.dart';

class ModuleNavigationService extends GetxService {
  final PermissionService _permissionService = Get.find<PermissionService>();

  void navigateToModule(String moduleCode, {String? routeName}) {
    String formattedCode = moduleCode.trim().toUpperCase();

    // Strip "MOD_" prefix if present
    if (formattedCode.startsWith('MOD_')) {
      formattedCode = formattedCode.substring(4);
    }

    // 1. Direct View Navigation (Guarantees immediate screen launching)
    if (formattedCode.contains('COLLECT')) {
      Get.to(
        () => const CollectionsView(),
        binding: CollectionsBinding(),
        preventDuplicates: false,
      );
      return;
    }

    if (formattedCode.contains('RECEIPT')) {
      Get.to(
        () => const ReceiptHistoryView(),
        binding: PaymentReceiptsBinding(),
        preventDuplicates: false,
      );
      return;
    }

    if (formattedCode.contains('CUSTOMER')) {
      Get.to(
        () => const CustomersListView(),
        binding: CustomerBinding(),
        preventDuplicates: false,
      );
      return;
    }

    if (formattedCode.contains('EMPLOYEE')) {
      Get.to(
        () => const EmployeesListView(),
        binding: EmployeesBinding(),
        preventDuplicates: false,
      );
      return;
    }

    if (formattedCode == 'MY_REQUESTS' || formattedCode == 'MYREQUESTS') {
      Get.toNamed('/hr/my-requests');
      return;
    }

    if (formattedCode == 'PENDING_APPROVALS' || formattedCode == 'PENDINGAPPROVALS') {
      Get.toNamed('/hr/pending-approvals');
      return;
    }

    if (routeName != null && routeName.isNotEmpty) {
      Get.toNamed(routeName);
      return;
    }

    // 2. Permission Check Fallback for Unmapped Modules
    if (!_permissionService.canViewModule(moduleCode)) {
      final allPerms = _permissionService.cachedPermissions;
      Get.dialog(
        AlertDialog(
          title: const Text('Access Denied'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('You do not have permission to view "$formattedCode".'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Cached Permissions (${allPerms.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (allPerms.isEmpty)
                  const Text('No permissions found in cache.', style: TextStyle(color: Colors.red))
                else
                  ...allPerms.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${p.moduleCode} : ${p.permissionCode} = ${p.isAllowed}',
                          style: TextStyle(
                            fontSize: 12,
                            color: p.isAllowed ? Colors.green : Colors.red,
                            fontFamily: 'monospace',
                          ),
                        ),
                      )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    AppToast.show(
      'Under Construction: $moduleCode (Route: ${routeName ?? "null"})',
      backgroundColor: Colors.orange,
    );
  }
}
