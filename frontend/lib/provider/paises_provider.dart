import 'package:app/models/pais_model.dart';
import 'package:app/services/paises_service.dart';
import 'package:flutter/foundation.dart';

enum PaisesLoadState { idle, loading, loaded, error }

class PaisesProvider extends ChangeNotifier {
  final PaisesService _service = PaisesService();

  PaisesLoadState _state = PaisesLoadState.idle;
  List<PaisModel> _paises = [];
  List<DashboardMetricaPais> _metricasGlobal = [];
  DashboardPais? _dashboardPais;
  String? _error;

  PaisesLoadState get state => _state;
  List<PaisModel> get paises => _paises;
  List<DashboardMetricaPais> get metricasGlobal => _metricasGlobal;
  DashboardPais? get dashboardPais => _dashboardPais;
  String? get error => _error;

  Future<void> cargarPaises() async {
    _setLoading();
    try {
      _paises = await _service.listar();
      _state = PaisesLoadState.loaded;
    } catch (e) {
      _setError('Error al cargar países');
    }
    notifyListeners();
  }

  Future<void> cargarDashboardSuperAdmin() async {
    _setLoading();
    try {
      _metricasGlobal = await _service.dashboardSuperAdmin();
      _state = PaisesLoadState.loaded;
    } catch (e) {
      _setError('Error al cargar métricas globales');
    }
    notifyListeners();
  }

  Future<void> cargarDashboardPais() async {
    _setLoading();
    try {
      _dashboardPais = await _service.dashboardPais();
      _state = PaisesLoadState.loaded;
    } catch (e) {
      _setError('Error al cargar métricas del país');
    }
    notifyListeners();
  }

  void _setLoading() {
    _state = PaisesLoadState.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _state = PaisesLoadState.error;
  }
}
