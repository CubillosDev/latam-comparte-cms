import 'package:app/core/enums.dart';
import 'package:app/models/pais_model.dart';
import 'package:flutter/material.dart';

class TestimonioModel {
  final String id;
  final String nombre;
  final String fotoUrl;
  final String testimonio;
  final PaisModel pais;
  final String? instagramUrl;
  final String? facebookUrl;
  final String estado;
  final DateTime fechaCreacion;

  TestimonioModel({
    required this.id,
    required this.nombre,
    required this.fotoUrl,
    required this.testimonio,
    required this.pais,
    this.instagramUrl,
    this.facebookUrl,
    required this.estado,
    required this.fechaCreacion,
  });

  bool get isPublicado => estado == 'publicado';
  bool get isBorrador => estado == 'borrador';
  bool get isDespublicado => estado == 'despublicado';

  // ── UI display properties ──────────────────────────────────────────────────

  BadgeStatus get status {
    if (estado == 'publicado') return BadgeStatus.published;
    if (estado == 'despublicado') return BadgeStatus.unpublished;
    return BadgeStatus.draft;
  }

  bool get isVisible => isPublicado;

  String get name => nombre;
  String get quote => testimonio;
  String get role => '';
  String get city => pais.nombre;

  String get date {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fechaCreacion.day} ${months[fechaCreacion.month - 1]} ${fechaCreacion.year}';
  }

  String get initials {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A';
  }

  Color get avatarColor {
    const colors = [
      Color(0xFF7C3AC7),
      Color(0xFF1D4ED8),
      Color(0xFF15803D),
      Color(0xFFDC2626),
    ];
    return colors[nombre.length % colors.length];
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  factory TestimonioModel.fromJson(Map<String, dynamic> json) => TestimonioModel(
        id: json['_id']?.toString() ?? '',
        nombre: json['nombre'] as String,
        fotoUrl: json['foto_url'] as String? ?? '',
        testimonio: json['testimonio'] as String,
        pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
        instagramUrl: json['instagram_url'] as String?,
        facebookUrl: json['facebook_url'] as String?,
        estado: json['estado'] as String,
        fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'foto_url': fotoUrl,
        'testimonio': testimonio,
        'pais': pais.id,
        if (instagramUrl != null) 'instagram_url': instagramUrl,
        if (facebookUrl != null) 'facebook_url': facebookUrl,
        'estado': estado,
      };
}
