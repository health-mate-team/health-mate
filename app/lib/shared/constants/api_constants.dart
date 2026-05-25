import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return kIsWeb
        ? 'http://43.201.67.1:3001/api'
        : 'http://43.201.67.1:3001/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
