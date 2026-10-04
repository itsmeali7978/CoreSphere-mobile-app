import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/services/prefs_service.dart';
import '../models/api_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/change_password_request.dart';

class AuthenticationRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<ApiResponse<LoginResponse>> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      final response = await _apiClient.post(ApiConstants.login, data: request.toJson());
      
      return ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json),
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          return ApiResponse<LoginResponse>.fromJson(
            e.response!.data,
            (json) => LoginResponse.fromJson(json),
          );
        } catch (_) {}
      }
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Invalid username or password.',
      );
    } catch (_) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Invalid username or password.',
      );
    }
  }

  Future<ApiResponse<AppInitializationResponse>> initialize() async {
    try {
      final response = await _apiClient.get(ApiConstants.initialize);
      
      return ApiResponse<AppInitializationResponse>.fromJson(
        response.data,
        (json) => AppInitializationResponse.fromJson(json),
      );
    } catch (e) {
      return ApiResponse<AppInitializationResponse>(
        success: false,
        message: 'Failed to initialize application context.',
      );
    }
  }

  Future<ApiResponse<AppInitializationResponse>> refresh() async {
    try {
      final response = await _apiClient.get(ApiConstants.refresh);
      
      return ApiResponse<AppInitializationResponse>.fromJson(
        response.data,
        (json) => AppInitializationResponse.fromJson(json),
      );
    } catch (e) {
      return ApiResponse<AppInitializationResponse>(
        success: false,
        message: 'Failed to refresh session context.',
      );
    }
  }

  Future<ApiResponse<bool>> logout() async {
    try {
      final deviceUid = await _getDeviceUid();
      final response = await _apiClient.post('/auth/logout', data: {
        'deviceUid': deviceUid,
      });
      
      return ApiResponse<bool>.fromJson(
        response.data,
        (json) => json as bool? ?? true,
      );
    } catch (_) {
      return ApiResponse<bool>(success: true, data: true, message: 'Logged out locally.');
    }
  }

  /// Changes the logged-in user's password
  Future<ApiResponse<bool>> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/change-password',
        data: request.toJson(),
      );
      
      return ApiResponse<bool>.fromJson(
        response.data,
        (data) => data as bool? ?? false,
      );
    } on DioException catch (e) {
      String errMsg = 'Failed to change password.';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('message') && data['message'] != null) {
              errMsg = data['message'].toString();
            } else if (data.containsKey('errors') && data['errors'] != null) {
              final errors = data['errors'];
              if (errors is Map<String, dynamic>) {
                final errorMessages = <String>[];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.map((v) => v.toString()));
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                if (errorMessages.isNotEmpty) {
                  errMsg = errorMessages.join('\n');
                }
              } else if (errors is List) {
                errMsg = errors.join('\n');
              }
            }
          }
        } catch (_) {}
      }
      return ApiResponse<bool>(
        success: false,
        message: errMsg,
      );
    } catch (_) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to change password.',
      );
    }
  }

  Future<void> registerDevice(String fcmToken) async {
    try {
      final deviceUid = await _getDeviceUid();
      final deviceName = 'Flutter Device'; 
      final data = {
        'deviceUid': deviceUid,
        'fcmToken': fcmToken,
        'deviceName': deviceName,
      };
      await _apiClient.post('/auth/device', data: data);
    } catch (e) {
      // Silently fail as this is not critical for login
    }
  }

  Future<String> _getDeviceUid() async {
    try {
      if (Get.isRegistered<PrefsService>()) {
        return Get.find<PrefsService>().getOrCreateDeviceUid();
      }
    } catch (_) {}
    return 'DEV-FLUTTER-GENERIC';
  }

  Future<ApiResponse<String>> uploadProfileImage(String filepath) async {
    try {
      final fileName = filepath.split('/').last;
      final formData = FormData.fromMap({
        'imageFile': await MultipartFile.fromFile(
          filepath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '/employees/profile-image',
        data: formData,
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data as String? ?? '',
      );
    } on DioException catch (e) {
      String errMsg = 'Failed to upload profile image.';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('message') && data['message'] != null) {
              errMsg = data['message'].toString();
            } else if (data.containsKey('errors') && data['errors'] != null) {
              final errors = data['errors'];
              if (errors is Map<String, dynamic>) {
                final errorMessages = <String>[];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.map((v) => v.toString()));
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                if (errorMessages.isNotEmpty) {
                  errMsg = errorMessages.join('\n');
                }
              } else if (errors is List) {
                errMsg = errors.join('\n');
              }
            }
          }
        } catch (_) {}
      }
      return ApiResponse<String>(
        success: false,
        message: errMsg,
      );
    } catch (_) {
      return ApiResponse<String>(
        success: false,
        message: 'Failed to upload profile image.',
      );
    }
  }
}
