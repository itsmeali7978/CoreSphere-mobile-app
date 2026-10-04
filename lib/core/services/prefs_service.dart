import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/api_response.dart';

class PrefsService extends GetxService {
  late SharedPreferences _prefs;

  SharedPreferences get sharedPreferences => _prefs;

  Future<PrefsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveAppInitializationData(AppInitializationResponse data) async {
    final jsonString = jsonEncode(data.toJson());
    await _prefs.setString(StorageKeys.userProfile, jsonString);
  }

  AppInitializationResponse? getAppInitializationData() {
    final jsonString = _prefs.getString(StorageKeys.userProfile);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return AppInitializationResponse.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String getOrCreateDeviceUid() {
    String? uid = _prefs.getString('device_unique_id');
    if (uid == null || uid.isEmpty) {
      uid = 'DEV-FLUTTER-${DateTime.now().millisecondsSinceEpoch}-${(1000 + (DateTime.now().microsecond % 9000))}';
      _prefs.setString('device_unique_id', uid);
    }
    return uid;
  }

  Future<void> clearPrefs() async {
    final String? deviceUid = _prefs.getString('device_unique_id');
    final String? lang = _prefs.getString(StorageKeys.language);
    await _prefs.clear();
    if (deviceUid != null) await _prefs.setString('device_unique_id', deviceUid);
    if (lang != null) await _prefs.setString(StorageKeys.language, lang);
  }

  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(StorageKeys.language, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(StorageKeys.language) ?? 'en';
  }
}
