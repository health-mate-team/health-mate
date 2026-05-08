# Feat Summary (앱) — `2026-04-25`

> 상대 문서: [../backend/summary.md](../backend/summary.md)

## 1. 한 줄 요약

오우너 브랜드 기준 **디자인 토큰·Cursor 룰·목업 JSON에 맞춘 공용 위젯·초기 네비 플로우(스플래시/온보딩/아침의식/홈)**를 앱에 반영하고, **일일 작업 문서 구조**를 `docs/`에 정의했다.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | (로컬 작업, 브랜치 미명시) |
| **변경 영역** | `app` |
| **주요 파일·경로** | `lib/core/theme/owner/*`, `lib/shared/widgets/owner/*`, `lib/routing/app_router.dart`, `lib/features/{splash,onboarding,morning_ritual,home}/presentation/*`, `.cursor/rules/owner-design.mdc`, `app/assets/fonts/Pretendard-*.otf`, `app/assets/images/mascot/*` |

---

## 3. 상세 작업 내용

### 3.1 구현

- **마스코트 에셋**: `app/assets/images/mascot/` 정리, `MascotConstants` / `MascotIconAssets`.
- **오우너 디자인 시스템**: `lib/core/theme/owner/`, Pretendard, `OwnerTheme.light()`.
- **목업 연동 위젯**: `OwnerButton`, `OwnerCard`, `OwnerChip`, `OwnerStoryProgressBar`, `OwnerStatGauge`, `OwnerQuickActionButton`, `OwnerMoodCard`, `OwnerStreakBadge`, `OwnerMoaAvatar`, `OwnerCheckbox`.
- **타이포 v1.1**: `OwnerTypography.displayXl`.
- **화면 스텁**: 스플래시, 온보딩 환영, 아침 무드, 캐릭터 홈.
- **라우팅**: `lib/routing/app_router.dart`, `themeMode: ThemeMode.light`.

### 3.2 의사결정 & 추론

- 라우터는 `lib/routing/`에 두어 `core`의 feature 의존 회피.
- 온보딩 MVP는 한 화면에서 홈 + `owner_onboarding_done` 저장으로 단순화.

### 3.3 설계·확장 포인트

- `owner_onboarding_done` → 서버 온보딩 스텝과 동기화 필요.
- 홈 스탯·약속 → Drift + Nest API.
- 남은 JSON 화면 `03`~`05`, `07`, `09`~`12` 등.

---

## 4. 검증

- [ ] `cd app && flutter pub get && flutter analyze`
- [ ] 수동: 스플래시 → 온보딩 → 홈; 아침 의식 → 홈

---

## 5. 상대(백엔드)에게 전달·요청

- 사용자 **프로필**(표시 이름), **온보딩 완료 스텝**, **아침 무드** 기록 API 초안.
- **스트릭 / XP / 오늘의 약속** 도메인·엔드포인트(홈 연동용 최소 CRUD 또는 일일 스냅샷).
- **에너지·수분·휴식** 스탯: 클라이언트 계산 vs 서버 권위 정책 합의.
- (선택) 아침 7시 / 저녁 8시 리추얼 푸시 설계.

### 5.1 공통 / 기타

- 디자인 단일 소스: `01_DESIGN_RULES.md` vs Figma 차이 시 토큰 명세 갱신.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 디자인 룰 | `docs/design/owner-mock/01_DESIGN_RULES.md` |
| 화면 인덱스 | `docs/design/owner-mock/00_index.json` |
| 토큰 추가 | `docs/design/owner-mock/token_additions.json` |
| Cursor 룰 | `.cursor/rules/owner-design.mdc`, `.cursor/rules/docs-feat-summary.mdc` |

---

## 7. 다음 액션 (우선순위)

1. **P0**: `flutter analyze` 통과, 온보딩 플로우 명세 정렬.
2. **P1**: 홈 스탯·약속 API 스펙 합의 후 repository 스텁.

---

*템플릿: `docs/_templates/feat_summary_template_app.md`*
