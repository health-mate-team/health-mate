/// 앱 마스코트 **모아(Moa)** · **수(Soo)** — 에셋 경로와 사용 맥락.
///
/// 참고: `assets/images/mascot/character_profile_moa_soo.png` (캐릭터 시트)
///
/// 스쿼클 아이콘 일러스트는 [MascotIconAssets]에 정리됨.
class MascotConstants {
  MascotConstants._();

  static const String _base = 'assets/images/mascot';

  /// 캐릭터 프로필(역할·등장 화면 요약) 참고용 이미지
  static const String characterProfileSheet =
      '$_base/character_profile_moa_soo.png';

  // --- 모아 (Moa): 큰 친구 · 따뜻한 코치 — 일상 동반, 인사·칭찬·따뜻한 알림 ---
  /// 기본 일러스트(큰 눈, 베이지, 하트). 홈, 인사, 칭찬 메시지 등.
  static const String moaDefault = '$_base/mascot_v3_white_eyes.png';

  /// 같은 톤의 다른 표정(점 눈). 필요 시 교체·A/B용.
  static const String moaAlternate = '$_base/mascot_v2_dot_eyes.png';

  // --- 수 (Soo): 작은 친구 · 활동 응원단 — 보상·업적·미션 ---
  static const String sooDefault = '$_base/mascot_v1_soot.png';
}

/// 라운드 사각(스쿼클) 배경의 브랜드·앱 아이콘용 일러스트.
///
/// 파일명 규칙: `icon_{구성}_{배경톤}.png`
/// - single_moa: 모아 단독
/// - duo_side: 나란히
/// - duo_peek: 작은 캐릭터가 큰 캐릭터 위에 얹힌 구도
/// - duo_heart: 가운데 하트(또는 연결) 강조
class MascotIconAssets {
  MascotIconAssets._();

  static const String _base = 'assets/images/mascot';

  // --- 모아 단독 ---
  static const String singleMoaCoral = '$_base/icon_single_moa_coral.png';
  static const String singleMoaCream = '$_base/icon_single_moa_cream.png';
  static const String singleMoaDark = '$_base/icon_single_moa_dark.png';

  // --- 듀오 · 나란히 ---
  static const String duoSideCoral = '$_base/icon_duo_side_coral.png';
  static const String duoSideCream = '$_base/icon_duo_side_cream.png';
  static const String duoSideDark = '$_base/icon_duo_side_dark.png';

  // --- 듀오 · 피크(겹침) ---
  static const String duoPeekCoral = '$_base/icon_duo_peek_coral.png';
  static const String duoPeekCream = '$_base/icon_duo_peek_cream.png';
  static const String duoPeekPeach = '$_base/icon_duo_peek_peach.png';

  // --- 듀오 · 하트 ---
  static const String duoHeartCoral = '$_base/icon_duo_heart_coral.png';
  static const String duoHeartCream = '$_base/icon_duo_heart_cream.png';
  static const String duoHeartDark = '$_base/icon_duo_heart_dark.png';
}
