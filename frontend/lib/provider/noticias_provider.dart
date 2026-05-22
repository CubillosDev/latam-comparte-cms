import 'package:app/models/noticia_model.dart';
import 'package:app/services/noticias_service.dart';
import 'package:flutter/foundation.dart';

enum NoticiasLoadState { idle, loading, loaded, error }

class NoticiasProvider extends ChangeNotifier {
  final NoticiasService _service = NoticiasService();

  NoticiasLoadState _state = NoticiasLoadState.idle;
  List<NoticiaModel> _noticias = [];
  String? _error;

  NoticiasLoadState get state => _state;
  List<NoticiaModel> get noticias => _noticias;
  String? get error => _error;

  Future<void> cargar({String? estado, String? pais}) async {
    _setLoading();
    try {
      _noticias = await _service.listar(estado: estado, pais: pais);
      _state = NoticiasLoadState.loaded;
    } catch (_) {
      _setError('Error al cargar noticias');
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    try {
      final nueva = await _service.crear(data);
      _noticias = [nueva, ..._noticias];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final actualizada = await _service.cambiarEstado(id, nuevoEstado);
      _noticias = _noticias.map((n) => n.id == id ? actualizada : n).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _service.eliminar(id);
      _noticias = _noticias.where((n) => n.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setLoading() {
    _state = NoticiasLoadState.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _state = NoticiasLoadState.error;
  }
}
