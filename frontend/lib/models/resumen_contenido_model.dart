import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

class ResumenContenidoModel {
  final IconData icon;
  final Color color;
  final String label;
  final int published;
  final int draft;

  const ResumenContenidoModel({
    required this.icon,
    required this.color,
    required this.label,
    required this.published,
    required this.draft,
  });
}

const List<ResumenContenidoModel> resumenContenidoMock = [
  ResumenContenidoModel(
    icon: Icons.record_voice_over_outlined,
    color: AppColors.metricDraftText,
    label: 'Testimonios',
    published: 61,
    draft: 22,
  ),
  ResumenContenidoModel(
    icon: Icons.feed_outlined,
    color: AppColors.statusPendingText,
    label: 'Noticias',
    published: 44,
    draft: 18,
  ),
  ResumenContenidoModel(
    icon: Icons.groups_outlined,
    color: AppColors.statusPublishedText,
    label: 'Usuarios activos',
    published: 1184,
    draft: 38,
  ),
];
