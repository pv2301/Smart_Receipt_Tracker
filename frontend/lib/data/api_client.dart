import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the FastAPI backend.
/// Detects if running on Web or Android Emulator automatically.
String get _baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000'; // Standard for Web
  }
  // If not web, assume Android Emulator (or you can add more checks for iOS/Real devices)
  return 'http://10.0.2.2:8000';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Request/response logger in debug mode
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ),
  );

  return dio;
});
