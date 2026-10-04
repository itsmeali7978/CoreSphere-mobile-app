class DataTranslation {
  final String key;
  final String english;
  final String arabic;
  final String? useType;

  DataTranslation({
    required this.key,
    required this.english,
    required this.arabic,
    this.useType,
  });

  factory DataTranslation.fromJson(Map<String, dynamic> json) {
    return DataTranslation(
      key: json['key'] ?? json['Key'] ?? '',
      english: json['english'] ?? json['English'] ?? '',
      arabic: json['arabic'] ?? json['Arabic'] ?? '',
      useType: json['useType'] ?? json['UseType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'english': english,
      'arabic': arabic,
      'useType': useType,
    };
  }

  String get bilingualCaption => '$english / $arabic';
}
