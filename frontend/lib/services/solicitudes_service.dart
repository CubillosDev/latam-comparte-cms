import 'package:app/models/solicitud_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class SolicitudesService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<SolicitudModel>> listar({String? estado, String? pais}) async {
    final response = await _dio.get('/api/v1/solicitudes', queryParameters: {
      if (estado != null) 'estado': estado,
      if (pais != null) 'pais': pais,
    });
    final List list = (response.data as Map<String, dynamic>)['solicitudes'] as List;
    return list.map((e) => SolicitudModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SolicitudModel> obtener(String id) async {
    final response = await _dio.get('/api/v1/solicitudes/$id');
    return SolicitudModel.fromJson((response.data as Map<String, dynamic>)['solicitud'] as Map<String, dynamic>);
  }

  Future<void> cambiarEstado(String id, String estado) async {
    await _dio.patch('/api/v1/solicitudes/$id/estado', data: {'estado': estado});
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/v1/solicitudes/$id');
  }

  // Endpoint público sin autenticación
  Future<void> enviarPublica({
    required String nombre,
    required String correo,
    required String telefono,
    required String finalidad,
    required String paisId,
  }) async {
    await _dio.post('/api/v1/solicitudes/publico', data: {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'finalidad': finalidad,
      'pais': paisId,
    });
  }
}
