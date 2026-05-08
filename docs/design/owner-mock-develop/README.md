# 오우너 디자인 토큰 시스템 v1.1

> **단일 소스:** 실제 앱 구현은 저장소의 `app/lib/`(예: `lib/core/theme/owner/`, `lib/shared/widgets/owner/`)를 따릅니다. 이 폴더의 화면 명세는 **JSON + 본 README + `01_DESIGN_RULES.md`**이며, Dart 파일은 `reference/` 아래 **참고용 스케치**일 뿐 import 경로가 앱과 맞지 않습니다.

Flutter 앱 개발을 위한 디자인 토큰 + 컴포넌트 라이브러리.

## 📦 v1.1 새로운 점

- ✨ **displayXl 타이포그래피 추가** (76px) — 풀스크린 모멘트의 거대한 숫자용
- 🎨 **chip variant 컬러 토큰** — info/success/warning 변형
- 🧩 **11개 표준 컴포넌트 위젯** — OwnerButton, OwnerCard, OwnerStatGauge 등
- 🎬 **5개 모션 패턴** — breathing, scale_in_bounce, wave_arm 등 (위젯에 내장)

## 📁 파일 구조

앱 코드 레이아웃(실제 프로젝트):

```
app/lib/
├── core/theme/owner/               # 디자인 토큰
├── shared/widgets/owner/           # 표준 컴포넌트
└── features/...                    # 화면
```

목업 폴더의 예시 구조(참고용 — `reference/*.dart`):

```
lib/
├── theme/                          # 디자인 토큰
│   ├── theme.dart                  # 배럴 export
│   ├── owner_colors.dart           # 컬러 (Core + Semantic + Chip variants)
│   ├── owner_typography.dart       # 9개 텍스트 스타일
│   ├── owner_tokens.dart           # 스페이싱/라운드/엘리베이션/모션/아이콘
│   └── owner_theme.dart            # ThemeData 통합
└── widgets/                        # 표준 컴포넌트
    ├── widgets.dart                # 배럴 export
    ├── owner_button.dart           # 3 variants
    ├── owner_card.dart             # 3 variants
    ├── owner_chip.dart             # 4 variants
    ├── owner_stat_gauge.dart       # 3대 스탯 게이지
    ├── owner_streak_badge.dart     # 연속 일수 배지
    ├── owner_story_progress_bar.dart  # 스토리식 진행 바
    ├── owner_quick_action_button.dart # 홈 액션 버튼
    ├── owner_checkbox.dart         # 약속 체크박스
    ├── owner_mood_card.dart        # 무드 선택 카드
    ├── owner_moa_avatar.dart       # 모아 캐릭터
    └── owner_soo_avatar.dart       # 수 캐릭터
```

## 🚀 빠른 시작

### 1. pubspec.yaml 설정

```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.otf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.otf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.otf
          weight: 600
        - asset: assets/fonts/Pretendard-Bold.otf
          weight: 700
```

