import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text style constants.
///
/// These are baseline styles — use `.copyWith(...)` to adjust colour or size
/// in individual widgets when needed.
class AppTextStyles {
  AppTextStyles._();

  // ─── Headings ─────────────────────────────────────────────────────
  /// 24 pt bold — page titles, large headers.
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// 20 pt bold — section headers.
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// 18 pt bold — card titles, dialog headers.
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// 16 pt bold — sub-section titles.
  static const TextStyle heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ─── Body ─────────────────────────────────────────────────────────
  /// 16 pt regular — primary body text.
  static const TextStyle body = TextStyle(fontSize: 16);

  /// 15 pt regular — secondary body text.
  static const TextStyle bodySmall = TextStyle(fontSize: 15);

  /// 14 pt regular — supporting text, label descriptions.
  static const TextStyle subtitle = TextStyle(fontSize: 14);

  /// 13 pt regular — compact information.
  static const TextStyle caption = TextStyle(fontSize: 13);

  /// 12 pt regular — smallest text (badges, footnotes).
  static const TextStyle footnote = TextStyle(fontSize: 12);

  // ─── Semantic ─────────────────────────────────────────────────────
  /// Bold only (inherit surrounding fontSize).
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);

  /// Red error / destructive text.
  static const TextStyle destructive = TextStyle(color: AppColors.destructive);

  /// 14 pt grey subtitle text.
  static TextStyle subtitleGrey({bool isDark = false}) => TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.grey400 : Colors.grey,
      );
}
