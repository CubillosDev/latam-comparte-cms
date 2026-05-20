import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

class MetricBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;     // usado como color del acento (barra y punto)
  final Color backgroundColor; // ignorado — siempre blanco para look limpio

  const MetricBox({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: valueColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.6,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1.5,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
