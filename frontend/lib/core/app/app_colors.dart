import 'package:flutter/material.dart';

abstract class AppColors {
  // Near-black — brand primario (usado solo en CTAs y texto)
  static const Color primary = Color(0xFF0F0F0F);
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF262626);

  // Legacy aliases
  static const Color primaryPurple = primary;
  static const Color primaryPurpleDark = primaryDark;
  static const Color primaryPurpleLight = primaryLight;

  // Surfaces — blanco dominante
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteTransparent = Color(0x99FFFFFF);
  static const Color formBackground = Color(0xFFF7F7F7); // casi blanco, muy sutil
  static const Color inputBorder = Color(0xFFEAEAEA);    // neutral suave
  static const Color inputIcon = Color(0xFFA3A3A3);
  static const Color textPrimary = Color(0xFF0F0F0F);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textHint = Color(0xFFA3A3A3);
  static const Color linkColor = primary;

  // Button
  static const Color buttonText = Color(0xFF0F0F0F);

  // Status badges — semánticos
  static const Color statusPendingText = Color(0xFFE11D48);   // rose-600
  static const Color statusPendingBg = Color(0xFFFFF1F2);     // rose-50
  static const Color statusPublishedText = Color(0xFF047857); // emerald-700
  static const Color statusPublishedBg = Color(0xFFD1FAE5);   // emerald-100
  static const Color statusDraftText = Color(0xFF737373);
  static const Color statusDraftBg = Color(0xFFF5F5F5);

  // Metric accent colors (barra superior del MetricBox)
  static const Color metricPendingBg = Color(0xFFFFF1F2);     // rose-50
  static const Color metricPendingText = Color(0xFFE11D48);   // rose-600
  static const Color metricDraftBg = Color(0xFFF5F5F5);       // neutro claro
  static const Color metricDraftText = Color(0xFF0F0F0F);     // near-black
  static const Color metricInactiveBg = Color(0xFFF5F5F5);
  static const Color metricInactiveText = Color(0xFF737373);

  // Card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x06000000);

  // Solicitud status
  static const Color statusManagedText = Color(0xFF404040);
  static const Color statusManagedBg = Color(0xFFF5F5F5);
  static const Color statusManagedBorder = Color(0xFFEAEAEA);
  static const Color statusRespondedText = Color(0xFF047857);
  static const Color statusRespondedBg = Color(0xFFD1FAE5);
  static const Color statusRespondedBorder = Color(0xFFA7F3D0);

  // Unpublished
  static const Color statusUnpublishedText = Color(0xFFDC2626);
  static const Color statusUnpublishedBg = Color(0xFFFEE2E2);

  // Content left-border accents
  static const Color borderPublished = Color(0xFF10B981);
  static const Color borderDraft = Color(0xFFD4D4D4);
  static const Color borderUnpublished = Color(0xFFEF4444);

  // Error
  static const Color errorColor = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color errorBg = Color(0x1ADC2626);

  // Gradients — premium charcoal (drawer header, logo box)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1C), Color(0xFF000000)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1C1C1C), Color(0xFF0F0F0F)],
  );
}
