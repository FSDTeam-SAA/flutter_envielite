import 'package:flutter/material.dart';

class AppThemes {
  // Black and White Theme
  static final ThemeData blackWhiteTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black, // Primary Color: Black
    scaffoldBackgroundColor: Colors.white, // Background: White
    cardColor: Colors.white, // Surface: White

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black, // AppBar: Black
      foregroundColor: Colors.white, // Text & Icons: White
      elevation: 2,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Primary Text: Black
      bodyMedium: TextStyle(color: Colors.black87), // Secondary Text: Dark Gray
    ),

    iconTheme: const IconThemeData(color: Colors.black), // Icons: Black
    dividerColor: Colors.black26, // Dividers: Light Black/Gray

    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.black, // Buttons: Black
      disabledColor: Colors.black38, // Disabled Button: Gray
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Colors.black),
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: Colors.black, // Primary: Black
      secondary: Colors.black, // Secondary: Black
      surface: Colors.white, // Surface: White
      error: Colors.red, // Error: Red
      onPrimary: Colors.white, // Text on Primary: White
      onSecondary: Colors.white, // Text on Secondary: White
      onSurface: Colors.black, // Text on Surface: Black
      onError: Colors.white, // Text on Error: White
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // TextField Background: White
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black54), // Border: Black
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black54), // Enabled Border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2), // Focused Border
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red), // Error Border
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 2), // Focused Error Border
      ),
      labelStyle: const TextStyle(color: Colors.black87), // Label Text
      hintStyle: const TextStyle(color: Colors.black45), // Hint Text
      errorStyle: const TextStyle(color: Colors.red), // Error Text
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Button: Black
        foregroundColor: Colors.white, // Text: White
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
