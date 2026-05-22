import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

/// Botón flotante con gradiente y bordes redondeados.
/// Reemplaza _AddFAB en testimonios y noticias.
class AppGradientFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final BorderRadius? borderRadius;

  const AppGradientFab({
    super.key,
    this.icon = Icons.add_rounded,
    this.onPressed,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Icon(icon, color: AppColors.white, size: size * 0.5),
        ),
      ),
    );
  }
}
