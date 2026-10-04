import 'announcement_item.dart';

class DashboardCard {
  final int dashboardCardId;
  final String cardCode;
  final String cardTitle;
  final String? cardDescription;
  final String? iconName;
  final String? iconColor;
  final int displayOrder;
  final String cardType;
  final String cardWidth;
  final String cardHeight;
  final String? cardDisplayStyle;
  final String? dataEndpoint;
  final int? maxItems;
  final bool allowRefresh;
  final List<AnnouncementItem>? items;

  DashboardCard({
    required this.dashboardCardId,
    required this.cardCode,
    required this.cardTitle,
    this.cardDescription,
    this.iconName,
    this.iconColor,
    required this.displayOrder,
    required this.cardType,
    required this.cardWidth,
    required this.cardHeight,
    this.cardDisplayStyle,
    this.dataEndpoint,
    this.maxItems,
    required this.allowRefresh,
    this.items,
  });

  factory DashboardCard.fromJson(Map<String, dynamic> json) {
    var announcementItems = <AnnouncementItem>[];
    final rawItems = json['items'] ?? json['Items'];
    if (rawItems != null && rawItems is List) {
      for (final v in rawItems) {
        try {
          if (v is Map<String, dynamic>) {
            announcementItems.add(AnnouncementItem.fromJson(v));
          }
        } catch (_) {}
      }
    }

    final rawId = json['dashboardCardId'] ?? json['DashboardCardId'] ?? json['id'] ?? json['Id'] ?? 0;

    return DashboardCard(
      dashboardCardId: rawId is int ? rawId : int.parse(rawId.toString()),
      cardCode: (json['cardCode'] ?? json['CardCode'] ?? '').toString(),
      cardTitle: (json['cardTitle'] ?? json['CardTitle'] ?? '').toString(),
      cardDescription: (json['cardDescription'] ?? json['CardDescription'])?.toString(),
      iconName: (json['iconName'] ?? json['IconName'])?.toString(),
      iconColor: (json['iconColor'] ?? json['IconColor'])?.toString(),
      displayOrder: (json['displayOrder'] ?? json['DisplayOrder']) as int? ?? 0,
      cardType: (json['cardType'] ?? json['CardType'] ?? 'METRIC').toString(),
      cardWidth: (json['cardWidth'] ?? json['CardWidth'] ?? 'HALF').toString(),
      cardHeight: (json['cardHeight'] ?? json['CardHeight'] ?? 'SMALL').toString(),
      cardDisplayStyle: (json['cardDisplayStyle'] ?? json['CardDisplayStyle'])?.toString(),
      dataEndpoint: (json['dataEndpoint'] ?? json['DataEndpoint'])?.toString(),
      maxItems: json['maxItems'] ?? json['MaxItems'],
      allowRefresh: (json['allowRefresh'] ?? json['AllowRefresh']) as bool? ?? true,
      items: announcementItems.isNotEmpty ? announcementItems : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboardCardId': dashboardCardId,
      'cardCode': cardCode,
      'cardTitle': cardTitle,
      'cardDescription': cardDescription,
      'iconName': iconName,
      'iconColor': iconColor,
      'displayOrder': displayOrder,
      'cardType': cardType,
      'cardWidth': cardWidth,
      'cardHeight': cardHeight,
      'cardDisplayStyle': cardDisplayStyle,
      'dataEndpoint': dataEndpoint,
      'maxItems': maxItems,
      'allowRefresh': allowRefresh,
      'items': items?.map((v) => v.toJson()).toList(),
    };
  }
}
