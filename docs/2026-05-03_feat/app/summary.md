# Feat Summary (앱) — `2026-05-03`

> 상대 문서: [../backend/summary.md](../backend/summary.md)

## 1. 한 줄 요약

펨테크 MVP의 **W1-2 마일스톤(사이클 OS + 추천 엔진)** 을 구현 — Drift·Riverpod·Freezed 코드 생성 파이프라인을 처음으로 가동하고, `02_CYCLE_OS.json` 의 4단계 호르몬 주기 모델·정적 프로필·운동 매트릭스·추천 엔진·분석 이벤트 인프라를 도입. 온보딩에 사이클 입력 화면을 추가하고 홈·아침 의식 두 화면을 사이클 단계에 따라 동적으로 분기시켰다. **추가로 운동 실행 화면(fallback player)과 28일 사이클 캘린더(13_cycle_calendar 신규) 두 화면을 더 붙여 H2(운동 완료율) 측정 회로와 H1(사이클 이해도)의 시각화 메커니즘을 완성**.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | `feature/bumpist` (로컬, 미푸시) — 마스터플랜 `docs/planning/owner-femtech-mvp/05_TIMELINE.json` W1-2 |
| **변경 영역** | `app` |
| **주요 파일·경로** | `app/lib/core/db/**`, `app/lib/core/analytics/**`, `app/lib/features/cycle/**` (도메인·데이터·정적 프로필·프로바이더·온보딩 화면·**운동 실행 화면·사이클 캘린더 화면**), `app/lib/features/home/presentation/home_character_page.dart`, `app/lib/features/morning_ritual/presentation/morning_mood_page.dart`, `app/lib/routing/app_router.dart`, `app/lib/core/di/providers.dart`, `app/lib/main.dart`, `app/test/features/cycle/**`, `app/build.yaml`, `app/pubspec.yaml`, `docs/design/owner-mock-develop/reference/{pubspec.yaml,analysis_options.yaml,.gitignore}` (참고용 위젯 폴더 격리) |

---

## 3. 상세 작업 내용

### 3.1 구현

- **인프라 (M1)**: `AppDatabase` (Drift, LazyDatabase + sqlite3_flutter_libs), `cycle_inputs` / `analytics_events` 테이블, `@Riverpod(keepAlive: true) AppDatabase appDatabase`. `pubspec.yaml`에서 `retrofit_generator`를 일시 비활성화 — `retrofit 4.9.2` × `retrofit_generator 9.7.0` 비호환으로 build script 컴파일이 실패해 모든 코드 생성을 막았기 때문. `crypto: ^3.0.5` 추가. `dart run build_runner build` 정상 동작 확인.
- **도메인 모델 (M2)**: `CyclePhase` enum (+ `LutealSubPhase`) — `02_CYCLE_OS.json phases[*].id` 와 1:1 매핑. `CycleInput` / `ComputedState` / `PhaseProfile` / `WorkoutTemplate` Freezed. `kPhaseProfiles` (4단계 정적 프로필 — hormone_state, recommendation_profile, moa_messaging_tone, moa_visual_state 통합) 와 `kWorkoutMatrix` (17개 운동 + `kSkipMatrix` 3건) 를 const 데이터로 옮김. 컬러 토큰은 `OwnerColors`를 직접 참조 — 컴파일 타임에 토큰 심볼 강제.
- **추천 엔진 (M3)**: `PhaseAssignmentService` — `02_CYCLE_OS.computation_logic.phase_assignment_algorithm` 그대로. `dayOfCycle = (days_since % cycleLen) + 1`, phase 분기, luteal sub_phase early/late, missed_period_alert, irregular confidence 0.5. `RecommendationService` — phase priority + skip 제외 + 다양성 + 완료 가산 + 한 줄 rationale (transparency 원칙). 단위 테스트 3개 파일 작성.
- **영속화 + 분석 이벤트 (M4)**: `CycleInputDao` (싱글턴 upsert/watch), `AnalyticsEventDao`. `CycleRepository` 인터페이스 + impl. `AnalyticsEvent` Freezed sealed class 6종 (`appOpen` / `workoutCompleted` / `workoutSkipped` / `morningRitualCompleted` / `cyclePhaseChanged` / `surveyResponse` — `04_SUCCESS_METRICS events_required_in_app` 1:1). `DriftAnalyticsRecorder` + `UserIdHashProvider` (SharedPreferences UUID v4 → SHA-256 해시 — `data_storage_principles` 준수). Riverpod provider 일괄: `cycleInputDao` / `analyticsEventDao` / `cycleRepository` / `analyticsRecorder` / `phaseAssignmentService` / `recommendationService` / `cycleInputStream` / `computedStateNotifier` (phase 전이 시 `cyclePhaseChanged` 자동 송신).
- **온보딩 추가 (M5)**: `OnboardingCyclePage` 신규 — 마지막 생리 시작일 (`showDatePicker`) + 사이클 길이 슬라이더 (21–35일) + 불규칙 토글 + "이 데이터는 이 기기에만 저장돼요" 한 줄 + "나중에 입력할게요" 스킵 (general_lifestyle 모드, edge_case.no_period_input). 라우터에 `/onboarding/cycle` 추가, `onboarding_goal_page` 의 다음 라우트를 `/onboarding/meet-moa` → `/onboarding/cycle` 로 변경.
- **홈 바인딩 (M6)**: `HomeCharacterPage` 를 `ConsumerStatefulWidget` 으로 전환. 사이클 입력이 있을 때만:
  - 헤더 우측 `🍂 22/28` 인디케이터 (`02_CYCLE_OS visual_indicators.locations[0]`)
  - 모아 표정이 `moaExpressionFor(phase, lutealSub)` 로 자동 변경 (sleepy / happy / starEyes / default)
  - "오늘의 추천" 카드 — 단계명 라벨 + 추천 운동 제목 + rationale + duration/타입 chip
  - `initState` 에서 `app_open` 이벤트 송신 (KPI_03 D7/D30 리텐션 측정 가능)
