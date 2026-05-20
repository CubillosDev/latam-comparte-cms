import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

/// Barra de filtros con FilterChip de Material 3.
class AppFilterBar extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppFilterBar({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.formBackground,
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = i == selectedIndex;
                  return FilterChip(
                    label: Text(filters[i]),
                    selected: selected,
                    onSelected: (_) => onSelected(i),
                    labelStyle: TextStyle(
                      color:
                          selected ? AppColors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.metricInactiveBg,
                    selectedColor: AppColors.primaryPurple,
                    checkmarkColor: AppColors.white,
                    showCheckmark: false,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  );
                },
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}
