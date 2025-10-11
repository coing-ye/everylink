// lib/app/theme.dart
import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
  scaffoldBackgroundColor: const Color(0xFFF7F8FA),
  appBarTheme: const AppBarTheme(
    elevation: 0, centerTitle: true, backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
  ),
  cardTheme: CardTheme(
    elevation: 0, color: Colors.white, surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: const Color(0xFFF1F3F6),
    hintStyle: const TextStyle(color: Colors.black38),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    backgroundColor: const Color(0xFFEFF2F7),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
  scaffoldBackgroundColor: const Color(0xFF0E1116),
  appBarTheme: const AppBarTheme(
    elevation: 0, centerTitle: true, backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  ),
  cardTheme: CardTheme(
    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: const Color(0xFF161A21),
    hintStyle: const TextStyle(color: Colors.white38),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    backgroundColor: const Color(0xFF1B2130),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),
);