- **아침 의식 바인딩 (M7)**: `MorningMoodPage` 를 `ConsumerStatefulWidget` 으로 전환. 사이클 입력이 있을 때만:
  - 상단에 "황체기 22일차 — [phaseProfile.exampleMessages 중 dayOfYear deterministic 선택]" 라벨 (`visual_indicators.locations[2]`) — 매일 다른 메시지
  - 모아 표정 phase 별 갱신
  - 기분 선택 시 `morning_ritual_completed` 송신 (mood_score / energy_score / phase / dayOfCycle)
- **운동 실행 화면 (N1)**: `WorkoutSessionPage` 신규 — `03_WORKOUT_MATRIX fallback_for_no_video` 명세. 동작 리스트(moves)를 전체 시간에 균등 분할해 현재 동작 강조 + 전체 카운트다운(LinearProgressIndicator) + 모아 동행. 시작/일시정지 + 완료 시 단계별 격려 메시지 카드. `PopScope` 로 진행 중 종료 시 진행률 다이얼로그 → "멈추기" 누르면 `workout_skipped` (skip_reason=`user_exit` 또는 `disposed`), 완주 시 `workout_completed` 송신. **이로써 H2(KPI_02 주 3회+ 완료율) 측정 회로가 처음으로 닫힘**.
- **사이클 캘린더 (N3)**: `CycleCalendarPage` 신규 — `13_cycle_calendar.json` 미작성으로 표기됐던 화면을 `02_CYCLE_OS visual_indicators.locations[1]` 사양에 맞춰 구현. 320pt 원형 ring 에 4단계를 컬러 코딩한 `CustomPaint` 호 + 28(또는 21–35) 일자 점, 오늘 day 는 코랄 보더로 강조. 일자 탭 시 중앙 라벨 갱신 + 상세 카드(단계명·메시지·추천/회피 운동) 표시. 입력 없으면 빈 상태(설정 안내).
- **홈 라우팅 연결 (N2 + N4)**: 헤더 사이클 인디케이터를 `Material+InkWell` 로 감싸 `/cycle/calendar` 푸시. 추천 카드(`OwnerCard.onTap`) 누르면 `/cycle/workout/{workoutId}` 로 푸시 — 운동 id 가 path param 으로 전달되어 화면이 `kWorkoutMatrix` 에서 lookup.

### 3.2 의사결정 & 추론

