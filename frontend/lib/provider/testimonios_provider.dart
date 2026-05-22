import 'package:app/models/testimonio_model.dart';
import 'package:app/services/testimonios_service.dart';
import 'package:flutter/foundation.dart';

enum TestimoniosLoadState { idle, loading, loaded, error }

class TestimoniosProvider extends ChangeNotifier {
  final TestimoniosService _service = TestimoniosService();

  TestimoniosLoadState _state = TestimoniosLoadState.idle;
  List<TestimonioModel> _testimonios = [];
  String? _error;

  TestimoniosLoadState get state => _state;
  List<TestimonioModel> get testimonios => _testimonios;
  String? get error => _error;

  Future<void> cargar({String? estado, String? pais}) async {
    _setLoading();
    try {
      _testimonios = await _service.listar(estado: estado, pais: pais);
      _state = TestimoniosLoadState.loaded;
    } catch (_) {
      _setError('Error al cargar testimonios');
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    try {
      final nuevo = await _service.crear(data);
      _testimonios = [nuevo, ..._testimonios];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizar(String id, Map<String, dynamic> data) async {
    try {
      final actualizado = await _service.actualizar(id, data);
      _testimonios = _testimonios.map((t) => t.id == id ? actualizado : t).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final actualizado = await _service.cambiarEstado(id, nuevoEstado);
      _testimonios = _testimonios.map((t) => t.id == id ? actualizado : t).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _service.eliminar(id);
      _testimonios = _testimonios.where((t) => t.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setLoading() {
    _state = TestimoniosLoadState.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _state = TestimoniosLoadState.error;
  }
}
