import 'package:flutter/painting.dart';

import 'osmon_colors.dart';

/// Type tokens. Geologica (display) and Onest (text) are bundled variable
/// fonts covering Latin and the full Cyrillic of all six app languages.
/// Weights are set through the `wght` axis as well as [FontWeight] so the
/// variable instances render identically on every engine.
abstract final class OsmonType {
  static const String display = 'Geologica';
  static const String text = 'Onest';

  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _display(double size, double weight, {double? spacing}) =>
      TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: _weight(weight),
        fontVariations: <FontVariation>[FontVariation.weight(weight)],
        letterSpacing: spacing ?? size * -0.02,
        height: 1.1,
        color: OsmonColors.textPrimary,
        fontFeatures: _tabular,
      );

  static TextStyle _text(double size, double weight, {double height = 1.45}) =>
      TextStyle(
        fontFamily: text,
        fontSize: size,
        fontWeight: _weight(weight),
        fontVariations: <FontVariation>[FontVariation.weight(weight)],
        height: height,
        color: OsmonColors.textPrimary,
        fontFeatures: _tabular,
      );

  static FontWeight _weight(double value) =>
      FontWeight.values[((value / 100).round() - 1).clamp(0, 8)];

  /// The one big number on the home screen.
  static final TextStyle hero = _display(
    104,
    200,
    spacing: -6,
  ).copyWith(height: 0.95);
  static final TextStyle heroUnit = _display(44, 300, spacing: 0);
  static final TextStyle numberLarge = _display(38, 300);
  static final TextStyle numberMedium = _display(24, 400);
  static final TextStyle numberSmall = _display(18, 400);

  static final TextStyle titleLarge = _display(26, 400);
  static final TextStyle titleMedium = _display(20, 400);
  static final TextStyle titleSmall = _display(16, 500, spacing: -0.2);

  static final TextStyle bodyLarge = _text(16, 600);
  static final TextStyle body = _text(14, 500);
  static final TextStyle bodyStrong = _text(14, 700);
  static final TextStyle caption = _text(12, 500);
  static final TextStyle captionStrong = _text(12, 700);
  static final TextStyle micro = _text(10.5, 600, height: 1.3);

  /// Uppercase section labels.
  static final TextStyle eyebrow = _text(
    10.5,
    700,
    height: 1.2,
  ).copyWith(letterSpacing: 1.5, color: OsmonColors.textTertiary);

  static final TextStyle button = _text(14, 700, height: 1.2);
  static final TextStyle navLabel = _text(10, 700, height: 1.1);
}
