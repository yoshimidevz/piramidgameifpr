import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        surface: AppColors.lightSurface,
        text: AppColors.lightText,
        textDim: AppColors.lightTextDim,
        border: AppColors.lightBorder,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        textDim: AppColors.darkTextDim,
        border: AppColors.darkBorder,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textDim,
    required Color border,
  }) {
    final base = ThemeData(brightness: brightness);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: AppColors.green,
        secondary: AppColors.gold,
        error: AppColors.red,
        surface: surface,
        onSurface: text,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
    );
  }
}