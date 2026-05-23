import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  static const _tokenKey = 'auth_token';
  final _storage = const FlutterSecureStorage();
  late final Dio dio;

  // NavigatorKey allows redirecting to /login from outside a BuildContext
  static final navigatorKey = GlobalKey<NavigatorState>();

  void init() {
    dio = Dio(BaseOptions(
      baseUrl: kIsWeb ? 'http://localhost:3000' : (dotenv.env['BASE_URL'] ?? 'http://192.168.1.5:3000'),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid — clear storage and redirect to login
          await _storage.delete(key: _tokenKey);
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (_) => false);
        }
        handler.next(error);
      },
    ));
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
