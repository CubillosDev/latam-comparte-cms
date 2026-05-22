import 'package:app/models/pais_model.dart';
import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class PaisesService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<PaisModel>> listar() async {
    final response = await _dio.get('/api/v1/paises');
    final List list = (response.data as Map<String, dynamic>)['paises'] as List;
    return list.map((e) => PaisModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DashboardMetricaPais>> dashboardSuperAdmin() async {
    final response = await _dio.get('/api/v1/paises/dashboard');
    final List list = (response.data as Map<String, dynamic>)['metrics'] as List;
    return list.map((e) => DashboardMetricaPais.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DashboardPais> dashboardPais() async {
    final response = await _dio.get('/api/v1/paises/dashboard/pais');
    return DashboardPais.fromJson(response.data as Map<String, dynamic>);
  }
}
