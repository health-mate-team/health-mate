# Feat Summary (앱) — `2026-05-05`

> 상대 문서: [../backend/summary.md](../backend/summary.md)

## 1. 한 줄 요약

**가설 검증의 마지막 측정 인프라(설문 D0/D14/D28)를 디바이스 단에서 완성**. 베타 등록일 기록 → 윈도우 판정 → 자동 트리거 → 응답 시 `survey_response` 이벤트 송신까지 일관 구현. 부수적으로 morning_promise 의 미사용 필드 제거(전체 warning 박멸), walk_action 의 fake-phase fallback 제거(분석 정직성), WorkoutSession 의 백그라운드 진입 시 wallclock 보정까지 처리.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | `feature/bumpist` (로컬) — `04_SUCCESS_METRICS measurement_window` 측정 회로 |
| **변경 영역** | `app` |
| **주요 파일·경로** | `app/lib/features/survey/**` (NEW: domain·presentation·트리거 서비스·SurveyPage), `app/lib/shared/constants/owner_prefs_keys.dart` (베타 시작일·설문 완료 키), `app/lib/features/onboarding/presentation/onboarding_meet_moa_page.dart` (`ensureBetaStartDate`), `app/lib/features/home/presentation/home_character_page.dart` (자동 트리거), `app/lib/routing/app_router.dart` (`/survey/:surveyId`), `app/lib/features/cycle/presentation/pages/workout_session_page.dart` (`WidgetsBindingObserver`), `app/lib/features/action/presentation/walk_action_page.dart` (fallback 제거), `app/lib/features/morning_ritual/presentation/morning_promise_page.dart` (`_goalId` 제거) |

---

## 3. 상세 작업 내용

### 3.1 구현

- **X1. morning_promise 의 `_goalId` 제거** — `_load` 가 prefs 에서 `goal` 을 읽어 `_recommendedPromise(mood, goal)` 에 직접 전달하므로 필드 자체가 불필요. 제거. **`flutter analyze lib/` 의 유일한 warning 박멸.**

- **X2. walk_action 의 fake-phase 제거** — cycle 입력이 없을 때 `light_cardio__follicular` 로 임의 fallback 하던 부분 제거. cycle 없으면 `workout_completed` 이벤트 자체를 송신 안 함 — 분석 정직성 유지. (cycle 없는 사용자의 산책 활동은 향후 별도 generic 이벤트로 분리.)

- **X3. SurveyTriggerService** — `04_SUCCESS_METRICS measurement_window` 의 D0/D14/D28 ±1일 윈도우 판정. 우선순위는 늦은 게이트가 우선(`finalD28 > pulseD14 > baselineD0`). 이미 완료한 설문은 재트리거 안 함. `ensureBetaStartDate`(첫 onboarding 완료 시 1회 기록), `nextDueSurvey()`(현재 윈도우 내 미완료 설문 반환), `markCompleted(id)`. 의존성: `SharedPreferences`. `now()` 주입 가능 — 단위 테스트 친화적.

- **X4. Survey 도메인 + SurveyPage**
  - `SurveyId` enum 3종(`baselineD0/pulseD14/finalD28`) + `SurveyDefinition` const 매트릭스 — `04_SUCCESS_METRICS` 의 KPI_01·04·05 + OBS_01·03 + 정성 자유응답 5문항을 그대로 옮김.
  - `SurveyQuestionKind`: `likert5 / nps(0-10) / freeText`.
  - `SurveyPage` — Likert 5칸 / NPS 11칸 chip + freeText TextField. 각 응답 시 즉시 `survey_response(survey_id, question_id, response_value)` 이벤트 송신. 모든 질문 답변 후 "제출하기" → `markCompleted` → 홈 복귀.
  - 라우터에 `/survey/:surveyId` 등록. `surveyId` 패스 파라미터를 enum 으로 안전 매핑.

- **X5. 자동 트리거 연결**
  - `OnboardingMeetMoaPage._finish()` 에서 `ensureBetaStartDate()` 호출 — onboarding 완료 직후 D0 시계 시작.
  - `HomeCharacterPage.initState()` 에 `_checkSurveyDue()` 추가 — 첫 프레임 이후 `nextDueSurveyProvider.future` read → 윈도우 내 설문이 있으면 자동 `context.push('/survey/{id}')`. 사용자가 닫고 다시 열면 같은 윈도우 동안은 다시 트리거.

- **X6. WorkoutSession 백그라운드 보정** — `WidgetsBindingObserver` 믹스인 추가. `paused/inactive/hidden` 시 `_pausedAt = now()` 기록 + ticker 정지 + TTS stop. `resumed` 시 wallclock 차이를 `_elapsedSeconds` 에 가산, 남은 시간 초과 시 즉시 완주 처리(`_onFinish`), 아니면 ticker 재가동. `_running == false` 일 땐 보정 없음 — 사용자가 명시 일시정지한 경우와 분리.

### 3.2 의사결정 & 추론

