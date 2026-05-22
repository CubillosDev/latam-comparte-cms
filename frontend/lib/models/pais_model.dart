import 'package:flutter/material.dart';

class PaisModel {
  final String id;
  final String nombre;
  final String codigo;
  final bool activo;

  PaisModel({required this.id, required this.nombre, required this.codigo, required this.activo});

  factory PaisModel.fromJson(Map<String, dynamic> json) => PaisModel(
        id: json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        codigo: json['codigo'] as String,
        activo: json['activo'] as bool? ?? true,
      );

  // Display aliases used by UI widgets
  String get name => nombre;
  String get code => codigo;
  String? get domain => null;

  String get flag {
    const flags = {'CO': '🇨🇴', 'CL': '🇨🇱', 'EC': '🇪🇨'};
    return flags[codigo] ?? '🌍';
  }

  Color get accentColor {
    const colors = {
      'CO': Color(0xFFF59E0B),
      'CL': Color(0xFFDC2626),
      'EC': Color(0xFF0891B2),
    };
    return colors[codigo] ?? const Color(0xFF7C3AC7);
  }
}

class DashboardMetricaPais {
  final PaisModel pais;
  final int solicitudesPendientes;
  final int noticiasActivas;
  final int testimoniosPublicados;

  DashboardMetricaPais({
    required this.pais,
    required this.solicitudesPendientes,
    required this.noticiasActivas,
    required this.testimoniosPublicados,
  });

  factory DashboardMetricaPais.fromJson(Map<String, dynamic> json) => DashboardMetricaPais(
        pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
        solicitudesPendientes: json['solicitudesPendientes'] as int? ?? 0,
        noticiasActivas: json['noticiasActivas'] as int? ?? 0,
        testimoniosPublicados: json['testimoniosPublicados'] as int? ?? 0,
      );
}

class DashboardPais {
  final PaisModel pais;
  final int solicitudesPendientes;
  final int noticiasActivas;
  final int testimoniosPublicados;
  final int totalSolicitudes;

  DashboardPais({
    required this.pais,
    required this.solicitudesPendientes,
    required this.noticiasActivas,
    required this.testimoniosPublicados,
    required this.totalSolicitudes,
  });

  factory DashboardPais.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    return DashboardPais(
      pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      solicitudesPendientes: metrics['solicitudesPendientes'] as int? ?? 0,
      noticiasActivas: metrics['noticiasActivas'] as int? ?? 0,
      testimoniosPublicados: metrics['testimoniosPublicados'] as int? ?? 0,
      totalSolicitudes: metrics['totalSolicitudes'] as int? ?? 0,
    );
  }
}
