import 'package:flutter/material.dart';
import 'owner_colors.dart';
import 'owner_typography.dart';
import 'owner_tokens.dart';

/// 오우너 테마
///
/// 사용법 (`MaterialApp`):
/// ```dart
/// MaterialApp(
///   theme: OwnerTheme.light(),
///   ...
/// )
/// ```
class OwnerTheme {
  OwnerTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: OwnerTypography.fontFamily,

      // ── Color Scheme ────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: OwnerColors.actionPrimary,
        onPrimary: OwnerColors.textOnAction,
        secondary: OwnerColors.coral100,
        onSecondary: OwnerColors.textBrand,
        surface: OwnerColors.bgSurface,
        onSurface: OwnerColors.textPrimary,
        surfaceContainerHighest: OwnerColors.bgElevated,
        error: OwnerColors.error,
        onError: OwnerColors.white,
        outline: OwnerColors.borderDefault,
        outlineVariant: OwnerColors.borderSubtle,
      ),

      // ── Scaffold ────────────────────────────────────────────────
      scaffoldBackgroundColor: OwnerColors.bgPrimary,

      // ── Text Theme ──────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: OwnerTypography.display,
        displayMedium: OwnerTypography.display,
        headlineLarge: OwnerTypography.h1,
        headlineMedium: OwnerTypography.h2,
        headlineSmall: OwnerTypography.h3,
        titleLarge: OwnerTypography.h2,
        titleMedium: OwnerTypography.h3,
        bodyLarge: OwnerTypography.body,
        bodyMedium: OwnerTypography.body,
        bodySmall: OwnerTypography.bodySm,
        labelLarge: OwnerTypography.button,
        labelMedium: OwnerTypography.caption,
        labelSmall: OwnerTypography.overline,
      ),

      // ── App Bar ─────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: OwnerColors.bgPrimary,
        foregroundColor: OwnerColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: OwnerTypography.h3,
        iconTheme: const IconThemeData(
          color: OwnerColors.textPrimary,
          size: OwnerIconSize.lg,
        ),
      ),

      // ── Button ──────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OwnerColors.actionPrimary,
          foregroundColor: OwnerColors.textOnAction,
          textStyle: OwnerTypography.button,
          padding: OwnerSpacing.buttonDefault,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: OwnerRadius.radiusLg,
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OwnerColors.actionPrimary,
          textStyle: OwnerTypography.button.copyWith(
            color: OwnerColors.actionPrimary,
          ),
        ),
      ),

      // ── Card ────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: OwnerColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: OwnerRadius.radiusLg,
          side: const BorderSide(
            color: OwnerColors.borderDefault,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OwnerColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OwnerSpacing.base,
          vertical: OwnerSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: OwnerRadius.radiusMd,
          borderSide: const BorderSide(
            color: OwnerColors.borderDefault,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: OwnerRadius.radiusMd,
          borderSide: const BorderSide(
            color: OwnerColors.borderDefault,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: OwnerRadius.radiusMd,
          borderSide: const BorderSide(
            color: OwnerColors.borderFocus,
            width: 1.5,
          ),
        ),
        hintStyle: OwnerTypography.body.copyWith(
          color: OwnerColors.textDisabled,
        ),
      ),

      // ── Bottom Sheet ────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OwnerColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: OwnerRadius.sheetTop,
        ),
      ),

      // ── Tab Bar ─────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: OwnerColors.actionPrimary,
        unselectedLabelColor: OwnerColors.textDisabled,
        labelStyle: OwnerTypography.caption,
        unselectedLabelStyle: OwnerTypography.caption,
        indicatorColor: OwnerColors.actionPrimary,
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: OwnerColors.bgSurface,
        selectedItemColor: OwnerColors.actionPrimary,
        unselectedItemColor: OwnerColors.textDisabled,
        selectedLabelStyle: TextStyle(
          fontFamily: OwnerTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: OwnerTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Divider ─────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: OwnerColors.borderSubtle,
        thickness: 0.5,
        space: 0,
      ),

      // ── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: OwnerColors.coral50,
        labelStyle: OwnerTypography.caption.copyWith(
          color: OwnerColors.textBrand,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: OwnerSpacing.sm,
          vertical: OwnerSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: OwnerRadius.radiusMd,
        ),
        side: BorderSide.none,
      ),

      // ── Snack Bar ───────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OwnerColors.cocoa800,
        contentTextStyle: OwnerTypography.bodySm.copyWith(
          color: OwnerColors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: OwnerRadius.radiusLg,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Page Transition ─────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
