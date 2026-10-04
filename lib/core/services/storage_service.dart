import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<StorageService> init() async {
    return this;
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.jwtToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.jwtToken);
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: StorageKeys.jwtToken);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: StorageKeys.userId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: StorageKeys.userId);
  }

  Future<void> saveEmployeeCode(String employeeCode) async {
    await _secureStorage.write(key: StorageKeys.employeeCode, value: employeeCode);
  }

  Future<String?> getEmployeeCode() async {
    return await _secureStorage.read(key: StorageKeys.employeeCode);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
