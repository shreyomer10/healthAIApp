import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Backgrounds
  final Color background;
  final Color surface;
  final Color overlay;

  // Brand
  final Color primary;
  final Color primarySoft;
  final Color accent;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // UI Elements
  final Color border;
  final Color divider;
  final Color actionButton;
  final Color shadow;

  // Status
  final Color error;
  final Color success;
  final Color warning;

  // Scanner / special
  final Color scannerCorner;

  const AppColors({
    required this.background,
    required this.surface,
    required this.overlay,
    required this.primary,
    required this.primarySoft,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.actionButton,
    required this.error,
    required this.success,
    required this.warning,
    required this.scannerCorner,
    required this.shadow
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? overlay,
    Color? primary,
    Color? primarySoft,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? actionButton,
    Color? error,
    Color? success,
    Color? warning,
    Color? scannerCorner,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      overlay: overlay ?? this.overlay,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      actionButton: actionButton ?? this.actionButton,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      scannerCorner: scannerCorner ?? this.scannerCorner,
      shadow: shadow ?? this.shadow,

    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      actionButton: Color.lerp(actionButton, other.actionButton, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      scannerCorner: Color.lerp(scannerCorner, other.scannerCorner, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,

    );
  }
}