> Pretendard 폰트는 [github.com/orioncactus/pretendard](https://github.com/orioncactus/pretendard) 다운로드.

### 2. main.dart 적용

```dart
import 'package:flutter/material.dart';
import 'theme/theme.dart';

void main() => runApp(const OwnerApp());

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오우너',
      theme: OwnerTheme.light(),
      home: const HomeScreen(),
    );
  }
}
```

### 3. 위젯 사용

```dart
import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(OwnerSpacing.base),
        child: Column(
          children: [
            // 모아 아바타
            const OwnerMoaAvatar(
              size: 200,
              expression: MoaExpression.happy,
            ),

            const SizedBox(height: OwnerSpacing.lg),

            // 3대 스탯
            Row(
              children: [
                Expanded(child: OwnerStatGauge(
                  icon: Icons.bolt,
                  label: '에너지',
                  value: 80,
                  color: OwnerColors.statEnergy,
                )),
                const SizedBox(width: OwnerSpacing.sm),
                Expanded(child: OwnerStatGauge(
                  icon: Icons.water_drop,
                  label: '수분',
                  value: 50,
                  color: OwnerColors.statHydration,
                )),
                const SizedBox(width: OwnerSpacing.sm),
                Expanded(child: OwnerStatGauge(
                  icon: Icons.bedtime,
                  label: '휴식',
                  value: 70,
                  color: OwnerColors.statRest,
                )),
              ],
            ),

            const SizedBox(height: OwnerSpacing.xl),

            // CTA 버튼
            OwnerButton(
              variant: OwnerButtonVariant.primary,
              label: '약속할게요',
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

## 💡 토큰 사용 가이드

### 컬러

```dart
// ✅ 권장: Semantic 토큰
Container(color: OwnerColors.bgPrimary)
Container(color: OwnerColors.actionPrimary)

// ⚠️ 특수 케이스: Core 팔레트
Container(color: OwnerColors.coral500)  // 명확히 브랜드 코랄을 의미할 때만
```

### 타이포그래피

```dart
Text('큰 제목', style: OwnerTypography.h1)
Text('숫자 임팩트', style: OwnerTypography.displayXl)  // NEW v1.1

// 컬러 오버라이드
Text(
  '강조',
  style: OwnerTypography.body.copyWith(
    color: OwnerColors.textBrand,
  ),
)
```

### 스페이싱

```dart
Padding(
  padding: const EdgeInsets.all(OwnerSpacing.base),  // 16px
  child: ...,
)

SizedBox(height: OwnerSpacing.lg),  // 20px
```

## 🧩 표준 컴포넌트 빠른 참조

### OwnerButton

```dart
OwnerButton(
  variant: OwnerButtonVariant.primary,  // primary | secondary | text
  label: '시작할게요',
  fullWidth: true,
  loading: false,
  icon: Icons.share,  // optional
  onPressed: () {},
)
```

### OwnerCard

```dart
OwnerCard(
  variant: OwnerCardVariant.surface,  // surface | elevated | hero
  padding: OwnerSpacing.cardDefault,
  onTap: () {},  // optional
  child: ...,
)
```

### OwnerChip

```dart
OwnerChip(
  label: '+50 XP',
  variant: OwnerChipVariant.defaultStyle,  // default | info | success | warning
  icon: Icons.star,  // optional
)
```

### OwnerStatGauge

```dart
OwnerStatGauge(
  icon: Icons.water_drop,
  label: '수분',
  value: 65,  // 0-100
  color: OwnerColors.statHydration,
  emphasized: false,  // 낮은 스탯 강조 시 true
)
```

### OwnerMoaAvatar

```dart
OwnerMoaAvatar(
  size: 200,
  expression: MoaExpression.happy,  // default/happy/sleepy/sad/...
  stage: MoaStage.owner,            // sprout/small/owner/shining/master
  breathingAnimation: true,         // 기본 true (살아있음 표현)
)
```

### OwnerStreakBadge

```dart
OwnerStreakBadge(days: 12)
```

### OwnerStoryProgressBar

```dart
OwnerStoryProgressBar(
  totalSteps: 4,
  currentStep: 2,  // 1-indexed
)
```

### OwnerCheckbox

```dart
OwnerCheckbox(
  checked: isCompleted,
  size: 28,
  onChanged: (newValue) {},
)
```

### OwnerMoodCard

```dart
OwnerMoodCard(
  emoji: '✨',
  label: '좋아요',
  selected: selectedMood == 'great',
  onPressed: () {},
)
```

### OwnerQuickActionButton

```dart
OwnerQuickActionButton(
  label: '+ 물 한 컵',
  emphasized: false,
  onPressed: () {},
)
```

## 🎯 자주 쓰는 토큰 빠른 참조

### 컬러

| 용도 | 토큰 | HEX |
|------|------|-----|
| 메인 배경 | `bgPrimary` | #FFF8F0 |
| 카드 배경 | `bgSurface` | #FFFFFF |
| 본문 텍스트 | `textPrimary` | #4A2820 |
| 보조 텍스트 | `textSecondary` | #8B6B5C |
| CTA | `actionPrimary` | #FF7B5C |
| 강조 영역 | `bgElevated` | #FFEDE3 |
| 에너지 스탯 | `statEnergy` | #FF7B5C |
| 수분 스탯 | `statHydration` | #85B7EB |
| 휴식 스탯 | `statRest` | #7F77DD |

### 타이포

| 용도 | 토큰 | 크기 |
|------|------|------|
| 풀스크린 임팩트 | `displayXl` | 76px |
| 큰 임팩트 | `display` | 42px |
| 화면 타이틀 | `h1` | 28px |
| 섹션 헤더 | `h2` | 22px |
| 카드 타이틀 | `h3` | 17px |
| 본문 | `body` | 15px |
| 보조 본문 | `bodySm` | 13px |
| 레이블 | `caption` | 12px |
| 버튼 | `button` | 15px |
| 카테고리 | `overline` | 11px |

### 스페이싱

| 용도 | 토큰 | 값 |
|------|------|-----|
| 미세 | `xs` | 4 |
| 작은 갭 | `sm` | 8 |
| 중간 | `md` | 12 |
| 화면 좌우 여백 | `base` | 16 |
| 카드 패딩 | `lg` | 20 |
| 섹션 간격 | `xl` | 24 |
| 큰 섹션 | `xxl` | 32 |
| 페이지 상단 | `xxxl` | 48 |

## 🔒 디자인 룰 (필수 준수)

상세 룰은 `/docs/01_DESIGN_RULES.md` 참조. 핵심만:

- ❌ Hex 코드 직접 사용 금지 (`Color(0xFF...)`)
- ❌ 4의 배수 아닌 스페이싱 금지 (15, 18 등)
- ❌ 그라디언트 금지
- ❌ 죄책감/부담 메시지 금지
- ✅ 토큰 우회 금지 — 새 패턴 필요하면 토큰부터 추가
- ✅ 한 화면에 코랄 영역은 1개만
- ✅ 캐릭터는 항상 호흡 모션 (살아있음)

## 🌙 다크 모드 (V1.2+)

현재 라이트만 지원. 다크 모드 추가 시 `OwnerTheme.dark()` 메서드 추가.
Semantic 토큰만 다른 Core 색상으로 매핑하면 끝.

## 📝 변경 로그

### v1.1.0 (2026-04)
- displayXl 타이포그래피 추가 (76px, 풀스크린 모멘트용)
- chip variant 컬러 시스템 추가 (info/success/warning)
- 11개 표준 컴포넌트 위젯 추가
- bgScrim 알파값 명확화 (50% black)

### v1.0.0 (2026-04)
- 최초 토큰 시스템 구축
- Core + Semantic 컬러 시스템
- 9개 타이포그래피 스타일
- 4px 기반 스페이싱
- 모션 토큰 5단계
