// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final Color primaryColor = Colors.green[700]!;
    final Color secondaryColor = Colors.greenAccent[400]!;
    final Color errorColor = Colors.red;
    final Color backgroundColor = Colors.grey[100]!;

    return ThemeData(
      // Modern typography with Google Fonts
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              displayMedium: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              headlineMedium: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              headlineSmall: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
              labelLarge: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.black87),
        hintStyle: GoogleFonts.poppins(color: Colors.black54),
        prefixIconColor: primaryColor,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        color: Colors.white,
      ),
      dividerColor: Colors.grey[300],
      iconTheme: IconThemeData(color: primaryColor, size: 24),
    );
  }
}
