import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final Dio _dio = ApiClient.instance.dio;

  Future<String> subirImagen(XFile file) async {
    // readAsBytes() funciona con content:// URIs de Android y paths normales
    final bytes = await file.readAsBytes();
    final filename = file.name.isNotEmpty ? file.name : 'imagen.jpg';
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post('/api/v1/upload', data: formData);
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}
