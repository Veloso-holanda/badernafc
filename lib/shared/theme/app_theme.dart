import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_sizes.dart';
import 'app_buttons.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.fontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.star,
          surface: AppColors.bgDark,
          error: AppColors.error,
          onPrimary: AppColors.textWhite,
          onSecondary: AppColors.textWhite,
          onSurface: AppColors.textWhite,
          onError: AppColors.textWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textWhite,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textWhite,
            size: AppSizes.iconXl,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtons.primary,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppButtons.secondary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppButtons.text,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.inputPlaceholder,
          ),
          border: OutlineInputBorder(
            borderRadius: AppSizes.borderRadiusPill,
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSizes.borderRadiusPill,
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSizes.borderRadiusPill,
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSizes.borderRadiusPill,
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navbarBg,
          selectedItemColor: AppColors.navbarActive,
          unselectedItemColor: AppColors.navbarInactive,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.navActive,
          unselectedLabelStyle: AppTypography.navInactive,
        ),
        cardTheme: CardThemeData(
          color: AppColors.tableRowBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusMd,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.navbarBorder,
          thickness: 1,
        ),
      );
}
