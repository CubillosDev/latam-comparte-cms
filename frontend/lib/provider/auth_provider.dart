import 'package:app/models/user_model.dart';
import 'package:app/services/api_client.dart';
import 'package:app/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.idle;
  User? _user;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> tryAutoLogin() async {
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      _status = AuthStatus.idle;
      notifyListeners();
      return;
    }
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      _user = await _authService.me();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await ApiClient.instance.deleteToken();
      _status = AuthStatus.idle;
    }
    notifyListeners();
  }

  Future<bool> login({required String correo, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(correo: correo, password: password);
      await ApiClient.instance.saveToken(response.token);
      _user = response.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      _errorMessage = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Error al conectar con el servidor';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado. Intenta de nuevo.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.deleteToken();
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
