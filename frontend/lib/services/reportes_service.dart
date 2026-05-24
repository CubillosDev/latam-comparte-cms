import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';

class ReporteData {
  final Map<String, int> solicitudes;
  final Map<String, int> noticias;
  final Map<String, int> testimonios;
  final List<Map<String, dynamic>>? porPais;

  const ReporteData({
    required this.solicitudes,
    required this.noticias,
    required this.testimonios,
    this.porPais,
  });

  factory ReporteData.fromJson(Map<String, dynamic> json) {
    Map<String, int> toIntMap(Map<String, dynamic>? m) =>
        (m ?? {}).map((k, v) => MapEntry(k, (v as num).toInt()));

    return ReporteData(
      solicitudes: toIntMap(json['solicitudes'] as Map<String, dynamic>?),
      noticias: toIntMap(json['noticias'] as Map<String, dynamic>?),
      testimonios: toIntMap(json['testimonios'] as Map<String, dynamic>?),
      porPais: json['porPais'] != null
          ? (json['porPais'] as List).cast<Map<String, dynamic>>()
          : null,
    );
  }
}

class ReportesService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ReporteData> obtener() async {
    final response = await _dio.get('/api/v1/reportes');
    return ReporteData.fromJson(
      (response.data as Map<String, dynamic>)['reportes']
          as Map<String, dynamic>,
    );
  }
}
