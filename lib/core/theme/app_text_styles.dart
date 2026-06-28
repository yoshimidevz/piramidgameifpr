import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle sora({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.sora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle jakarta({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Estilos prontos, direto do design (ex: titulo da Splash).
  static TextStyle get splashTitle =>
      sora(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -1.2);

  static TextStyle get screenTitle =>
      sora(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6);

  static TextStyle get cardNumber =>
      sora(fontSize: 26, fontWeight: FontWeight.w800);

  static TextStyle get bodyDefault =>
      jakarta(fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle get bodySmallDim =>
      jakarta(fontSize: 13, fontWeight: FontWeight.w500);
}