- **설문 트리거 우선순위 = 늦은 게이트 우선** — D0 미완료 + D14 윈도우 진입 케이스에서 D14 가 더 시급(시간 지나면 못 잡음). D0 는 베타 시작 직후 1주일은 안전.
- **응답 시 즉시 이벤트 송신 + 마지막에만 markCompleted** — 사용자가 중간 종료해도 부분 응답이 분석에 남음. KPI 계산은 백엔드에서 questionId 별 유무로 판정.
- **`SurveyPage` 의 freeText 는 onChanged 마다 commit** — 디바운스 없이 매 키 입력. SQLite 로컬 큐라 부담 없음. 서버 동기화 시점에 마지막 값만 보내도록 백엔드와 합의 필요(§5).
- **백그라운드 보정의 임계 처리** — wallclock 차이 ≥ 남은 시간이면 완주 처리. 5분 운동을 1시간 배경 두고 돌아오면 정상 완주로 인정. 이건 H2(KPI_02 운동 완료율) 의 "duration_actual ≥ 0.8 × target" 정의와 일치.

### 3.3 설계·확장 포인트

- **설문 질문 텍스트 다국어** — 현재 한국어 const. 베타 종료 후 글로벌 확장 시 ARB intl 로 이관.
- **펄스 D14 의 3점 척도** — 04_SUCCESS_METRICS 명세는 3점, 우리 구현은 5점 통합. 데이터 매핑 시 5→3 번역 또는 별도 분기 필요.
- **사용자가 설문을 닫고 다시 열어도 같은 윈도우면 재트리거** — 의도적. 다만 "오늘은 그만 보고 싶음" 옵션 + 1일 dismissal 쿨다운 추가 검토 (UX 부담 완화).
- **백그라운드 보정의 `_pausedAt` 정확도** — `paused` 직후 OS 가 isolate 종료하면 `_pausedAt` 도 잃음. 영속 저장(SharedPreferences) 으로 부활 가능하나 오늘 범위 밖.
- **walk_action 의 generic 운동 id** — cycle 없는 사용자도 KPI 측정 대상 — `general_walk` 같은 별도 phase 외 id 추가 + `AnalyticsEvent.workoutCompleted` 의 `phase` 를 nullable 로 변경 검토. 이건 **백엔드 DTO 변경 동반** — 합의 후 작업.

---

## 4. 검증

- [x] `flutter pub get` — 변경 없음 (이전 일자 flutter_tts 그대로).
- [x] `dart run build_runner build` — survey_providers.g.dart 생성. 158 outputs 갱신.
- [x] `flutter analyze lib/` — **0 error, 0 warning**, 66 info(const/deprecated 권고).
- [x] 신규/수정 코드: **0 error / 0 warning**.
- [ ] `flutter test` — 환경 hang 미해결.
- [ ] `flutter run` 수동 QA — 동일 사유.

### 검증 시나리오 (사용자가 환경 복구 후 실행할 것)

1. **D0 트리거**: 새 설치 → 온보딩 끝(meet-moa `_finish`) → home 진입 → 0.x초 후 `/survey/baseline_d0` 자동 push. 2문항(사이클 이해도·PMS 영향) 응답 → 제출 → home 복귀. SQLite `analytics_events` 에 `survey_response` 2행.
2. **D0 dismiss → 같은 날 재트리거**: 위에서 닫기(좌측 X) → home 헤더 인디케이터 탭 후 복귀 → home 다시 들어가면 `_checkSurveyDue()` 가 다시 트리거. (윈도우 내라서)
3. **D14 트리거 시뮬**: prefs 에서 `owner_beta_start_date` 를 14일 전으로 강제 변경 + `surveyD0CompletedAt` 채우기 → home 진입 → `/survey/pulse_d14` 자동 push.
4. **walk_action — cycle 없을 때 이벤트 미송신**: cycle 입력 비우기 → `+ 산책` → 60초+ 진행 → 종료 → SQLite 에 `workout_completed` 행 **없음**. (이전 동작은 `light_cardio__follicular` 로 가짜 송신했음)
5. **WorkoutSession 백그라운드 보정**: 추천 카드 → 시작 → 30초 진행 → 홈 버튼으로 백그라운드 → 60초 후 복귀 → `_elapsedSeconds == 90` 으로 보정 표시 + ticker 재가동.

---

## 5. 상대(백엔드)에게 전달·요청

> 이번 라운드도 앱 단독 변경. 다만 설문 인프라가 디바이스 단에서 완성됐으므로 **베타 시작 D-7 이전에 서버 측 수집·집계가 반드시 완료돼야 함**.

### 5.1 핵심 요청 — 분석 이벤트 수집 API (이전 일자 §5.1 의 후속, 이제 블로커)

이전 일자(2026-05-04 §5.1) 의 `POST /v1/analytics/events:batch` 가 베타 시작 D-7 이전 합의 마감.
**오늘 변경으로 `survey_response` 이벤트가 처음으로 실제 송신되기 시작**. 백엔드가 받지 못하면 KPI_01·04·05 측정 자체가 기록만 되고 집계 불가. 다음 항목을 **명시적으로 응답** 부탁:

