import 'package:app/services/reportes_service.dart';
import 'package:flutter/foundation.dart';

enum ReportesLoadState { idle, loading, loaded, error }

class ReportesProvider extends ChangeNotifier {
  final ReportesService _service = ReportesService();

  ReportesLoadState _state = ReportesLoadState.idle;
  ReporteData? _data;
  String? _error;

  ReportesLoadState get state => _state;
  ReporteData? get data => _data;
  String? get error => _error;

  Future<void> cargar() async {
    _state = ReportesLoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.obtener();
      _state = ReportesLoadState.loaded;
    } catch (_) {
      _error = 'Error al cargar reportes';
      _state = ReportesLoadState.error;
    }
    notifyListeners();
  }
}
