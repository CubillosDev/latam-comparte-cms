import 'package:app/models/usuario_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class UsuariosService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<UsuarioModel>> listar() async {
    final response = await _dio.get('/api/v1/usuarios');
    final List list =
        (response.data as Map<String, dynamic>)['usuarios'] as List;
    return list
        .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UsuarioModel> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/usuarios', data: data);
    return UsuarioModel.fromJson(
      (response.data as Map<String, dynamic>)['usuario']
          as Map<String, dynamic>,
    );
  }

  Future<UsuarioModel> actualizar(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/usuarios/$id', data: data);
    return UsuarioModel.fromJson(
      (response.data as Map<String, dynamic>)['usuario']
          as Map<String, dynamic>,
    );
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/v1/usuarios/$id');
  }
}
