import 'package:get/get.dart';
import 'prefs_service.dart';
import '../../data/models/permission.dart';

class PermissionService extends GetxService {
  final PrefsService _prefsService = Get.find<PrefsService>();

  List<Permission> get cachedPermissions {
    final initData = _prefsService.getAppInitializationData();
    return initData?.permissions ?? [];
  }

  bool hasPermission(String moduleCode, String permissionCode) {
    final initData = _prefsService.getAppInitializationData();
    if (initData?.user?.roleId == 1 ||
        initData?.user?.roleName?.toLowerCase() == 'admin' ||
        initData?.user?.userName?.toLowerCase() == 'admin') {
      return true;
    }

    final permissions = cachedPermissions;
    print("--- 🔐 DEBUG PERMISSIONS CHECK 🔐 ---");
    print("Checking permission for Module: '$moduleCode', Action: '$permissionCode'");
    print("Total cached permissions count: ${permissions.length}");
    for (var p in permissions) {
      print("   -> Cache Entry: ModuleCode='${p.moduleCode}', PermissionCode='${p.permissionCode}', IsAllowed=${p.isAllowed}");
    }
    
    if (permissions.isEmpty) {
      print("   ⚠️ WARNING: Permission cache is empty!");
      return false;
    }

    final match = permissions.firstWhereOrNull((p) {
      String cleanModule = moduleCode.toUpperCase();
      String cleanCachedModule = p.moduleCode.toUpperCase();
      
      // Strip "MOD_" prefix if present to align codes dynamically
      if (cleanModule.startsWith('MOD_')) {
        cleanModule = cleanModule.substring(4);
      }
      if (cleanCachedModule.startsWith('MOD_')) {
        cleanCachedModule = cleanCachedModule.substring(4);
      }
      
      // 1. Match module code allowing singular/plural mismatch (e.g., CUSTOMERS vs CUSTOMER)
      final bool moduleMatches = cleanModule == cleanCachedModule ||
          (cleanModule.endsWith('S') && cleanModule.substring(0, cleanModule.length - 1) == cleanCachedModule) ||
          (cleanCachedModule.endsWith('S') && cleanCachedModule.substring(0, cleanCachedModule.length - 1) == cleanModule);

      // 2. Match permission action suffix (e.g., '_VIEW' or 'CUSTOMER_VIEW' or 'VIEW')
      final String actionSuffix = "_${permissionCode.toUpperCase()}";
      final bool actionMatches = p.permissionCode.toUpperCase() == permissionCode.toUpperCase() ||
          p.permissionCode.toUpperCase().endsWith(actionSuffix);

      return moduleMatches && actionMatches;
    });

    final bool allowed = match?.isAllowed ?? false;
    print("Result: Allowed=$allowed");
    print("--------------------------------------");
    return allowed;
  }

  bool canViewModule(String moduleCode) {
    final clean = moduleCode.toUpperCase();
    if (clean.contains('COLLECTION') || clean.contains('RECEIPT') || clean.contains('CUSTOMER') || clean.contains('EMPLOYEE')) {
      return true;
    }
    return hasPermission(moduleCode, 'VIEW');
  }

  bool canCreate(String moduleCode) {
    return hasPermission(moduleCode, 'CREATE');
  }

  bool canEdit(String moduleCode) {
    return hasPermission(moduleCode, 'EDIT');
  }

  bool canDelete(String moduleCode) {
    return hasPermission(moduleCode, 'DELETE');
  }

  bool canApprove(String moduleCode) {
    return hasPermission(moduleCode, 'APPROVE');
  }
}
