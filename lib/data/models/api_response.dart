import 'user.dart';
import 'dashboard_card.dart';
import 'module.dart';
import 'permission.dart';
import 'device.dart';
import 'app_config.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final bool isSuccess = json['success'] as bool? ?? json['Success'] as bool? ?? true;
    final String msg = (json['message'] ?? json['Message'] ?? '').toString();
    final dynamic rawData = json['data'] ?? json['Data'];
    final dynamic rawErrors = json['errors'] ?? json['Errors'];

    return ApiResponse(
      success: isSuccess,
      message: msg,
      data: rawData != null ? fromJsonT(rawData) : null,
      errors: rawErrors != null && rawErrors is List ? List<String>.from(rawErrors) : null,
    );
  }
}

class AppInitializationResponse {
  final User? user;
  final List<DashboardCard>? dashboardCards;
  final List<Module>? modules;
  final List<Permission>? permissions;
  final Device? device;
  final AppConfig? configuration;

  AppInitializationResponse({
    this.user,
    this.dashboardCards,
    this.modules,
    this.permissions,
    this.device,
    this.configuration,
  });

  factory AppInitializationResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'] ?? json['User'];
    final rawCards = json['dashboardCards'] ?? json['DashboardCards'];
    final rawModules = json['modules'] ?? json['Modules'];
    final rawPermissions = json['permissions'] ?? json['Permissions'];
    final rawDevice = json['device'] ?? json['Device'];
    final rawConfig = json['configuration'] ?? json['Configuration'];

    List<DashboardCard>? parsedCards;
    if (rawCards != null && rawCards is List) {
      parsedCards = rawCards.map((i) {
        try {
          if (i is Map<String, dynamic>) {
            return DashboardCard.fromJson(i);
          }
        } catch (_) {}
        return null;
      }).whereType<DashboardCard>().toList();
    }

    List<Module>? parsedModules;
    if (rawModules != null && rawModules is List) {
      parsedModules = rawModules.map((i) {
        try {
          if (i is Map<String, dynamic>) {
            return Module.fromJson(i);
          }
        } catch (_) {}
        return null;
      }).whereType<Module>().toList();
    }

    List<Permission>? parsedPermissions;
    if (rawPermissions != null && rawPermissions is List) {
      parsedPermissions = rawPermissions.map((i) {
        try {
          if (i is Map<String, dynamic>) {
            return Permission.fromJson(i);
          }
        } catch (_) {}
        return null;
      }).whereType<Permission>().toList();
    }

    return AppInitializationResponse(
      user: rawUser != null && rawUser is Map<String, dynamic> ? User.fromJson(rawUser) : null,
      dashboardCards: parsedCards,
      modules: parsedModules,
      permissions: parsedPermissions,
      device: rawDevice != null && rawDevice is Map<String, dynamic> ? Device.fromJson(rawDevice) : null,
      configuration: rawConfig != null && rawConfig is Map<String, dynamic> ? AppConfig.fromJson(rawConfig) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'dashboardCards': dashboardCards?.map((e) => e.toJson()).toList(),
      'modules': modules?.map((e) => e.toJson()).toList(),
      'permissions': permissions?.map((e) => e.toJson()).toList(),
      'device': device?.toJson(),
      'configuration': configuration?.toJson(),
    };
  }
}
