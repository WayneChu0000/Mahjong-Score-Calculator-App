import 'package:flutter/material.dart';

/// Centralized color constants for the Mahjong Score Calculator app.
///
/// Usage:
/// ```dart
/// import '../theme/app_colors.dart';
/// color: AppColors.primary
/// ```
class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Brand / Primary (Green) ───────────────────────────────────────
  static const Color primary = Colors.green;
  static const MaterialColor primarySwatch = Colors.green;
  static final Color primaryLight = Colors.green.shade300;
  static final Color primaryMedium = Colors.green.shade600;
  static final Color primaryDark = Colors.green.shade700;
  static final Color primaryDarker = Colors.green.shade800;
  static final Color primarySurface = Colors.green.shade50;
  static final Color primarySurfaceDark = Colors.green.withValues(alpha: 0.2);
  static final Color primarySurfaceSubtle = Colors.green.withValues(alpha: 0.1);

  // ─── Accent (Amber) ───────────────────────────────────────────────
  static const Color accent = Colors.amber;

  // ─── Destructive / Negative (Red) ─────────────────────────────────
  static const Color destructive = Colors.red;
  static final Color destructiveLight = Colors.red.shade100;
  static final Color destructiveMedium = Colors.red.shade300;
  static final Color destructiveDark = Colors.red.shade700;

  // ─── Neutral (Grey) ───────────────────────────────────────────────
  static final Color grey200 = Colors.grey.shade200;
  static final Color grey300 = Colors.grey.shade300;
  static final Color grey400 = Colors.grey.shade400;
  static final Color grey600 = Colors.grey.shade600;
  static final Color grey700 = Colors.grey.shade700;
  static final Color grey800 = Colors.grey.shade800;

  // ─── Dark Theme Surfaces ──────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkAppBar = Color(0xFF1F1F1F);
  static const Color darkCard = Color(0xFF2C2C2C);

  // ─── Fixed (theme-independent) ────────────────────────────────────
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color onPrimary = Colors.white;

  // ─── Semantic helpers ─────────────────────────────────────────────

  /// Returns green for positive scores, red for negative.
  static Color scoreColor(num score) => score >= 0 ? primary : destructive;

  /// Adaptive card background: translucent green (dark) / green.shade50 (light).
  static Color primaryCardBackground(bool isDark) =>
      isDark ? primarySurfaceDark : primarySurface;

  /// Adaptive subtle text colour.
  static Color subtitleColor(bool isDark) => isDark ? grey400 : grey600;

  /// Adaptive border colour.
  static Color borderColor(bool isDark) => isDark ? grey700 : grey300;

  /// Adaptive secondary surface colour.
  static Color secondarySurface(bool isDark) => isDark ? grey800 : grey200;
}
