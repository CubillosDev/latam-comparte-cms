import 'package:app/models/usuario_model.dart';
import 'package:app/services/usuarios_service.dart';
import 'package:flutter/foundation.dart';

enum UsuariosLoadState { idle, loading, loaded, error }

class UsuariosProvider extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  UsuariosLoadState _state = UsuariosLoadState.idle;
  List<UsuarioModel> _usuarios = [];
  String? _error;

  UsuariosLoadState get state => _state;
  List<UsuarioModel> get usuarios => _usuarios;
  String? get error => _error;

  Future<void> cargar() async {
    _state = UsuariosLoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _usuarios = await _service.listar();
      _state = UsuariosLoadState.loaded;
    } catch (_) {
      _error = 'Error al cargar usuarios';
      _state = UsuariosLoadState.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Map<String, dynamic> data) async {
    try {
      final nuevo = await _service.crear(data);
      _usuarios = [nuevo, ..._usuarios];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizar(String id, Map<String, dynamic> data) async {
    try {
      final actualizado = await _service.actualizar(id, data);
      _usuarios = _usuarios.map((u) => u.id == id ? actualizado : u).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _service.eliminar(id);
      _usuarios = _usuarios.where((u) => u.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
