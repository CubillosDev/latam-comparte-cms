import 'package:app/core/app/app_colors.dart';
import 'package:app/core/enums.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;

  const StatusBadge({super.key, required this.status});

  static const _labels = {
    BadgeStatus.pending: 'Pendiente',
    BadgeStatus.published: 'Publicado',
    BadgeStatus.draft: 'Borrador',
    BadgeStatus.unpublished: 'Despublicado',
  };

  static const _textColors = {
    BadgeStatus.pending: AppColors.statusPendingText,
    BadgeStatus.published: AppColors.statusPublishedText,
    BadgeStatus.draft: AppColors.statusDraftText,
    BadgeStatus.unpublished: AppColors.statusUnpublishedText,
  };

  static const _bgColors = {
    BadgeStatus.pending: AppColors.statusPendingBg,
    BadgeStatus.published: AppColors.statusPublishedBg,
    BadgeStatus.draft: AppColors.statusDraftBg,
    BadgeStatus.unpublished: AppColors.statusUnpublishedBg,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColors[status],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labels[status]!,
        style: TextStyle(
          color: _textColors[status],
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
