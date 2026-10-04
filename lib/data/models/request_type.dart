class RequestType {
  final int requestTypeId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;

  RequestType({
    required this.requestTypeId,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory RequestType.fromJson(Map<String, dynamic> json) {
    return RequestType(
      requestTypeId: json['requestTypeId'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestTypeId': requestTypeId,
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
