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
      // Typographie moderne avec Google Fonts
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              headlineSmall: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
              bodySmall: GoogleFonts.poppins(
                fontSize: 12,
                color: errorColor,
              ),
              labelLarge: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              labelMedium: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
              labelSmall: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onError: Colors.white,
        onSurface: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
        ),
        labelStyle: GoogleFonts.poppins(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: GoogleFonts.poppins(
          color: errorColor,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      iconTheme: IconThemeData(color: primaryColor),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: primaryColor,
        textColor: Colors.black87,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
