import 'package:app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final Dio _dio = ApiClient.instance.dio;

  Future<String> subirImagen(XFile file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    final response = await _dio.post('/api/v1/upload', data: formData);
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}