- **운동 콘텐츠는 fallback (텍스트 + 동작리스트) 로 시작** — `03_WORKOUT_MATRIX.json fallback_for_no_video` 조항. 영상은 외부 촬영 (13일 소요) 이라 오늘 불가. moves 배열을 그대로 표시 + 타이머 가정.
- **기존 `onboarding_goal` (energy / hydration / rest) 는 유지** — 사이클 입력은 별도 단계로 추가. 펨테크 모델과 어긋나지만 이미 만든 화면·prefs·디자인 명세를 폐기하기보다 사이클 단계를 superset 으로 얹는 것이 변경 면적 최소.
- **Drift 이관 범위는 사이클 도메인만** — 기존 11개 화면의 `SharedPreferences` 직접 접근은 그대로 유지. 전수 이관은 분량이 수일 단위라 "오늘 안에 마무리" 합의 범위 밖.
- **Riverpod 은 `@riverpod` 어노테이션 + build_runner watch** — `CLAUDE.md` 원칙 준수. 첫 build_runner 가동에 retrofit_generator 비활성화가 필요했음.
- **민감 데이터는 디바이스 로컬만** — `06_RISKS.json R03` critical. cycle_input·분석 이벤트는 모두 Drift 로컬에만. `analytics_events.synced` 컬럼은 추가했으나 동기화 로직은 미구현 (오늘 범위 밖).
- **모아 표정 매핑** — 황체기 후반 (luteal_late) 만 `sleepy` 로 분기, 나머지는 `02_CYCLE_OS.json moa_visual_state.expression` 그대로 (`starEyes` 자산은 부족해 `OwnerMoaAvatar` 가 default 로 폴백 — 수용 가능).

### 3.3 설계·확장 포인트

- **나머지 화면 사이클 바인딩** — `09_action_water`, `10_action_walk`, `11_evening_ritual`, `12_evolution` 모두 phase 별 분기 가능. 특히 walk 화면은 `light_cardio` 운동의 audio_guide 포맷 전용으로 재정의하고 WorkoutSession 의 일러스트 모드와 분기 처리할 후보.
- **WorkoutSession 의 audio_guide 모드** — 현재는 illustrated(텍스트+동작리스트)만. `light_cardio` 와 `breathing_meditation` 은 `WorkoutFormat.audioGuide` 로 표시되는데 실제 오디오 재생은 미구현. TTS 또는 사전 녹음 mp3 슬롯 필요.
- **분석 이벤트 서버 동기화** — `analytics_events.synced` 플래그 + workmanager 잡. 익명화·동의 UI 필요.
- **추천 엔진의 `userGoalId` 가산** — 현재 미사용. `onboarding_goal` 의 결과를 추천 score 에 반영하면 H2 (행동 변환) 강화 가능.
- **CycleCalendar 의 cycleLength 정확 표시** — 헤더 인디케이터가 28 로 하드코드. `cycleInputStreamProvider` 를 watch 해 동적으로 표시하면 21/35 일 사용자에 정확.
- **WorkoutSession 의 진행 일시정지·재개 시간 누적 정확도** — 현재 `_elapsedSeconds` 만 누적. 일시정지 동안 ticker 정지하므로 정확하지만, 백그라운드 진입 시 보정 로직(pause 시각 기록 → resume 시 보정) 은 미구현.

---

## 4. 검증

- [x] `flutter pub get` / `dart run build_runner build --delete-conflicting-outputs` — 0 error.
- [x] `flutter analyze lib/` — **0 error**, 1 warning (`_goalId` 미사용 — 기존 `morning_promise_page` 잔여 필드, 우리 변경과 무관), 65개 info (const/deprecated 권고).
- [x] 사이클 신규 코드만: **0 error / 0 warning**.
- [ ] `flutter test test/features/cycle/` — **환경 문제로 hang**: `Shell: [ERROR:flutter/runtime/dart_isolate.cc(146)] Could not prepare isolate.` `flutter clean` + 좀비 프로세스 (flutter_tester 13개, dart 10개) 강제 종료 후에도 동일. Flutter SDK 측 isolate 부팅 실패로 추정 — 시스템 재부팅 / SDK 재설치 / Visual Studio Build Tools 점검 후 재시도 필요.
- [ ] 수동: `flutter run` — 위와 동일 사유로 미실시. 빌드 자체는 analyze 통과.

### 검증 시나리오 (재부팅 후 사용자가 실행할 것)

1. `cd app && flutter test test/features/cycle/` — 단위 테스트 4개 파일 (phase_profiles, phase_assignment_service, recommendation_service, cycle_repository_impl) 통과 확인.
2. `flutter run` — splash → onboarding/welcome → name → goal → **cycle (NEW)** → meet-moa → home.
3. cycle 화면에서 마지막 생리일 = 오늘-3일, 28일 입력.
4. home — 헤더 우측 `🌑 4/28` (월경기 인디케이터) + "오늘의 추천 — 월경기 따뜻한 5분 요가" 카드 표시 예상.
5. morning/mood — 상단 "월경기 4일차 — [메시지]" 라벨, 모아 표정 sleepy.
6. **추천 카드 탭** → `/cycle/workout/stretching_yoga__menstrual` 진입 → 시작 → 5분 카운트다운 → 완주 → "잘 했어요!" → home 복귀. SQLite `analytics_events` 에 `workout_completed` 행 추가.
7. **헤더의 `🌑 4/28` 인디케이터 탭** → `/cycle/calendar` 진입 → 28개 일자 점이 4단계 컬러 호 위에 배치, 4번째 점이 코랄 보더로 강조 → 다른 일자 탭 시 중앙 라벨·상세 카드 갱신.
8. SQLite 파일 (`getApplicationDocumentsDirectory()/health_mate.sqlite`) — `cycle_inputs` 1행, `analytics_events` 에 `app_open` + `morning_ritual_completed` + `workout_completed` 행.

