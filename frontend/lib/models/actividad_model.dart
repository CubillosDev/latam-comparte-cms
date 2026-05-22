import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

class ActividadModel {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;

  const ActividadModel({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}

const List<ActividadModel> actividadRecienteMock = [
  ActividadModel(
    icon: Icons.person_add_outlined,
    color: AppColors.statusPublishedText,
    bgColor: AppColors.statusPublishedBg,
    title: 'Nueva solicitud aprobada',
    subtitle: 'Lucía Ramírez · Colombia · hace 5 min',
  ),
  ActividadModel(
    icon: Icons.article_outlined,
    color: AppColors.metricDraftText,
    bgColor: AppColors.metricDraftBg,
    title: 'Testimonio publicado',
    subtitle: 'Adriana Castro · Venezuela · hace 18 min',
  ),
  ActividadModel(
    icon: Icons.flag_outlined,
    color: AppColors.statusPendingText,
    bgColor: AppColors.statusPendingBg,
    title: 'Solicitud pendiente de revisión',
    subtitle: 'Mateo Gómez · Ecuador · hace 34 min',
  ),
];
