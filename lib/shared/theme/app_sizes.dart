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

  // Table row
  static const double tableRowHeight = 34;
  static const double tableHeaderHeight = 34;
  static const double separatorHeight = 24;
}
