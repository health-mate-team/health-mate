import 'package:flutter/material.dart';

import 'owner/owner_theme.dart';

/// 앱 전역 테마. 오우너 디자인 토큰(`OwnerTheme`)을 사용합니다.
class AppTheme {
  AppTheme._();

  static ThemeData get light => OwnerTheme.light();

  /// V1.1: `OwnerTheme.dark()` 추가 후 교체
  static ThemeData get dark => OwnerTheme.light();
}
