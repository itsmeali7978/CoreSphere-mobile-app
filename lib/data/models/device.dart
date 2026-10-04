class Device {
  final String deviceId;
  final String? deviceName;
  final String? deviceType;
  final String? appVersion;
  final String? lastLogin;

  Device({
    required this.deviceId,
    this.deviceName,
    this.deviceType,
    this.appVersion,
    this.lastLogin,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      appVersion: json['appVersion'],
      lastLogin: json['lastLogin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'appVersion': appVersion,
      'lastLogin': lastLogin,
    };
  }
}
