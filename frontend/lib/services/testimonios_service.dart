import 'package:app/models/testimonio_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class TestimoniosService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TestimonioModel>> listar({String? estado, String? pais}) async {
    final response = await _dio.get('/api/v1/testimonios', queryParameters: {
      if (estado != null) 'estado': estado,
      if (pais != null) 'pais': pais,
    });
    final List list = (response.data as Map<String, dynamic>)['testimonios'] as List;
    return list.map((e) => TestimonioModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TestimonioModel> obtener(String id) async {
    final response = await _dio.get('/api/v1/testimonios/$id');
    return TestimonioModel.fromJson((response.data as Map<String, dynamic>)['testimonio'] as Map<String, dynamic>);
  }

  Future<TestimonioModel> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/testimonios', data: data);
    return TestimonioModel.fromJson((response.data as Map<String, dynamic>)['testimonio'] as Map<String, dynamic>);
  }

  Future<TestimonioModel> actualizar(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/testimonios/$id', data: data);
    return TestimonioModel.fromJson((response.data as Map<String, dynamic>)['testimonio'] as Map<String, dynamic>);
  }

  Future<TestimonioModel> cambiarEstado(String id, String estado) async {
    final response = await _dio.patch('/api/v1/testimonios/$id/estado', data: {'estado': estado});
    return TestimonioModel.fromJson((response.data as Map<String, dynamic>)['testimonio'] as Map<String, dynamic>);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/v1/testimonios/$id');
  }
}
