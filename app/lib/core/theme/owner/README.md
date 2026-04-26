# 오우너 디자인 토큰 시스템

Flutter 앱 개발을 위한 디자인 토큰. 모든 화면에서 일관된 디자인을 보장하기 위한 중심 시스템입니다.

## 파일 구조 (health-mate)

```
lib/core/theme/
├── app_theme.dart                 # 앱 진입 — OwnerTheme 래퍼
└── owner/
    ├── owner_design_system.dart   # 배럴 export (권장 단일 import)
    ├── owner_colors.dart
    ├── owner_typography.dart
    ├── owner_tokens.dart
    ├── owner_theme.dart
    ├── example_screen.dart        # 참고용 (OwnerDesignExampleScreen)
    └── README.md
```

## 빠른 시작

### import

```dart
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
```

앱 테마는 `HealthMateApp`에서 `AppTheme.light` / `AppTheme.dark`로 이미 연결되어 있습니다 (`OwnerTheme.light()` 기반).

### pubspec

Pretendard는 `assets/fonts/`에 두고 `pubspec.yaml`의 `fonts` 섹션으로 등록합니다. (저장소에 포함됨)

## 사용 가이드 (요약)

- 컬러: UI에서는 `OwnerColors` **시맨틱** 토큰 우선 (`bgPrimary`, `actionPrimary` 등).
- 타이포: `OwnerTypography.h1` ~ `button` 등.
- 간격: `OwnerSpacing` (4px 그리드), `OwnerRadius`, `OwnerElevation`, `OwnerMotion`, `OwnerIconSize`.

임의의 `Color(0xFF…)`·`EdgeInsets.all(15)` 직접 사용은 지양합니다.

## 다크 모드

V1.1 이후 `OwnerTheme.dark()` 추가 예정. 현재 `AppTheme.dark`는 라이트와 동일합니다.

## 화면 명세·룰북

- `docs/design/owner-mock/01_DESIGN_RULES.md`, `00_index.json`, `*.json`
- 공용 위젯: `lib/shared/widgets/owner/`
