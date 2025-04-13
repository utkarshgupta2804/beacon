import 'package:flutter/material.dart';

class AppTheme {
  // App colors based on the provided image
  static const Color primaryColor = Color(0xFF0A5F55);
  static const Color secondaryColor = Color(0xFF0D7A6D);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: const Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}