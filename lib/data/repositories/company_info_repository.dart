import 'dart:convert';
import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../core/services/prefs_service.dart';
import '../models/company_info.dart';

class CompanyInfoRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final PrefsService _prefsService = Get.find<PrefsService>();
  
  static const String _storageKey = 'cached_company_info';

  Future<CompanyInfo> getCompanyInfo() async {
    try {
      final response = await _apiClient.get('/company-info');
      if (response.data != null && response.data['success'] == true && response.data['data'] != null) {
        final info = CompanyInfo.fromJson(response.data['data']);
        await _prefsService.sharedPreferences.setString(_storageKey, jsonEncode(info.toJson()));
        return info;
      }
    } catch (e) {
      // Ignore network failure and try reading from cache
    }

    final cachedStr = _prefsService.sharedPreferences.getString(_storageKey);
    if (cachedStr != null) {
      try {
        final Map<String, dynamic> cached = jsonDecode(cachedStr);
        return CompanyInfo.fromJson(cached);
      } catch (_) {}
    }

    return CompanyInfo.defaultCompanyInfo();
  }
}
