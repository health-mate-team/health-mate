import 'package:flutter/material.dart';

/// 오우너 컬러 토큰
///
/// 사용법:
/// ```dart
/// Container(color: OwnerColors.coral500)
/// Container(color: OwnerColors.bgPrimary) // semantic
/// ```
///
/// 모든 컬러는 [Core Palette]와 [Semantic Tokens] 두 그룹으로 분리됨.
/// UI 코드에서는 가능하면 Semantic 토큰만 사용할 것.
class OwnerColors {
  OwnerColors._();

  // ════════════════════════════════════════════════════════════════
  // CORE PALETTE
  // ════════════════════════════════════════════════════════════════

  // ── Coral (Primary) ───────────────────────────────────────────
  static const Color coral50 = Color(0xFFFFEDE3);
  static const Color coral100 = Color(0xFFFFD5C7);
  static const Color coral300 = Color(0xFFFF9A86);
  static const Color coral500 = Color(0xFFFF7B5C); // ★ Brand
  static const Color coral700 = Color(0xFFC2410C);
  static const Color coral900 = Color(0xFFB8412F);

  // ── Beige (Surface) ───────────────────────────────────────────
  static const Color beige50 = Color(0xFFFFF8F0);
  static const Color beige100 = Color(0xFFFBE9D0);
  static const Color beige300 = Color(0xFFF0D4B0); // ★ 모아 마스코트
  static const Color beige500 = Color(0xFFD4A57A);

  // ── Cocoa (Text) ──────────────────────────────────────────────
  static const Color cocoa200 = Color(0xFFC9B8A8);
  static const Color cocoa500 = Color(0xFF8B6B5C);
  static const Color cocoa800 = Color(0xFF4A2820); // ★ Primary text
  static const Color cocoa900 = Color(0xFF2C2722); // ★ 수 마스코트

  // ── Accent ────────────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFB923C); // 수 시그니처 별
  static const Color accentMint = Color(0xFF5DCAA5); // 운동
  static const Color accentSky = Color(0xFF85B7EB); // 수분
  static const Color accentLavender = Color(0xFF7F77DD); // 휴식

  // ── System ────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFE24B4A);

  // ════════════════════════════════════════════════════════════════
  // SEMANTIC TOKENS — UI에서 우선 사용
  // ════════════════════════════════════════════════════════════════

  // ── Background ────────────────────────────────────────────────
  static const Color bgPrimary = beige50;
  static const Color bgSurface = white;
  static const Color bgElevated = coral50;
  static const Color bgScrim = Color(0x803D2820);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = cocoa800;
  static const Color textSecondary = cocoa500;
  static const Color textDisabled = cocoa200;
  static const Color textOnAction = white;
  static const Color textBrand = coral900;

  // ── Action ────────────────────────────────────────────────────
  static const Color actionPrimary = coral500;
  static const Color actionPrimaryHover = coral700;
  static const Color actionSecondary = coral100;
  static const Color actionDisabled = beige100;

  // ── Border ────────────────────────────────────────────────────
  static const Color borderSubtle = coral50;
  static const Color borderDefault = coral100;
  static const Color borderStrong = coral300;
  static const Color borderFocus = coral500;

  // ── Status ────────────────────────────────────────────────────
  static const Color success = accentMint;
  static const Color warning = accentOrange;
  static const Color error = errorRed;
  static const Color info = accentSky;

  // ── Stat (3대 스탯) ───────────────────────────────────────────
  static const Color statEnergy = coral500;
  static const Color statHydration = accentSky;
  static const Color statRest = accentLavender;
}
