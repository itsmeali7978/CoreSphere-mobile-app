import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger extends GetxService {
  late Logger _logger;

  Future<AppLogger> init() async {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kReleaseMode ? Level.warning : Level.trace,
    );
    return this;
  }

  void trace(dynamic message) {
    if (!kReleaseMode) _logger.t(message);
  }

  void debug(dynamic message) {
    if (!kReleaseMode) _logger.d(message);
  }

  void info(dynamic message) {
    _logger.i(message);
  }

  void warning(dynamic message) {
    _logger.w(message);
  }

  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
