import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the FastAPI backend.
/// Detects environment: Vercel production, local network (real device), local dev, or Android emulator.
String get _baseUrl {
  if (kIsWeb) {
    final host = Uri.base.host;
    // Local dev on same machine
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:8000';
    }
    // Local network IP (e.g. real device on same Wi-Fi, e.g. 192.168.x.x)
    final isLocalIp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(host);
    if (isLocalIp) {
      return 'http://$host:8000';
    }
    // Production (Vercel/cloud domain): backend served at /api
    return '${Uri.base.scheme}://${Uri.base.host}/api';
  }
  // Android emulator: 10.0.2.2 routes to host machine
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
