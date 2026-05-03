# Feat Summary (앱) — `2026-05-04`

> 상대 문서: [../backend/summary.md](../backend/summary.md)

## 1. 한 줄 요약

펨테크 MVP의 사이클 OS를 **나머지 화면(action/water·walk, evening_ritual)에 확산**시키고, **추천 엔진의 userGoalId 가산**과 **WorkoutSession 의 audio_guide(TTS) 모드**를 도입. 운동 매트릭스의 `breathing_meditation`·`light_cardio` 가 음성 안내로 작동 가능해졌고, 산책 화면도 종료 시 `workout_completed` 이벤트를 송신해 KPI_02 측정 회로의 두 번째 진입로가 열림.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | `feature/bumpist` (로컬) — 마스터플랜 W1-2 확장 |
| **변경 영역** | `app` |
| **주요 파일·경로** | `app/lib/features/cycle/domain/services/recommendation_service.dart` (goalBoosts), `app/lib/features/cycle/presentation/pages/workout_session_page.dart` (TTS), `app/lib/features/home/presentation/home_character_page.dart` (goalId 주입), `app/lib/features/action/presentation/{water_action_page,walk_action_page}.dart`, `app/lib/features/evening_ritual/presentation/evening_ritual_page.dart`, `app/pubspec.yaml` (flutter_tts ^4.2.0) |

---

## 3. 상세 작업 내용

### 3.1 구현

- **W1. 추천 엔진 userGoalId 가산** — `RecommendationService.recommendForToday` 가 받기만 하고 안 쓰던 `userGoalId` 를 score 에 반영. 4개 목표(`energy/hydration/rest/shape`)를 운동 타입(`hiit/strength_training/light_cardio/breathing_meditation/stretching_yoga`)에 가중치(1–4점) 매핑. phase priority(10단위) 보다 작은 단위라 phase 우선순위는 깨지 않음. rationale 한 줄에도 "활기 목표에 잘 맞아요" 같은 보조 라인 합성. 홈에서 `OwnerPrefsKeys.goalId` 를 SharedPreferences 로 읽어 `_CycleRecommendationCard` 에 주입.

- **W2-A. water_action 사이클 바인딩** — `ConsumerStatefulWidget` 전환. 4단계별 수분 가이드 한 줄 추가 ("월경기엔 따뜻한 물·차가 좋아요" / "황체기엔 부기 완화에 미지근한 물" 등). UI 골격은 변경 없음.

- **W2-B. walk_action 사이클 바인딩** — `ConsumerStatefulWidget` 전환. `_BeforeStart` 에 `cyclePhase` 파라미터를 받아 phase 별 모아 표정과 격려 메시지("천천히, 가볍게 걸어볼까요" / "활기차게! 오늘 컨디션 최고예요" 등) 분기. `_endWalk` 에서 60초 이상 산책했으면 `workout_completed(workoutId='light_cardio__{phase}', durationTarget=300)` 송신 — **light_cardio 카테고리의 두 번째 진입로**.

- **W3. evening_ritual 사이클 바인딩** — `ConsumerStatefulWidget` 전환. 상단 "저녁 의식 · 2분" 칩 옆에 단계 칩 추가: "🍂 황체기 22일차 · 수면 8시간" (sleepTargetHours 반영). 어두운 배경에 phase colorToken 25% 알파로 칩 배경. (evolution 화면은 사이클 메커니즘과 직교 — 이번 라운드 범위 밖.)

- **W4. WorkoutSession audio_guide 모드** — `flutter_tts ^4.2.0` 추가. `WorkoutFormat.audioGuide` 인 운동만 TTS 활성화 (light_cardio, breathing_meditation 전부). 시작 시 "운동 제목 · 시작할게요" 발화, 동작 인덱스가 바뀌는 1초마다 해당 move 텍스트 발화 (중복 방지로 `_lastSpokenMoveIndex` 체크), 일시정지 시 stop, 완주 시 "잘 했어요. 운동 끝났어요". 한국어 ko-KR · speech rate 0.5 · pitch 1.0.

### 3.2 의사결정 & 추론

