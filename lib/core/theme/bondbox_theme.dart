import 'package:flutter/material.dart';
<<<<<<< Updated upstream
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
=======

class BondBoxColors {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryPink = Color(0xFFF472B6);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color softYellow = Color(0xFFFDE68A);
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [primaryPurple, secondaryPink],
>>>>>>> Stashed changes
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

<<<<<<< Updated upstream
  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, Color(0xFFD1FDFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

=======
  static const LinearGradient bluePinkGradient = LinearGradient(
    colors: [accentBlue, secondaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class BondBoxTheme {
>>>>>>> Stashed changes
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
<<<<<<< Updated upstream
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
=======
        seedColor: BondBoxColors.primaryPurple,
        primary: BondBoxColors.primaryPurple,
        secondary: BondBoxColors.secondaryPink,
      ),
      scaffoldBackgroundColor: BondBoxColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: BondBoxColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: BondBoxColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BondBoxColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: BondBoxColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: BondBoxColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: BondBoxColors.primaryPurple,
        ),
      ),
      cardTheme: CardThemeData(
        color: BondBoxColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
>>>>>>> Stashed changes
        ),
      ),
    );
  }
<<<<<<< Updated upstream

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
=======
>>>>>>> Stashed changes
}
