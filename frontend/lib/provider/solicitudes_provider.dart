import 'package:app/models/solicitud_model.dart';
import 'package:app/services/solicitudes_service.dart';
import 'package:flutter/foundation.dart';

enum SolicitudesLoadState { idle, loading, loaded, error }

class SolicitudesProvider extends ChangeNotifier {
  final SolicitudesService _service = SolicitudesService();

  SolicitudesLoadState _state = SolicitudesLoadState.idle;
  List<SolicitudModel> _solicitudes = [];
  String? _error;

  SolicitudesLoadState get state => _state;
  List<SolicitudModel> get solicitudes => _solicitudes;
  String? get error => _error;

  Future<void> cargar({String? estado, String? pais}) async {
    _setLoading();
    try {
      _solicitudes = await _service.listar(estado: estado, pais: pais);
      _state = SolicitudesLoadState.loaded;
    } catch (_) {
      _setError('Error al cargar solicitudes');
    }
    notifyListeners();
  }

  Future<bool> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final actualizada = await _service.cambiarEstado(id, nuevoEstado);
      _solicitudes = _solicitudes.map((s) => s.id == id ? actualizada : s).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _service.eliminar(id);
      _solicitudes = _solicitudes.where((s) => s.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setLoading() {
    _state = SolicitudesLoadState.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _state = SolicitudesLoadState.error;
  }
}
