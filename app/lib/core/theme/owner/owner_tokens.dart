import 'package:flutter/material.dart';

/// 오우너 스페이싱 (4px 기반)
class OwnerSpacing {
  OwnerSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // EdgeInsets 헬퍼
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets cardDefault = EdgeInsets.all(lg);
  static const EdgeInsets buttonDefault = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: base,
  );
}

/// 오우너 코너 라운드
class OwnerRadius {
  OwnerRadius._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 14;
  static const double xl = 20;
  static const double full = 9999;

  // BorderRadius 헬퍼
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusFull =
      BorderRadius.all(Radius.circular(full));

  // 바텀시트용 (위쪽만 둥글게)
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}

/// 오우너 엘리베이션 (그림자)
class OwnerElevation {
  OwnerElevation._();

  static const List<BoxShadow> e0 = [];

  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0F4A2820), // 6% opacity
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x1F4A2820), // 12% opacity
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}

/// 오우너 모션 (애니메이션 시간 + 곡선)
class OwnerMotion {
  OwnerMotion._();

  // ── Duration ──────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration character = Duration(milliseconds: 800);
  static const Duration evolution = Duration(milliseconds: 2400);

  // ── Curves ────────────────────────────────────────────────────
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
  static const Curve bouncy = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve gentle = Cubic(0.25, 0.1, 0.25, 1);
}

/// 오우너 아이콘 사이즈
class OwnerIconSize {
  OwnerIconSize._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 40;

  static const double stroke = 1.6;
}
