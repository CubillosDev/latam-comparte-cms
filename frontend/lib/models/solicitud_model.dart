import 'package:app/core/enums.dart';
import 'package:app/models/pais_model.dart';
import 'package:flutter/material.dart';

class SolicitudModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String finalidad;
  final PaisModel pais;
  final String estado;
  final DateTime fechaCreacion;

  SolicitudModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.finalidad,
    required this.pais,
    required this.estado,
    required this.fechaCreacion,
  });

  bool get isPendiente => estado == 'pendiente';
  bool get isGestionada => estado == 'gestionada';
  bool get isRespondida => estado == 'respondida';

  // ── UI display properties ──────────────────────────────────────────────────

  SolicitudStatus get status {
    switch (estado) {
      case 'gestionada':
        return SolicitudStatus.gestionada;
      case 'respondida':
        return SolicitudStatus.respondida;
      default:
        return SolicitudStatus.pendiente;
    }
  }

  String get name => nombre;
  String get email => correo;
  String get phone => telefono;
  String get message => finalidad;
  String get country => pais.nombre;
  String get countryCode => pais.codigo;
  String get flag => pais.flag;
  String get city => pais.nombre;

  String get initials {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A';
  }

  Color get avatarStart => pais.accentColor;
  Color get avatarEnd => HSLColor.fromColor(pais.accentColor).withLightness(0.4).toColor();

  Color get codeTextColor => pais.accentColor;
  Color get codeBgColor => pais.accentColor.withValues(alpha: 0.1);

  String get receivedTime {
    final diff = DateTime.now().difference(fechaCreacion);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} días';
  }

  String get receivedDate {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fechaCreacion.day} de ${months[fechaCreacion.month - 1]} de ${fechaCreacion.year}';
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  factory SolicitudModel.fromJson(Map<String, dynamic> json) => SolicitudModel(
        id: json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        telefono: json['telefono'] as String,
        finalidad: json['finalidad'] as String,
        pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
        estado: json['estado'] as String,
        fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      );
}
