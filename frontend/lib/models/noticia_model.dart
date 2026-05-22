import 'package:app/core/enums.dart';
import 'package:app/models/pais_model.dart';
import 'package:flutter/material.dart';

class NoticiaModel {
  final String id;
  final String titulo;
  final String resumen;
  final String contenido;
  final String autor;
  final String? imagenUrl;
  final PaisModel pais;
  final String estado;
  final DateTime fechaCreacion;

  NoticiaModel({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.contenido,
    required this.autor,
    this.imagenUrl,
    required this.pais,
    required this.estado,
    required this.fechaCreacion,
  });

  bool get isPublicado => estado == 'publicado';
  bool get isBorrador => estado == 'borrador';

  // ── UI display properties ──────────────────────────────────────────────────

  BadgeStatus get status {
    if (estado == 'publicado') return BadgeStatus.published;
    return BadgeStatus.draft;
  }

  bool get isVisible => isPublicado;
  bool get hasImage => imagenUrl != null;

  String get title => titulo;
  String get author => autor;
  String get excerpt => resumen;

  String get date {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fechaCreacion.day} ${months[fechaCreacion.month - 1]} ${fechaCreacion.year}';
  }

  Color get thumbnailColor => pais.accentColor;
  IconData get thumbnailIcon => Icons.newspaper_outlined;
  String get category => pais.nombre;
  Color get categoryColor => pais.accentColor;
  Color get borderColor => pais.accentColor;

  String get authorInitials {
    final parts = autor.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return autor.isNotEmpty ? autor[0].toUpperCase() : 'A';
  }

  Color get authorColor {
    const colors = [
      Color(0xFF7C3AC7),
      Color(0xFF1D4ED8),
      Color(0xFF15803D),
      Color(0xFFDC2626),
    ];
    return colors[autor.length % colors.length];
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  factory NoticiaModel.fromJson(Map<String, dynamic> json) => NoticiaModel(
        id: json['_id']?.toString() ?? '',
        titulo: json['titulo'] as String,
        resumen: json['resumen'] as String,
        contenido: json['contenido'] as String,
        autor: json['autor'] as String,
        imagenUrl: json['imagen_url'] as String?,
        pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
        estado: json['estado'] as String,
        fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'resumen': resumen,
        'contenido': contenido,
        'autor': autor,
        if (imagenUrl != null) 'imagen_url': imagenUrl,
        'pais': pais.id,
        'estado': estado,
      };
}
