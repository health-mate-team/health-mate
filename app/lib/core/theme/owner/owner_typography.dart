import 'package:flutter/material.dart';
import 'owner_colors.dart';

/// 오우너 타이포그래피
///
/// 폰트: Pretendard (`pubspec.yaml` fonts 섹션)
///
/// 사용법:
/// ```dart
/// Text('제목', style: OwnerTypography.h1)
/// Text('본문', style: OwnerTypography.body.copyWith(color: ...))
/// ```
class OwnerTypography {
  OwnerTypography._();

  static const String fontFamily = 'Pretendard';

  // ── Display XL (v1.1 — 진화·풀스크린 모멘트) ─────────────────
  static const TextStyle displayXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 76,
    fontWeight: FontWeight.w700,
    height: 0.95,
    letterSpacing: -2.28,
    color: OwnerColors.textPrimary,
  );

  // ── Display (큰 숫자, 임팩트) ─────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.26, // -3%
    color: OwnerColors.textPrimary,
  );

  // ── Headings ──────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.56, // -2%
    color: OwnerColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.44,
    color: OwnerColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.34,
    color: OwnerColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: -0.15,
    color: OwnerColors.textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.13,
    color: OwnerColors.textSecondary,
  );

  // ── Caption (레이블, 메타) ────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: OwnerColors.textSecondary,
  );

  // ── Button ────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.15,
    color: OwnerColors.textOnAction,
  );

  // ── Overline (섹션 라벨) ──────────────────────────────────────
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: 0.88, // +8%
    color: OwnerColors.textBrand,
  );
}
