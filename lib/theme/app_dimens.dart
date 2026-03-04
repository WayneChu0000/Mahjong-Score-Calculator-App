import 'package:flutter/material.dart';

/// Centralized dimension and spacing constants.
class AppDimens {
  AppDimens._();

  // ─── Padding / Spacing ────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  /// Most-used content padding.
  static const EdgeInsets paddingAllLg = EdgeInsets.all(16.0);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(12.0);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(8.0);

  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: 12.0,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: 8.0,
  );

  // ─── Border Radius ────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
}
