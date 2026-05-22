import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

/// Tarjeta blanca con sombra usada como contenedor de secciones de formulario.
class AppFormCard extends StatelessWidget {
  final Widget child;

  const AppFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
