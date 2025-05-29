import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
