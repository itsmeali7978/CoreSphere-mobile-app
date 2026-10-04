class LoginResponse {
  final int userId;
  final String username;
  final String employeeCode;
  final String token;

  LoginResponse({
    required this.userId,
    required this.username,
    required this.employeeCode,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      username: json['username'],
      employeeCode: json['employeeCode'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'employeeCode': employeeCode,
      'token': token,
    };
  }
}
