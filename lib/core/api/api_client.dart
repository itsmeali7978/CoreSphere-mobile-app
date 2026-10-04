import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/prefs_service.dart';
import '../services/logger_service.dart';
import '../routes/app_pages.dart';
import '../utils/app_toast.dart';

class ApiClient {
  late Dio _dio;
  final StorageService _storageService = getx.Get.find<StorageService>();
  final AppLogger _logger = getx.Get.find<AppLogger>();

  ApiClient() {
    BaseOptions options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: ApiConstants.timeoutInSeconds),
      receiveTimeout: const Duration(seconds: ApiConstants.timeoutInSeconds),
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);
    _dio.interceptors.add(_getInterceptors());
  }

  InterceptorsWrapper _getInterceptors() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        _logger.debug('API Request: [${options.method}] ${options.uri}');
        if (options.data != null) {
          _logger.trace('Request Data: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.debug('API Response: [${response.statusCode}] ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('====== RAW ERROR DATA ======');
        print(e.response?.data);
        print('============================');
        _logger.error('API Error: [${e.response?.statusCode}] ${e.requestOptions.uri}\nResponse: ${e.response?.data}', e.message, e.stackTrace);
        
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/login')) {
          _handleUnauthorized();
        }
        
        return handler.next(e);
      },
    );
  }

  void _handleUnauthorized() {
    _logger.warning('Unauthorized request (401). Logging out user and clearing session.');
    
    final bool isAlreadyOnLoginRoute = getx.Get.currentRoute == RouteNames.login;

    // Clear secure storage and shared preferences
    _storageService.clearAll();
    getx.Get.find<PrefsService>().clearPrefs();
    
    // Redirect to login and clear navigation stack FIRST
    if (!isAlreadyOnLoginRoute) {
      getx.Get.offAllNamed(RouteNames.login);

      // Show session expired notification ONLY when navigating away from an active session
      Future.delayed(const Duration(milliseconds: 300), () {
        AppToast.show('Session Expired. Please login again.', backgroundColor: Colors.redAccent);
      });
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return await _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
