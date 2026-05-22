import 'package:flutter/material.dart';

abstract class AppColors {
  // Purples
  static const Color primaryPurple = Color(0xFF7C3AC7);
  static const Color primaryPurpleDark = Color(0xFF5E2A9A);
  static const Color primaryPurpleLight = Color(0xFF9B5FD4);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteTransparent = Color(0x99FFFFFF);
  static const Color formBackground = Color(0xFFF2F2F7);
  static const Color inputBorder = Color(0xFFDDDDE8);
  static const Color inputIcon = Color(0xFF9B5FD4);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textHint = Color(0xFFAAAAAC);
  static const Color linkColor = Color(0xFF7C3AC7);

  // Button
  static const Color buttonText = Color(0xFF5E2A9A);

  // Status badges
  static const Color statusPendingText = Color(0xFFFF9500);
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusPublishedText = Color(0xFF34C759);
  static const Color statusPublishedBg = Color(0xFFE8F8EC);
  static const Color statusDraftText = Color(0xFF8E8EA0);
  static const Color statusDraftBg = Color(0xFFF0F0F5);

  // Metric boxes
  static const Color metricPendingBg = Color(0xFFFFF8EE);
  static const Color metricPendingText = Color(0xFFFF9500);
  static const Color metricDraftBg = Color(0xFFF0EEFF);
  static const Color metricDraftText = Color(0xFF7C3AC7);
  static const Color metricInactiveBg = Color(0xFFF5F5F7);
  static const Color metricInactiveText = Color(0xFF8E8EA0);

  // Card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0D000000);

  // Solicitud status
  static const Color statusManagedText = Color(0xFF1565C0);
  static const Color statusManagedBg = Color(0xFFE3F2FD);
  static const Color statusManagedBorder = Color(0xFFBBDEFB);
  static const Color statusRespondedText = Color(0xFF2E7D32);
  static const Color statusRespondedBg = Color(0xFFE8F5E9);
  static const Color statusRespondedBorder = Color(0xFFC8E6C9);

  // Unpublished / Despublicado
  static const Color statusUnpublishedText = Color(0xFFBE123C);
  static const Color statusUnpublishedBg = Color(0xFFFFF1F2);

  // Content left-border accents
  static const Color borderPublished = Color(0xFF10B981);
  static const Color borderDraft = Color(0xFF94A3B8);
  static const Color borderUnpublished = Color(0xFFEF4444);

  // Error / Danger zone
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color errorBg = Color(0x1ABA1A1A);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryPurpleLight, primaryPurpleDark],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryPurple, Color(0xFFBF3FC7)],
  );
}
