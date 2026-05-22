import 'package:app/core/app/app_colors.dart';
import 'package:flutter/material.dart';

/// Campo de formulario con fondo gris, label opcional, icono prefijo y
/// soporte para estado de error. Reemplaza _FilledField, _FilledInput y _FieldLabel.
class AppFormField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final double fontSize;
  final Widget? suffix;

  const AppFormField({
    super.key,
    this.label,
    required this.hint,
    this.prefixIcon,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.hasError = false,
    this.errorText,
    this.onChanged,
    this.fontSize = 14,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: AppColors.textPrimary, fontSize: fontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: fontSize),
            prefixIcon: prefixIcon != null && maxLines == 1
                ? Icon(
                    prefixIcon,
                    color: hasError ? AppColors.errorColor : AppColors.textHint,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: AppColors.formBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.errorColor, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.errorColor, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.errorColor, width: 1.5)
                  : const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.errorColor, size: 14),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(color: AppColors.errorColor, fontSize: 11),
              ),
            ],
          ),
        ],
        if (suffix != null) ...[
          const SizedBox(height: 4),
          suffix!,
        ],
      ],
    );
  }
}