---

## 5. 상대(백엔드)에게 전달·요청

- **현재 분석 이벤트는 디바이스 로컬에만 적재**. 베타 단계에 서버 수집이 필요해지면 다음 6개 이벤트의 `POST /analytics/batch` 엔드포인트 + DTO 합의 필요:
  - `app_open(session_id, ts)`
  - `workout_completed(workout_id, phase, duration_target_seconds, duration_actual_seconds, ts)`
  - `workout_skipped(workout_id, phase, skip_reason?, ts)`
  - `morning_ritual_completed(mood_score, energy_score?, phase?, day_of_cycle?, ts)`
  - `cycle_phase_changed(from_phase, to_phase, day_of_cycle, ts)`
  - `survey_response(survey_id, question_id, response_value, ts)`
  - 모든 이벤트 페이로드에 `user_id_hash` (SHA-256, 디바이스 UUID 기반) 동봉. 익명화 정책 (`04_SUCCESS_METRICS data_storage_principles`) 합의 필요.
- **사이클 데이터는 서버 동기화 대상 아님** (`06_RISKS R03 critical`). 백엔드는 cycle_input 을 절대 저장하지 않는다는 정책에 동의 요청.
- **이전 일자 (2026-04-26) 의 잔여 요청도 유효**: 사용자 프로필·온보딩·무드·오늘의 약속·스트릭/XP·스탯 API 초안 합의 필요.

### 5.1 공통 / 기타

- 마스터 플랜 `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json analytics_implementation` 가 SOURCE OF TRUTH — 백엔드 DTO 설계 시 이 명세 우선.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 마스터 플랜 인덱스 | `docs/planning/owner-femtech-mvp/00_OVERVIEW.md` |
| 사이클 OS 명세 (SOURCE OF TRUTH) | `docs/planning/owner-femtech-mvp/02_CYCLE_OS.json` |
| 운동 매트릭스 명세 | `docs/planning/owner-femtech-mvp/03_WORKOUT_MATRIX.json` |
| 분석 이벤트 명세 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` |
| 가설·합격선 | `docs/planning/owner-femtech-mvp/01_HYPOTHESES.json` |
| 리스크 | `docs/planning/owner-femtech-mvp/06_RISKS.json` |
| 사이클 도메인 트리 | `app/lib/features/cycle/` |
| Drift DB | `app/lib/core/db/` |
| 분석 이벤트 인프라 | `app/lib/core/analytics/` |
| 작업 계획 (오늘) | `C:\Users\박수범\.claude\plans\jazzy-orbiting-floyd.md` |

---

## 7. 다음 액션 (우선순위)

1. **시스템 재부팅 + `flutter test test/features/cycle/`** — 단위 테스트 통과 확인. 안 되면 `flutter clean && flutter pub get && flutter precache --no-android --no-ios`.
2. **`flutter run` 으로 골든 패스 수동 QA** — 위 §4 시나리오 + 추천 카드 탭 → WorkoutSession 시작·완료·중단 → analytics_events 검증, 헤더 인디케이터 탭 → CycleCalendar 진입.
3. **나머지 화면 (action/walk, action/water, evening, evolution) 사이클 바인딩** — phase 별 메시지·표정·추천 분기. walk 는 light_cardio audio_guide 전용으로 재정의 검토.
4. **WorkoutSession audio_guide 모드** — `breathing_meditation`, `light_cardio` 는 텍스트보다 음성 가이드가 본질. TTS 또는 사전 녹음 mp3 통합.
5. **추천 엔진 `userGoalId` 가산** — `OnboardingGoalPage` 결과를 `RecommendationService.recommendForToday` 에 전달.
6. **분석 이벤트 서버 동기화 + 동의 UI** — `analytics_events.synced` 플래그 활용 + workmanager 배치 + 첫 진입 시 동의 다이얼로그.
7. `pubspec.yaml` 의 `retrofit_generator` 일시 비활성화 해제 — 백엔드 API 연동 시작 시점에 버전 핀 후 재도입.

---

*템플릿: `feat_summary_template_app.md`*