- **goalBoost 가중치는 phase priority 보다 작게** — phase 추천이 깨지면 H1(사이클 이해) 메커니즘의 일관성이 무너짐. goalBoost 는 동률 후보 중에서만 의미가 갈리도록 4단위 이하.
- **walk_action 의 60초 임계값** — 단순 진입·즉시 종료를 `workout_completed` 로 잡으면 KPI_02 가 부정확. 사용자가 의도적으로 60초 이상 머물면 운동으로 간주. 그 미만은 이벤트 송신 안 함.
- **TTS 발화 시점** — 매 초가 아니라 동작 인덱스 변경 시점. 5분 운동 4개 동작이면 약 75초 마다 1회 발화. 사용자 피로 최소.
- **evolution 화면은 사이클과 분리** — 진화는 XP·레벨 기반 게이미피케이션이라 호르몬 주기와 직교. 단계 라벨을 끼워 넣으면 두 메커니즘이 섞여 H4(자기 돌봄) 검증 시 신호 분리 어려움.

### 3.3 설계·확장 포인트

- **TTS 음성 설정 사용자 커스터마이즈** — 현재 ko-KR/0.5/1.0 하드코드. 설정 화면에서 속도·성별·음소거 옵션 노출 가능.
- **walk_action 의 workoutId fallback** — cycle_input 이 없을 때 `light_cardio__follicular` 로 두는데, 이건 분석 시 노이즈가 됨. cycle 없으면 별도 generic 운동 id (`general_walk`) 로 분리하는 것이 정확.
- **evening_ritual 의 단계 라벨이 어두운 배경에서 가독성** — phase colorToken 의 25% 알파 + 흰 텍스트로 처리했지만 menstrual(cocoa800) 은 배경과 섞임. 단계별로 텍스트 색을 보조 라이트 톤으로 다르게 처리하는 후속 검토.
- **goal-phase 가중치 매트릭스의 캘리브레이션** — 현재는 추정. 베타 후 KPI_02 데이터로 어떤 조합이 실제 완료율을 끌어올리는지 검증 후 갱신.

---

## 4. 검증

- [x] `flutter pub get` (flutter_tts 추가) — 성공.
- [x] `flutter analyze lib/` — **0 error**, 1 warning(기존 잔여 `_goalId` — morning_promise_page, 우리 변경 외), 64 info(const/deprecated 권고).
- [x] 사이클 신규/수정 코드: **0 error / 0 warning**.
- [ ] `flutter test` — 환경 hang 미해결(이전 일자 동일 사유).
- [ ] 수동 QA: `flutter run` — 동일 사유로 미실시.

### 검증 시나리오 (사용자가 환경 복구 후 실행할 것)

1. **goalId 주입 확인**: 온보딩 goal=`rest` 선택 → home 추천 카드에 `breathing_meditation` 또는 `stretching_yoga` 추천 + rationale 끝에 "잘 쉬기 목표에 어울려요" 보조 라인.
2. **water_action**: cycle 입력 후 home → "+ 물 한 컵" → 시트 하단 캡션에 "월경기엔 따뜻한 물·차가 좋아요" 표시.
3. **walk_action**: home → "+ 산책" → 시작 화면 메시지 단계별 분기 + 60초 이상 → 종료 → SQLite analytics_events 에 `workout_completed(workoutId=light_cardio__{phase})` 1행.
4. **evening_ritual**: cycle 입력 후 evening 진입 → 상단 단계 칩 "🍂 황체기 22일차 · 수면 8시간" 표시.
5. **WorkoutSession TTS**: home 추천 카드가 `breathing_meditation__menstrual` 인 상태에서 탭 → 시작 → "월경기 통증 완화 호흡 3분 · 시작할게요" 음성 → 동작 바뀔 때마다 "들숨 4초", "참기 7초", "날숨 8초" 음성.

---

## 5. 상대(백엔드)에게 전달·요청

> 이번 라운드는 앱 단독 변경이지만, 다음 백엔드 작업이 시작되기 전 합의가 필요한 항목 정리.

### 5.1 핵심 요청 — 분석 이벤트 수집 API 스펙 확정

지금까지 누적된 6개 이벤트(2026-05-03 §5 에서 한 번 언급)를 **베타 시작 D-7 이전에 서버 수집 가능 상태**로 만들어야 KPI 측정이 시작됨. 다음 합의가 필요:

1. **엔드포인트**: `POST /v1/analytics/events:batch`
   - 요청: `{ events: AnalyticsEvent[], device_user_hash: string }`
   - 응답: `{ accepted: number, rejected: number, server_ts: ISO8601 }` (idempotency 키는 client_event_id 로 중복 차단)
