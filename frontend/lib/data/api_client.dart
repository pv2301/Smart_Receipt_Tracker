import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL de produção do backend no Vercel.
const _kProductionApiUrl = 'https://notinha.vercel.app/api';

/// Base URL for the FastAPI backend.
/// Web: detecta host para distinguir local dev / produção.
/// Mobile: usa sempre a URL de produção do Vercel.
/// Para testar localmente com dispositivo físico, troque _kProductionApiUrl
/// pelo IP da sua máquina, ex: 'http://192.168.0.x:8000'.
String get _baseUrl {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:8000';
    }
    final isLocalIp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(host);
    if (isLocalIp) {
      return 'http://$host:8000';
    }
    return '${Uri.base.scheme}://${Uri.base.host}/api';
  }
  // Dispositivo físico ou emulador → produção Vercel
  return _kProductionApiUrl;
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
