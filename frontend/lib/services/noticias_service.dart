import 'package:app/models/noticia_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class NoticiasService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<NoticiaModel>> listar({String? estado, String? pais}) async {
    final response = await _dio.get('/api/v1/noticias', queryParameters: {
      if (estado != null) 'estado': estado,
      if (pais != null) 'pais': pais,
    });
    final List list = (response.data as Map<String, dynamic>)['noticias'] as List;
    return list.map((e) => NoticiaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<NoticiaModel> obtener(String id) async {
    final response = await _dio.get('/api/v1/noticias/$id');
    return NoticiaModel.fromJson((response.data as Map<String, dynamic>)['noticia'] as Map<String, dynamic>);
  }

  Future<NoticiaModel> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/noticias', data: data);
    return NoticiaModel.fromJson((response.data as Map<String, dynamic>)['noticia'] as Map<String, dynamic>);
  }

  Future<NoticiaModel> actualizar(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/noticias/$id', data: data);
    return NoticiaModel.fromJson((response.data as Map<String, dynamic>)['noticia'] as Map<String, dynamic>);
  }

  Future<NoticiaModel> cambiarEstado(String id, String estado) async {
    final response = await _dio.patch('/api/v1/noticias/$id/estado', data: {'estado': estado});
    return NoticiaModel.fromJson((response.data as Map<String, dynamic>)['noticia'] as Map<String, dynamic>);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/v1/noticias/$id');
  }
}
