import 'package:flutter/material.dart';

abstract final class AppSizes {
  // Tela padrão (baseado no design 390x844)
  static const double screenWidth = 390;
  static const double screenHeight = 844;

  // Spacing
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 32;

  // Padding das telas
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(32, 50, 32, 40);
  static const EdgeInsets screenPaddingLogin = EdgeInsets.fromLTRB(32, 60, 32, 40);
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(20, 50, 20, 140);

  // Gap padrão entre seções
  static const double sectionGap = 24;
  static const double formGap = 16;
  static const double inputGap = 8;
  static const double tableGap = 2;

  // Border Radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;
  static const double radiusPill = 25;
  static const double radiusButton = 26;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(radiusPill);
  static final BorderRadius borderRadiusButton = BorderRadius.circular(radiusButton);
  static const double radiusCard = 12;
  static final BorderRadius borderRadiusCard = BorderRadius.circular(radiusCard);
  static const double radiusField = 10;
  static final BorderRadius borderRadiusField = BorderRadius.circular(radiusField);

  // Icon sizes
  static const double iconSm = 14;
  static const double iconMd = 20;
  static const double iconLg = 22;
  static const double iconXl = 24;

  // Button / Input heights
  static const double inputHeight = 50;
  static const double buttonHeight = 52;
  static const double fabHeight = 50;
  static const double navbarHeight = 70;

  // Avatar
  static const double avatarSm = 34;
  static const double avatarLg = 36;
  static const double avatarXl = 80;
  static const double avatarPerfil = 100;

  // Perfil jogador (carta)
  static const double starPerfil = 28;

  // Menu
  static const EdgeInsets menuItemPadding = EdgeInsets.all(16);
  static const double menuItemGap = 14;

  // Table row
  static const double tableRowHeight = 40;
  static const double tableHeaderHeight = 40;
  static const double separatorHeight = 24;

  // Table cell
  static const EdgeInsets tableCellPadding = EdgeInsets.symmetric(horizontal: lg);

  // Badge
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(vertical: sm, horizontal: lg);

  // Field content (form inputs customizados)
  static const EdgeInsets fieldContentPadding = EdgeInsets.symmetric(horizontal: xl, vertical: 14);

  // Campo label gap (entre label e campo em forms customizados)
  static const double fieldLabelGap = 6;

  // Icon intermediário (usado em campos de form)
  static const double iconForm = 18;

  // Navbar
  static const EdgeInsets navbarPadding = EdgeInsets.fromLTRB(xl, md, xl, xl);

  // Card admin (cadastros/financeiro)
  static const EdgeInsets cardAdminPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 24);
  static const double radiusCardAdmin = 16;
  static final BorderRadius borderRadiusCardAdmin = BorderRadius.circular(radiusCardAdmin);

  // Background image opacity
  static const double bgImageOpacidade = 0.12;

  // Exit button
  static const EdgeInsets exitButtonPadding = EdgeInsets.symmetric(vertical: 14, horizontal: xl);
}
