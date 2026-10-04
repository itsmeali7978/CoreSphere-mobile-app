class ApiConstants {
  // Use a base URL that can be easily changed for dev/prod
  // For android emulator accessing localhost, use 10.0.2.2
  // For iOS simulator, use localhost or 127.0.0.1
  
  // Developemnt-EC2-My Free AWS / EC2 setup
  //static const String baseUrl = 'http://34.233.124.123/api/v1.0';

  // Production-EC2-Company AWS / EC2 setup
 static const String baseUrl = 'https://coresphere.housecare.sa/api/v1.0';
  
  // Local Staging setup
  //static const String baseUrl = 'http://192.168.105.254:8085/api/v1.0';
  
  static const String login = '/auth/login';
  static const String initialize = '/app/initialize';
  static const String refresh = '/app/refresh';
  static const String customers = '/customers';
  static const String employees = '/employees';
  
  static const int timeoutInSeconds = 30;
}
