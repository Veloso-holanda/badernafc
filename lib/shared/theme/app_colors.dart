import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primárias
  static const Color primary = Color(0xFF1B9B0A);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color star = Color(0xFF4CAF50);
  static const Color starInactive = Color(0x444CAF50);

  // Background
  static const Color background = Color(0xFF0D2B0D);
  static const Color bgDark = Color(0xFF0A1F0A);

  // Splash
  static const Color splashGreen = Color(0xFF239B0A);

  // Tabela
  static const Color tableHeaderBg = Color(0xFF2E7D32);
  static const Color tableRowBg = Color(0xCC1B5E20);
  static const Color tableRowAltBg = Color(0x662E7D32);

  // Texto
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xAAFFFFFF);
  static const Color textLabel = Color(0xFFC8E6C9);

  // Input
  static const Color inputBg = Color(0x33FFFFFF);
  static const Color inputBorder = Color(0x55FFFFFF);
  static const Color inputPlaceholder = Color(0x77FFFFFF);

  // FAB / Botões
  static const Color fabSortear = Color(0xFFFF8F00);

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Navbar
  static const Color navbarBg = Color(0xFF0A1F0A);
  static const Color navbarBorder = Color(0x15FFFFFF);
  static const Color navbarInactive = Color(0x66FFFFFF);
  static const Color navbarActive = Color(0xFF4CAF50);
}
