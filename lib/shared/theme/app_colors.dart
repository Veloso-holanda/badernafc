import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primárias
  static const Color primary = Color(0xFFD4841A);       // Laranja principal (botões, destaques)
  static const Color primaryDark = Color(0xFF8B5A1B);   // Laranja escuro (tabela rows, backgrounds)
  static const Color star = Color(0xFFE8922E);           // Laranja claro (estrelas, links, navbar ativo)
  static const Color starInactive = Color(0x44E8922E);   // Estrelas inativas

  // Background
  static const Color background = Color(0xFF121212);     // Scaffold background
  static const Color bgDark = Color(0xFF0A0A0A);         // Navbar bg, áreas escuras

  // Splash
  static const Color splashBg = Color(0xFF1A1A1A);       // Splash background

  // Tabela
  static const Color tableHeaderBg = Color(0xFF7A4A1A);  // Header de tabelas
  static const Color tableRowBg = Color(0xCC5C3A12);     // Linha tabela par
  static const Color tableRowAltBg = Color(0x667A4A1A);  // Linha tabela ímpar

  // Texto
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xAAFFFFFF);
  static const Color textLabel = Color(0xFFE0C8A8);      // Labels (tom quente)

  // Input
  static const Color inputBg = Color(0x33FFFFFF);
  static const Color inputBorder = Color(0x55FFFFFF);
  static const Color inputPlaceholder = Color(0x77FFFFFF);

  // FAB / Botões
  static const Color fabSortear = Color(0xFFFF8F00);     // FAB sortear (laranja forte)

  // Config / Menu
  static const Color menuItemBg = Color(0x22FFFFFF);
  static const Color adminBadge = Color(0xFFFF8F00);
  static const Color adminBadgeBg = Color(0x33FF8F00);
  static const Color exitBg = Color(0x22FF5252);
  static const Color levelBadgeBg = Color(0x33E8922E);

  // Card admin (cadastros/financeiro)
  static const Color cardAdminBg = Color(0x55D4841A);       // primary ~33% alpha
  static const Color cardAdminBorder = Color(0x66D4841A);    // primary ~40% alpha

  // Form
  static const Color formFieldBg = Color(0x1AFFFFFF);
  static const Color formFieldBorder = Color(0x33E8922E);

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Navbar
  static const Color navbarBg = Color(0xFF0A0A0A);
  static const Color navbarBorder = Color(0x15FFFFFF);
  static const Color navbarInactive = Color(0x66FFFFFF);
  static const Color navbarActive = Color(0xFFE8922E);
}
