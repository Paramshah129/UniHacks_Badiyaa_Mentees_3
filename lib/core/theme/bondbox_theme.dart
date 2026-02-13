import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BondBoxTheme {
  // Pastel Colors
  static const Color lavender = Color(0xFFE0BBE4);
  static const Color softPurple = Color(0xFF957DAD);
  static const Color peach = Color(0xFFFFDFD3);
  static const Color skyBlue = Color(0xFFB2E2F2);
  static const Color mint = Color(0xFFB8E1DD);
  static const Color hotPink = Color(0xFFFF69B4);
  
  // Neutral Colors
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF2D3436);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lavender, peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, Color(0xFFD1FDFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavender,
        primary: softPurple,
        secondary: hotPink,
        surface: offWhite,
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: softPurple,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavender,
        brightness: Brightness.dark,
        primary: lavender,
        secondary: hotPink,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }
}
