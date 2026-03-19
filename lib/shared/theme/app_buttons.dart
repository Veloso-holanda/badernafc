import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

abstract final class AppButtons {
  // Botão principal (Entrar, Cadastrar)
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textWhite,
    textStyle: AppTypography.button,
    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: AppSizes.borderRadiusButton,
    ),
    elevation: 0,
  );

  // Outlined (secundário)
  static final ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textWhite,
    textStyle: AppTypography.button,
    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: AppSizes.borderRadiusButton,
    ),
    side: const BorderSide(color: AppColors.inputBorder, width: 1),
  );

  // Text button
  static final ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.star,
    textStyle: AppTypography.link,
  );

  // FAB style (Confirmar presença)
  static final ButtonStyle fab = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textWhite,
    textStyle: AppTypography.buttonFab,
    minimumSize: const Size(270, AppSizes.fabHeight),
    shape: RoundedRectangleBorder(
      borderRadius: AppSizes.borderRadiusPill,
    ),
    elevation: 8,
    shadowColor: const Color(0x66000000),
  );

  // Botão primário de formulário (radius card, sem elevation)
  static final ButtonStyle primaryForm = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textWhite,
    textStyle: AppTypography.button,
    shape: RoundedRectangleBorder(
      borderRadius: AppSizes.borderRadiusCard,
    ),
    padding: AppSizes.fieldContentPadding,
    elevation: 0,
  );

  // FAB Sortear
  static final ButtonStyle fabSortear = ElevatedButton.styleFrom(
    backgroundColor: AppColors.fabSortear,
    foregroundColor: AppColors.textWhite,
    textStyle: AppTypography.buttonFab,
    minimumSize: const Size(270, AppSizes.fabHeight),
    shape: RoundedRectangleBorder(
      borderRadius: AppSizes.borderRadiusPill,
    ),
    elevation: 8,
    shadowColor: const Color(0x66000000),
  );
}
