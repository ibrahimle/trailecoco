import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design Language System: EcoTrail - Nature's Guardian
/// Aesthetic Name: "Clean-Toon"
class EcoTheme {
  // Prevent instantiation
  EcoTheme._();

  // -- Colors --

  // Primary Colors
  static const Color sproutGreen = Color(0xFF8BC34A);
  static const Color skyBlue = Color(0xFF29B6F6);
  static const Color bloomPink = Color(0xFFFF4081);

  // Neutral Colors
  static const Color trailBrown = Color(0xFF795548);
  static const Color cloudWhite = Color(0xFFFFF9F0);
  static const Color softCharcoal = Color(0xFF37474F);

  // Feedback Colors
  static const Color ecoRed = Color(0xFFE53935);
  static const Color mutedGrey = Color(0xFF9E9E9E);

  // -- Text Styles --

  // We use a method to get the text theme so it can be used in the MaterialApp theme
  static TextTheme getTextTheme() {
    return GoogleFonts.baloo2TextTheme().copyWith(
      // Game Title: 48dp, ExtraBold (800), UPPERCASE
      displayLarge: GoogleFonts.baloo2(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: softCharcoal,
      ),
      // Screen Headings: 32dp, Bold (700), Title Case
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: softCharcoal,
      ),
      // HUD Elements: 24dp, Bold (700), Numeric
      titleLarge: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: softCharcoal,
      ),
      // Button Labels: 20dp, SemiBold (600), UPPERCASE
      labelLarge: GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: cloudWhite, // Buttons usually have colored backgrounds
      ),
      // Body Text: 18dp, Medium (500), Sentence case
      bodyMedium: GoogleFonts.baloo2(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: softCharcoal,
      ),
      // Small Labels: 14dp
      labelSmall: GoogleFonts.baloo2(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: softCharcoal,
      ),
    );
  }

  // -- Dimensions & Spacing --
  static const double cornerRadius = 24.0;
  static const double buttonRadius = 100.0; // Pill shape
  static const double smallRadius = 16.0;
  
  static const double borderThick = 4.0;
  static const double borderThin = 3.0;

  // Spacing (Base Unit 8dp)
  static const double spacingTight = 8.0;
  static const double spacingStandard = 16.0;
  static const double spacingComfortable = 24.0;
  static const double spacingGenerous = 32.0;
  static const double spacingSection = 48.0;
}

