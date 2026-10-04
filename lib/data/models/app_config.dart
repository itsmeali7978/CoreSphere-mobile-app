class AppConfig {
  final String companyName;
  final String apiVersion;
  final String defaultLanguage;
  final String dateFormat;
  final String currency;
  final String theme;

  AppConfig({
    required this.companyName,
    required this.apiVersion,
    required this.defaultLanguage,
    required this.dateFormat,
    required this.currency,
    required this.theme,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      companyName: json['companyName'] ?? '',
      apiVersion: json['apiVersion'] ?? '1.0',
      defaultLanguage: json['defaultLanguage'] ?? 'en',
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      currency: json['currency'] ?? '⃁',
      theme: json['theme'] ?? 'Light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'apiVersion': apiVersion,
      'defaultLanguage': defaultLanguage,
      'dateFormat': dateFormat,
      'currency': currency,
      'theme': theme,
    };
  }
}
