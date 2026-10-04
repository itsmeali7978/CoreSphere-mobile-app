class AnnouncementItem {
  final int announcementId;
  final String cardCode;
  final String title;
  final String? shortDescription;
  final String? fullDescription;
  final String? imageUrl;
  final int displayOrder;
  final int priority;
  final int? targetRoleId;
  final int? targetModuleId;
  final String startDate;
  final String endDate;
  final bool isActive;
  final String actionType;
  final String? actionValue;

  AnnouncementItem({
    required this.announcementId,
    required this.cardCode,
    required this.title,
    this.shortDescription,
    this.fullDescription,
    this.imageUrl,
    required this.displayOrder,
    required this.priority,
    this.targetRoleId,
    this.targetModuleId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.actionType,
    this.actionValue,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      announcementId: json['announcementId'],
      cardCode: json['cardCode'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      imageUrl: json['imageUrl'],
      displayOrder: json['displayOrder'] ?? 1,
      priority: json['priority'] ?? 1,
      targetRoleId: json['targetRoleId'],
      targetModuleId: json['targetModuleId'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? true,
      actionType: json['actionType'] ?? 'NONE',
      actionValue: json['actionValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcementId': announcementId,
      'cardCode': cardCode,
      'title': title,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'priority': priority,
      'targetRoleId': targetRoleId,
      'targetModuleId': targetModuleId,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'actionType': actionType,
      'actionValue': actionValue,
    };
  }
}
