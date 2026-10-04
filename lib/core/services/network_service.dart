import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_toast.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;

  Future<NetworkService> init() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });
    
    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    bool hasConnection = !results.contains(ConnectivityResult.none);
    
    if (isOnline.value != hasConnection) {
      isOnline.value = hasConnection;
      
      if (!hasConnection) {
        AppToast.show(
          'Offline: You are currently offline. Please check your internet connection.',
          backgroundColor: Colors.redAccent,
        );
      } else {
        AppToast.show(
          'Online: Internet connection restored.',
          backgroundColor: Colors.green,
        );
      }
    }
  }
}
