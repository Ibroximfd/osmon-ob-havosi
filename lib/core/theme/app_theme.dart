import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgLight,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(color: AppColors.darkText),
            displayMedium: GoogleFonts.outfit(color: AppColors.darkText),
            displaySmall: GoogleFonts.outfit(color: AppColors.darkText),
            headlineLarge: GoogleFonts.outfit(color: AppColors.darkText),
            headlineMedium: GoogleFonts.outfit(color: AppColors.darkText),
            headlineSmall: GoogleFonts.outfit(color: AppColors.darkText),
            titleLarge: GoogleFonts.outfit(color: AppColors.darkText),
            titleMedium: GoogleFonts.outfit(color: AppColors.darkText),
            titleSmall: GoogleFonts.outfit(color: AppColors.darkText),
          )
          .apply(
            bodyColor: AppColors.darkText,
            displayColor: AppColors.darkText,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgDark,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(color: AppColors.lightText),
            displayMedium: GoogleFonts.outfit(color: AppColors.lightText),
            displaySmall: GoogleFonts.outfit(color: AppColors.lightText),
            headlineLarge: GoogleFonts.outfit(color: AppColors.lightText),
            headlineMedium: GoogleFonts.outfit(color: AppColors.lightText),
            headlineSmall: GoogleFonts.outfit(color: AppColors.lightText),
            titleLarge: GoogleFonts.outfit(color: AppColors.lightText),
            titleMedium: GoogleFonts.outfit(color: AppColors.lightText),
            titleSmall: GoogleFonts.outfit(color: AppColors.lightText),
          )
          .apply(
            bodyColor: AppColors.lightText,
            displayColor: AppColors.lightText,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightText),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
