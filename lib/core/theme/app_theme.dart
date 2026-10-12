import 'package:flutter/material.dart';

import 'osmon_colors.dart';
import 'osmon_spacing.dart';
import 'osmon_typography.dart';
import 'sky_page_transitions.dart';

/// Material theme over the Osmon tokens. Scaffolds are transparent: the live
/// sky behind the router shows through every screen.
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: OsmonColors.accent,
      onPrimary: OsmonColors.textOnAccent,
      secondary: OsmonColors.gold,
      onSecondary: OsmonColors.textOnAccent,
      surface: OsmonColors.inkRaised,
      onSurface: OsmonColors.textPrimary,
      error: OsmonColors.severe,
    );
    final textTheme = TextTheme(
      displayLarge: OsmonType.hero,
      headlineLarge: OsmonType.titleLarge,
      headlineMedium: OsmonType.titleMedium,
      titleLarge: OsmonType.titleMedium,
      titleMedium: OsmonType.titleSmall,
      titleSmall: OsmonType.bodyStrong,
      bodyLarge: OsmonType.bodyLarge,
      bodyMedium: OsmonType.body,
      bodySmall: OsmonType.caption,
      labelLarge: OsmonType.button,
      labelMedium: OsmonType.captionStrong,
      labelSmall: OsmonType.micro,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: OsmonType.text,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: OsmonColors.inkRaised,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: OsmonColors.divider,
      iconTheme: const IconThemeData(
        color: OsmonColors.textPrimary,
        size: OsmonSize.iconMd,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: OsmonType.titleSmall,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OsmonColors.inkSheet,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: OsmonColors.glassStroke,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OsmonRadius.xxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OsmonColors.inkSheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OsmonRadius.xxl),
        ),
        titleTextStyle: OsmonType.titleSmall,
        contentTextStyle: OsmonType.body.copyWith(
          color: OsmonColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: OsmonColors.inkSheet,
        contentTextStyle: OsmonType.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OsmonRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OsmonColors.glassFill,
        hintStyle: OsmonType.body.copyWith(color: OsmonColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OsmonSpace.s16,
          vertical: OsmonSpace.s14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OsmonRadius.md),
          borderSide: const BorderSide(color: OsmonColors.glassStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OsmonRadius.md),
          borderSide: const BorderSide(color: OsmonColors.glassStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OsmonRadius.md),
          borderSide: const BorderSide(color: OsmonColors.accent),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: OsmonColors.accent,
        selectionColor: OsmonColors.accentSoft,
        selectionHandleColor: OsmonColors.accent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OsmonColors.accent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: SkyFadeTransitionsBuilder(),
          TargetPlatform.iOS: SkyFadeTransitionsBuilder(),
        },
      ),
    );
  }
}
