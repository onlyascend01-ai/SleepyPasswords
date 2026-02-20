import 'package:flutter/material.dart';

// Sleep-enhanced theme: Soft, dark, and calming
final ThemeData sleepTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: const Color(0xFF0D1117), // Deep navy blue
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
    elevation: 0,
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white60),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1F6FEB), // Softer blue
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF161B22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(fontSize: 16, color: Colors.white70),
    hintStyle: TextStyle(fontSize: 16, color: Colors.white54),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
