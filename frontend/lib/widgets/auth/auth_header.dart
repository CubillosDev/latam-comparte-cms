import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.share_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9B5FD4), Color(0xFF4A1580)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -22,
                  right: -22,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: -18,
                  left: -14,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/logos/latam.png',
                    width: 54,
                    height: 54,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => Icon(
                      icon,
                      color: AppColors.white,
                      size: 38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'LATINOAMÉRICA COMPARTE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
