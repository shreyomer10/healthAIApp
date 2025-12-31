import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color overlay;
  final Color scannerCorner;
  final Color textPrimary;
  final Color textSecondary;

  const AppColors({
    required this.background,
    required this.overlay,
    required this.scannerCorner,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? overlay,
    Color? scannerCorner,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColors(
      background: background ?? this.background,
      overlay: overlay ?? this.overlay,
      scannerCorner: scannerCorner ?? this.scannerCorner,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      scannerCorner: Color.lerp(scannerCorner, other.scannerCorner, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
