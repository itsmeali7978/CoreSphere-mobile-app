class Module {
  final int moduleId;
  final String moduleCode;
  final String moduleName;
  final int moduleCategoryId;
  final String moduleCategoryName;
  final String? iconName;
  final int displayOrder;
  final String? routeName;
  final String? platform;

  Module({
    required this.moduleId,
    required this.moduleCode,
    required this.moduleName,
    required this.moduleCategoryId,
    required this.moduleCategoryName,
    this.iconName,
    required this.displayOrder,
    this.routeName,
    this.platform,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleId: json['moduleId'],
      moduleCode: json['moduleCode'],
      moduleName: json['moduleName'],
      moduleCategoryId: json['moduleCategoryId'],
      moduleCategoryName: json['moduleCategoryName'],
      iconName: json['iconName'],
      displayOrder: json['displayOrder'] ?? 0,
      routeName: json['routeName'],
      platform: json['platform'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'moduleCode': moduleCode,
      'moduleName': moduleName,
      'moduleCategoryId': moduleCategoryId,
      'moduleCategoryName': moduleCategoryName,
      'iconName': iconName,
      'displayOrder': displayOrder,
      'routeName': routeName,
      'platform': platform,
    };
  }

  bool get isVisibleOnMobile {
    if (platform == null || platform!.trim().isEmpty) return true;
    final p = platform!.toLowerCase().trim();
    if (p == 'web' || p == 'web only') return false;
    return true;
  }
}
