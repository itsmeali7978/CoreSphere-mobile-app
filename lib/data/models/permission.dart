class Permission {
  final String moduleCode;
  final String permissionCode;
  final String permissionName;
  final bool isAllowed;

  Permission({
    required this.moduleCode,
    required this.permissionCode,
    required this.permissionName,
    required this.isAllowed,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      moduleCode: json['moduleCode'],
      permissionCode: json['permissionCode'],
      permissionName: json['permissionName'],
      isAllowed: json['isAllowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleCode': moduleCode,
      'permissionCode': permissionCode,
      'permissionName': permissionName,
      'isAllowed': isAllowed,
    };
  }
}
