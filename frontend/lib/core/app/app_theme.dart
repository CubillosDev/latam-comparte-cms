import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.formBackground,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.formBackground,

        // ─── AppBar ──────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: AppColors.cardShadow,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColors.primary, size: 24),
          actionsIconTheme: IconThemeData(color: AppColors.primary, size: 24),
          toolbarHeight: 56,
        ),

        // ─── NavigationBar ───────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.cardShadow,
          elevation: 4,
          height: 64,
          indicatorColor: AppColors.metricDraftBg,
          indicatorShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                  color: AppColors.primaryPurple, size: 22);
            }
            return const IconThemeData(color: AppColors.textHint, size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              );
            }
            return const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            );
          }),
        ),

        // ─── Chip (FilterChip) ───────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.metricInactiveBg,
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),

        // ─── Elevated Button ─────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.buttonText,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        // ─── Filled Button ───────────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),

        // ─── Dialog ──────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),

        // ─── BottomSheet ─────────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),

        // ─── Divider ─────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.inputBorder,
          thickness: 1,
          space: 1,
        ),

        // ─── Text ────────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          labelSmall: TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
          ),
        ),
      );
}
