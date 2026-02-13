import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BondBoxColors {
  // Brand & UI Colors
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryPink = Color(0xFFF472B6);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color softYellow = Color(0xFFFDE68A);
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Pastel & Theme Colors (from merge)
  static const Color lavender = Color(0xFFE0BBE4);
  static const Color softPurple = Color(0xFF957DAD);
  static const Color peach = Color(0xFFFFDFD3);
  static const Color skyBlue = Color(0xFFB2E2F2);
  static const Color mint = Color(0xFFB8E1DD);
  static const Color hotPink = Color(0xFFFF69B4);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF2D3436);

  // Gradients
  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [primaryPurple, secondaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bluePinkGradient = LinearGradient(
    colors: [accentBlue, secondaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
}

class BondBoxTheme {
  // Compatibility members for stashed code references
  static const Color hotPink = BondBoxColors.hotPink;
  static const Color softPurple = BondBoxColors.softPurple;
  static const LinearGradient skyGradient = BondBoxColors.skyGradient;
  static const LinearGradient primaryGradient = BondBoxColors.primaryGradient;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BondBoxColors.lavender,
        primary: BondBoxColors.softPurple,
        secondary: BondBoxColors.hotPink,
        surface: BondBoxColors.offWhite,
      ),
      scaffoldBackgroundColor: BondBoxColors.offWhite,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: BondBoxColors.darkGrey,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: BondBoxColors.darkGrey,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: BondBoxColors.darkGrey,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: BondBoxColors.darkGrey,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: BondBoxColors.textSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
          backgroundColor: BondBoxColors.softPurple,
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
        seedColor: BondBoxColors.lavender,
        brightness: Brightness.dark,
        primary: BondBoxColors.lavender,
        secondary: BondBoxColors.hotPink,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }
}
