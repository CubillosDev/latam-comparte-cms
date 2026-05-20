import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? badge;
  final String? subtitle;

  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.badge,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?badge,
                if (actionLabel != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textHint,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.inputBorder),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