1. `survey_response.response_value` 의 타입 — 클라이언트는 항상 `String` 으로 보냄 (likert/nps 도 `"1"~"5"`, `"0"~"10"` 문자열). 백엔드가 `int | string` union 으로 받을지, 모두 `string` 으로 받고 KPI 계산 시 파싱할지 합의 필요. **권장: 모두 `string` + 메타에 `kind` 동봉**(아래 4번).
2. `freeText` 응답의 PII 위험 — 사용자가 자유 응답에 이름·전화번호 적을 가능성. 서버 저장 시 PII 검출 필터(정규식 + 공공 DB) 필요한가? 아니면 디바이스에서 제출 전 알림으로만 처리?
3. `survey_id` enum — 클라이언트는 `baseline_d0 / pulse_d14 / final_d28` 문자열로 보냄. 백엔드 enum 동일 표기로 통일 요청.
4. **이벤트 메타 `kind` 필드 추가 검토** — 현재 6개 이벤트 schema 에 `kind` 가 없음. 분석 시 `survey_response` 의 `response_value` 가 likert/nps/freeText 중 무엇인지 백엔드가 추론해야 하는데, 클라이언트가 `kind: 'likert5' | 'nps' | 'free_text'` 를 같이 보내면 단순. **DTO 합의 시 추가할지 결정 부탁**.

### 5.2 두 번째 요청 — 베타 코호트 마감 처리 정책

`04_SUCCESS_METRICS pass_fail_decision_protocol.step_1_collect` 에 "Day 28 에 모든 KPI 데이터 동결" 명시. 이 시점 이후 송신되는 `survey_response` 는 분석 제외해야 함.

- 백엔드가 `received_ts > beta_cohort_end_ts` 인 응답을 **저장은 하되 KPI 집계에서 제외**하는 플래그(`is_within_window`) 를 ETL 단계에서 계산하는 정책 합의 부탁.
- 또는 클라이언트가 D28+1 부터 트리거 자체를 안 하므로 서버는 단순 저장만 — 어느 쪽이든 책임 명시 필요.

### 5.3 세 번째 요청 — `cycle_inputs` 미저장 정책의 CI 검사

이전 일자 §5.1 에서 "백엔드 PR 템플릿에 명시" 요청. 추가로 **CI 가 스키마 grep 으로 자동 차단**하는 워크플로우 합의:
- `last_period_start_date | average_cycle_length | is_irregular | day_of_cycle | menstrual_start | period_end` 등 키워드가 백엔드 마이그레이션·entity 파일에 추가되면 PR 자동 fail.
- 사람이 깜빡할 때 정책이 코드로 강제됨.

### 5.4 공통 / 기타

- 우선순위 §5.1 > §5.2 > §5.3.
- 베타 출시 D-7 이전에 §5.1 1·3·4 의 명시 응답이 §5 회신으로 와야 dio retrofit 클라이언트 스텁 작성 가능.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 가설 명세 | `docs/planning/owner-femtech-mvp/01_HYPOTHESES.json` |
| 측정 명세 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` |
| 데이터 저장 원칙 (R03) | `docs/planning/owner-femtech-mvp/06_RISKS.json` |
| Survey 도메인 | `app/lib/features/survey/domain/entities/survey.dart` |
| Survey 트리거 서비스 | `app/lib/features/survey/domain/services/survey_trigger_service.dart` |
| Survey 화면 | `app/lib/features/survey/presentation/pages/survey_page.dart` |
| 자동 트리거 (홈) | `app/lib/features/home/presentation/home_character_page.dart#_checkSurveyDue` |
| 베타 시작일 기록 | `app/lib/features/onboarding/presentation/onboarding_meet_moa_page.dart#_finish` |
| 직전 일자 작업 | `docs/2026-05-04_feat/app/summary.md` |

---

## 7. 다음 액션 (우선순위)

1. **시스템 재부팅 + `flutter test`** — 단위 테스트 통과 확인 (이전 일자부터 잔여 블로커). SurveyTriggerService 단위 테스트도 작성 후 실행 가능 시 추가.
2. **`flutter run` 골든패스** — 위 §4 시나리오 5단계.
3. **백엔드 §5.1 응답 받으면 dio retrofit 클라이언트 스텁 + 동기화 잡 구현** — workmanager 배치 + `analytics_events.synced` 플래그 활용.
4. **설문 dismissal 쿨다운** — UX 부담 완화 (오늘 하루 그만보기).
5. **walk 의 cycle 없는 사용자용 `general_walk` id** — 백엔드 §5 의 DTO 합의 필요.
6. **펄스 D14 의 3점 ↔ 5점 척도 매핑** — KPI 계산 시 정확도.
7. `pubspec.yaml` 의 `retrofit_generator` 일시 비활성화 해제 (백엔드 API 연동 시점).

---

*템플릿: `feat_summary_template_app.md`*
