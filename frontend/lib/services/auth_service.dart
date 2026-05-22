import 'package:app/models/user_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<LoginResponse> login({required String correo, required String password}) async {
    final response = await _dio.post('/api/v1/auth/login', data: {'correo': correo, 'password': password});
    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw DioException(requestOptions: response.requestOptions, response: response, message: 'Respuesta inválida');
    }
    return LoginResponse.fromJson(data);
  }

  Future<User> me() async {
    final response = await _dio.get('/api/v1/auth/me');
    final data = response.data as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }
}