2. **DTO 스펙**: 04_SUCCESS_METRICS.json `analytics_implementation.events_required_in_app` 6개 그대로.
   - `app_open(session_id, ts)`
   - `workout_completed(workout_id, phase, duration_target_seconds, duration_actual_seconds, ts)`
   - `workout_skipped(workout_id, phase, skip_reason?, ts)`
   - `morning_ritual_completed(mood_score, energy_score?, phase?, day_of_cycle?, ts)`
   - `cycle_phase_changed(from_phase, to_phase, day_of_cycle, ts)`
   - `survey_response(survey_id, question_id, response_value, ts)`
3. **익명화 정책 합의**: 06_RISKS R03 critical. user_id_hash 외에 IP·이메일·생년월일은 수집 금지. 백엔드 스키마에 `user_email`/`birthday` 컬럼 자체가 없어야 함.
4. **사이클 데이터 미저장 보장**: `cycle_inputs` (last_period_start_date, average_cycle_length, is_irregular) 는 디바이스 로컬에만. 서버 DB 에 어떤 형태로도 컬럼 추가하지 않을 것 — **이건 정책 차원에서 백엔드 PR 리뷰어가 차단해야 함**.

### 5.2 두 번째 요청 — 운동 콘텐츠 메타데이터 API (Phase 2)

현재 운동 매트릭스 17개는 `app/lib/features/cycle/static_data/workout_matrix.dart` 에 const 로 박혀 있음. 영상 촬영 후 v1.1 에 영상 URL·일러스트 SVG 가 추가되면 클라 강제 업데이트 없이 갱신할 수 있도록:

- `GET /v1/workouts?phase={phaseId}&format={video|illustrated|audioGuide}` — 운동 메타데이터 (제목·설명·동작·duration·assetUrls).
- 클라이언트는 첫 진입 시 동기화 후 Drift 에 캐시. 오프라인 우선.

### 5.3 세 번째 요청 — Goal 가중치 캘리브레이션 데이터

W1 의 `_goalBoosts` 매트릭스는 추정값. 베타 4주 후 다음 분석을 백엔드에서 받고 싶음:

- `GET /v1/internal/recommendation-stats?period=beta_w1_w4` → `{ goalId × workoutType: { recommended_count, completed_count, completion_rate } }` 표.
- 사내 대시보드용. 외부 노출 X.

### 5.4 공통 / 기타

- 마스터 플랜의 W3-W4(베타 인프라) 시점에 위 1·2·3 모두 정렬돼야 함. **우선순위 1 > 2 > 3**.
- 앱이 보내는 `phase` 값 enum: `menstrual / follicular / ovulatory / luteal` (소문자 snake_case 아님, 단순 영문). 백엔드 enum 정의 시 동일 표기.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 마스터 플랜 인덱스 | `docs/planning/owner-femtech-mvp/00_OVERVIEW.md` |
| 사이클 OS 명세 | `docs/planning/owner-femtech-mvp/02_CYCLE_OS.json` |
| 분석 이벤트 명세 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` |
| 리스크 (R03 데이터 보안) | `docs/planning/owner-femtech-mvp/06_RISKS.json` |
| 직전 일자 작업 | `docs/2026-05-03_feat/app/summary.md` |
| 추천 엔진 | `app/lib/features/cycle/domain/services/recommendation_service.dart` |
| TTS 통합 | `app/lib/features/cycle/presentation/pages/workout_session_page.dart` |

---

## 7. 다음 액션 (우선순위)

1. **시스템 재부팅 + `flutter test`** — 단위 테스트 통과 확인 (이전 일자부터 잔여 블로커).
2. **`flutter run` 골든패스** — 위 §4 시나리오 5단계.
3. **WorkoutSession 의 audio_guide 음성 설정 UI** — 속도·음소거.
4. **walk_action 의 cycle 없을 때 generic id 분리** — 분석 노이즈 제거.
5. **morning_promise_page 정리** — 미사용 `_goalId` 필드 제거 또는 사이클 메시지에 활용.
6. **백엔드 §5.1 요청에 따른 API 스펙 합의** — 베타 D-7 이전 마감.
7. `pubspec.yaml` 의 `retrofit_generator` 일시 비활성화 해제 (백엔드 API 연동 시점).

---

*템플릿: `feat_summary_template_app.md`*
