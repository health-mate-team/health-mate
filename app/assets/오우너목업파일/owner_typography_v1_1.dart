import 'package:flutter/material.dart';
import 'owner_colors.dart';

/// 오우너 타이포그래피 v1.1
///
/// v1.1 변경사항:
/// - displayXl 추가 (풀스크린 모멘트의 거대한 숫자용)
class OwnerTypography {
  OwnerTypography._();

  static const String fontFamily = 'Pretendard';

  // ── Display XL (NEW v1.1) ────────────────────────────────────
  /// 풀스크린 모멘트의 거대한 숫자 임팩트
  /// 사용처: 진화 화면, 주간 리포트, 마일스톤 모멘트
  static const TextStyle displayXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 76,
    fontWeight: FontWeight.w700,
    height: 0.95,
    letterSpacing: -2.28,
    color: OwnerColors.textPrimary,
  );

  // ── Display ──────────────────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.26,
    color: OwnerColors.textPrimary,
  );

  // ── Headings ──────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.56,
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

  // ── Caption ──────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: OwnerColors.textSecondary,
  );

  // ── Button ───────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.15,
    color: OwnerColors.textOnAction,
  );

  // ── Overline ─────────────────────────────────────────────────
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: 0.88,
    color: OwnerColors.textBrand,
  );
}
