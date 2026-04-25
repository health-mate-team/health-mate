# Feat Summary (앱) — `2026-04-26`

> 상대 문서: [../backend/summary.md](../backend/summary.md)

## 1. 한 줄 요약

**목업디벨롭 JSON**에 맞춰 온보딩·의식·액션·진화 화면과 공용 위젯을 정렬하고, **에셋·Git 훅·논리 단위 커밋** 후 **`main` 원격 푸시**까지 반영했다.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | `main` (로컬 커밋 다수 → `origin/main` 푸시) |
| **변경 영역** | `app`, `docs`, `githooks`, `.gitignore` |
| **주요 파일·경로** | `lib/features/**/presentation/*`, `lib/shared/widgets/owner/*`, `lib/core/theme/owner/*`, `lib/routing/app_router.dart`, `app/assets/오우너 목업디벨롭파일/*`, `githooks/*`, `shared/constants/owner_prefs_keys.dart` |

---

## 3. 상세 작업 내용

### 3.1 구현

- **화면 명세 정합**: 온보딩 이름·목표·모아 만남, 아침 약속(`coral100`·말풍선·약속 prefs), 물/산책 액션, 저녁 의식(다크), 진화 풀스크린(단색 단계 전환).
- **위젯·토큰**: `OwnerSooAvatar`, `OwnerButton.icon`, `OwnerCard.onTap`, `OwnerStatGauge.emphasized`, `OwnerChip.defaultStyle` 별칭.
- **상태·연동**: `WaterActionResult`, 오늘의 약속·완료 여부 `SharedPreferences` 키, 홈 카드와 동기화.
- **에셋**: Pretendard·마스코트 PNG, 목업 JSON·`reference/*.dart` 격리, 디벨롭 README 단일 소스 안내.
- **저장소**: `core/router` 제거, `lib/routing/app_router.dart`로 통일; `.gitignore`에 `.cursor/`; `githooks`로 부적절한 커밋 푸터 차단.

### 3.2 의사결정 & 추론

- 진화·배경 연출은 디자인 룰에 맞춰 **그라디언트 없이** 단색·토큰만 사용.
- 모아 아바타는 당분간 **PNG 유지**; 디벨롭 `CustomPaint` 참고는 `reference/`에만 둠.

### 3.3 설계·확장 포인트

- 물 일일 잔 수·산책 걸음: `health` / pedometer 연동 및 Drift 동기화.
- 진화 공유 버튼: 네이티브 공유 시트 연동.

---

## 4. 검증

- [ ] `cd app && flutter pub get && flutter analyze`
- [ ] 수동: 온보딩 전 구간, 아침 약속 저장 → 홈·저녁 카드, 물 여러 잔, 산책 3상태, 진화 단계

---

## 5. 상대(백엔드)에게 전달·요청

- (이전 일자와 동일 계열) 사용자 프로필·온보딩·무드·**오늘의 약속**·스트릭/XP·스탯(에너지·수분·휴식) API 초안 및 권위 정책 합의.
- 없음 — 블로커 없음.

### 5.1 공통 / 기타

- 없음.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 디벨롭 명세 | `app/assets/오우너 목업디벨롭파일/*.json`, `README.md` |
| 기존 목업 | `app/assets/오우너목업파일/` |
| Git 훅 | `githooks/commit-msg`, `githooks/prepare-commit-msg` (`core.hooksPath=githooks`) |

---

## 7. 다음 액션 (우선순위)

1. 로컬에서 `flutter analyze` 통과 확인.
2. 백엔드 §5 요청에 맞춰 앱 repository/API 클라이언트 스텁 설계.

---

*템플릿: `feat_summary_template_app.md`*
