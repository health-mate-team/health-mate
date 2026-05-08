# Backend API 검증 결과

---

## Phase P0 검증 — 2026-05-07

### 단위 테스트 (Jest)

| 케이스 | 파일 | 결과 | 오류 위치 |
|---|---|---|---|
| [Happy] 신규 이메일 회원가입 → access_token 반환 | auth.service.spec.ts | ✅ PASS | — |
| [Happy] bcrypt 해시 저장 확인 | auth.service.spec.ts | ✅ PASS | — |
| [오류] 중복 이메일 → ConflictException(409) | auth.service.spec.ts | ✅ PASS | — |
| [Happy] 올바른 credentials → access_token + is_onboarding_completed | auth.service.spec.ts | ✅ PASS | — |
| [오류] 존재하지 않는 이메일 → UnauthorizedException | auth.service.spec.ts | ✅ PASS | — |
| [경계] 비밀번호 불일치 → UnauthorizedException | auth.service.spec.ts | ✅ PASS | — |
| [Happy] 온보딩 완료 → initial_stats + current_phase 반환 | onboarding.service.spec.ts | ✅ PASS | — |
| [Happy] user.isOnboardingCompleted = true 업데이트 | onboarding.service.spec.ts | ✅ PASS | — |
| [Happy] initial_stats 초기값 검증 (energy/hydration/mood=50, xp=0, level=1) | onboarding.service.spec.ts | ✅ PASS | — |
| [경계] 생리 시작 직후 (day 1) → menstrual | onboarding.service.spec.ts | ✅ PASS | — |
| [경계] 생리 종료 직후 (day 8) → follicular | onboarding.service.spec.ts | ✅ PASS | — |

**Jest 결과: 11/11 PASS** (수정 1건: `onboarding.service.ts` — `statRepo.create` 초기값 미명시)

---

### 통합 테스트 (SQLite in-memory, NestJS supertest)

> 검증 방식: Docker Desktop 미실행 환경 → SQLite 인메모리 DB + supertest로 test-phase.sh p0 동일 시나리오 재현

| 케이스 | 기대값 | 실제값 | 결과 | 오류 위치 |
|---|---|---|---|---|
| POST /auth/register | 201 + data.access_token | 201 + access_token | ✅ PASS | — |
| POST /auth/register (중복) | 409 | 409 | ✅ PASS | — |
| POST /auth/login | 200 + is_onboarding_completed | 200 + is_onboarding_completed | ✅ PASS | — |
| GET /users/me (토큰 없음) | 401 | 401 | ✅ PASS | — |
| GET /users/me (토큰 있음) | 200 + data.name 일치 | 200 + "테스터" | ✅ PASS | — |
| POST /onboarding/complete | 200 + initial_stats + current_phase | 200 + 두 필드 모두 존재 | ✅ PASS | — |
| GET /users/me (온보딩 후) | is_onboarding_completed: true | true | ✅ PASS | — |

**통합 테스트 결과: 7/7 PASS**

### Docker 실환경 테스트 (PostgreSQL + test-phase.sh p0) — 2026-05-07

| 케이스 | 결과 |
|---|---|
| POST /auth/register → 201 + access_token | ✅ PASS |
| POST /auth/register (중복) → 409 | ✅ PASS |
| POST /auth/login → 200 + is_onboarding_completed | ✅ PASS |
| GET /users/me (토큰 없음) → 401 | ✅ PASS |
| GET /users/me (토큰 있음) → 200 + name 일치 | ✅ PASS |
| POST /onboarding/complete → 200 + initial_stats + current_phase | ✅ PASS |
| GET /users/me (온보딩 후) → is_onboarding_completed: true | ✅ PASS |

**Docker 실환경 결과: 13/13 PASS** (필드 검증 포함)

**수정 이력:**
1. `onboarding.service.ts` — `statRepo.create` 초기값 미명시(`total_xp`, `level` 등) → Backend 버그, 즉각 수정
2. `p0.integration.spec.ts` — JwtModule 서명키 ≠ JwtStrategy 검증키 불일치 → 테스트 설정 오류, env 변수 통일

---

## Phase P1 검증 — 2026-05-07

### 단위 테스트 (Jest)

| 케이스 | 파일 | 결과 |
|---|---|---|
| [경계] day 1 → menstrual | cycle.service.spec.ts | ✅ PASS |
| [경계] day 5 (period=5) → menstrual 마지막 | cycle.service.spec.ts | ✅ PASS |
| [경계] day 6 → follicular 시작 | cycle.service.spec.ts | ✅ PASS |
| [경계] day 13 → follicular 마지막 | cycle.service.spec.ts | ✅ PASS |
| [경계] day 14 → ovulation 시작 | cycle.service.spec.ts | ✅ PASS |
| [경계] day 15 → ovulation 마지막 | cycle.service.spec.ts | ✅ PASS |
| [경계] day 16 → luteal 시작 | cycle.service.spec.ts | ✅ PASS |
| [Happy] period=7, day 7 → menstrual | cycle.service.spec.ts | ✅ PASS |
| [Happy] 기분3 → XP+10, recommended_promise 반환 | rituals.service.spec.ts | ✅ PASS |
| [오류] 중복 기분 기록 → BadRequestException | rituals.service.spec.ts | ✅ PASS |
| [Happy] promise_kept=true → xp_earned 60 | rituals.service.spec.ts | ✅ PASS |
| [Happy] promise_kept=false → xp_earned 10 | rituals.service.spec.ts | ✅ PASS |
| [오류] 중복 저녁 완료 → BadRequestException | rituals.service.spec.ts | ✅ PASS |

**Jest 결과: 13/13 PASS**

---

### 통합 테스트 (SQLite in-memory, NestJS supertest)

| 케이스 | 기대값 | 결과 |
|---|---|---|
| 회원가입 + 온보딩 | 201 + 200 | ✅ PASS |
| GET /cycle/current | day_of_cycle=10, follicular | ✅ PASS |
| PATCH /cycle/settings | goal_type 업데이트 | ✅ PASS |
| GET /cycle/calendar | days 배열 반환 (28+개) | ✅ PASS |
| GET /rituals/today | 초기 상태 null | ✅ PASS |
| POST /rituals/morning/mood | XP+10, recommended_promise | ✅ PASS |
| POST /rituals/morning/mood (중복) | 400 | ✅ PASS |
| POST /rituals/morning/promise | 약속 저장 | ✅ PASS |
| POST /rituals/evening (promise_kept=true) | xp_earned=60 | ✅ PASS |
| POST /rituals/evening (중복) | 400 | ✅ PASS |
| GET /stats/today | user+stats+cycle+ritual 전체 | ✅ PASS |

**통합 테스트 결과: 11/11 PASS**

**수정 이력:**
1. `daily-ritual.entity.ts` — `number|null` 유니온 타입 → `type: 'integer'` 명시 (SQLite 호환)
2. `daily-ritual.entity.ts` — `Date|null` → `type: 'text'` ISO 문자열 저장 (SQLite 호환)
3. `cycle.service.ts` — 날짜 계산 UTC 기준 → 로컬 기준 (`localDateString` 헬퍼, KST 타임존 오프셋 버그 수정)

### Docker 실환경 테스트 (PostgreSQL + test-phase.sh p1) — 2026-05-07

| 케이스 | 결과 |
|---|---|
| GET /cycle/current → current_phase + day_of_cycle | ✅ PASS |
| GET /rituals/today → morning_mood=null, evening_completed=false | ✅ PASS |
| POST /rituals/morning/mood → XP+10, recommended_promise | ✅ PASS |
| POST /rituals/morning/promise → promise 저장 | ✅ PASS |
| POST /rituals/evening (promise_kept=true) → xp_earned=60 | ✅ PASS |
| GET /stats/today → user+stats+cycle+today_ritual 전체 | ✅ PASS |

**Docker 실환경 결과: 21/21 PASS** (필드 검증 포함)

---

## INFRA-codes 검증 결과 — 2026-05-08

### Stage 1 — Backend API 명세
| 케이스 | 기대 | 결과 |
|---|---|---|
| Jest `codes.integration.spec` SQLite in-memory | 6 PASS | ✅ 6/6 |
| Docker curl GET /codes/mood (mood 4개, numericValue 5,3,2,1) | 200 + count 4 | ✅ |
| Docker curl GET /codes/evening_mood (4개) | 200 + count 4 | ✅ |
| Docker curl GET /codes/goal_option (4개 + accent_color/subtitle metadata) | 200 + metadata 존재 | ✅ |
| Docker curl GET /codes?groups=mood,evening_mood,goal_option (배치) | 각 4개 | ✅ |
| 비로그인 GET /codes/mood | 200 (가드 제거 후) | ✅ |
| displayOrder 오름차순 (0,1,2,3) | 정렬 일치 | ✅ |

**Docker 실환경 결과: 13/13 PASS**

### Stage 2 — Flutter 실동작 (Playwright + Network 캡처)
| 시나리오 | 결과 | 비고 |
|---|---|---|
| Flutter web 빌드 + splash 진입 | ✅ | port 3000, dart-define API_BASE_URL 주입 |
| splash → /onboarding/welcome 자동 라우팅 (1500ms) | ✅ | |
| codes API 호출 발생 (`GET /api/codes?groups=...`) | ✅ | warmup from `splash_page._warmupCodes` |
| 응답 200 OK (가드 제거 후) | ✅ | console 0 errors |
| onboarding/welcome 화면 렌더링 | ✅ | 마스코트 + "시작할게요" 버튼 |

### 수정 이력
1. **Backend**: `CodesController` `@UseGuards(JwtAuthGuard)` 제거 → public 엔드포인트로 변경 (비로그인 splash/onboarding에서 사용 가능). `codes.integration.spec.ts`의 401 테스트 케이스 → 200 public 검증으로 갱신.
2. **Backend**: Docker 컨테이너 재빌드 (codes 모듈 dist 누락 → `docker compose up -d --build backend`).
3. **Flutter**: `ApiConstants.baseUrl` `/api` prefix 추가 (`http://10.0.2.2:3001/api`).
4. **Flutter**: `OwnerMoodCard.onTap` non-nullable → `VoidCallback?` 변경 (morning_mood_page에서 disabled 상태 표현 위해).
5. **Flutter**: `splash_page.dart`를 `ConsumerStatefulWidget`으로 변환 + `codesProvider` warmup 추가.

### 미해결 / 보류
- **Frontend overflow**: onboarding/welcome 화면 BOTTOM OVERFLOWED BY 34px (viewport 종속, Frontend 별도 세션).
- **옵션 표시 화면 단위 검증**: morning_mood/evening_ritual/onboarding_goal 화면에서 codes 옵션이 실제로 4개씩 렌더되는지 — P0/P1 검증 시 부수 확인.

---

## P0+P1 통합 검증 결과 — 2026-05-08

### 결정: Backend = 진실 + 게스트 가입 (MVP)
- DTO contract 픽스 시 Backend 실제 구현을 진실로 삼음 (API_SPEC.md는 차후 정정 대상으로 분리)
- 디자인 흐름에 email/password 입력 화면 부재 → 게스트 가입 자동 생성 (`guest_<ts>_<rand>@guest.healthmate.app` + 16자 랜덤 비밀번호)
- Backend `goal_type` enum: `['energy', 'weight', 'mood', 'fitness']` → `['energy', 'hydration', 'rest', 'fitness']`로 수정 (product semantic 정합성)
- Backend `daily_stats`에 `restScore` 컬럼 추가 (UI 3대 stat: energy/hydration/rest)

### Stage 1 — Backend 회귀 (재시드 + rest_score 추가 후)
| 항목 | 결과 |
|---|---|
| Jest p0+p1+codes integration spec | ✅ 24/24 PASS |
| Docker test-phase.sh p0 | ✅ 13/13 PASS |
| Docker test-phase.sh p1 | ✅ 21/21 PASS |

### Stage 2 — Flutter 실동작 (Playwright)

#### P0 시나리오 (게스트 가입 + 온보딩 완료)
| 시나리오 | 결과 | 비고 |
|---|---|---|
| splash → /onboarding/welcome | ✅ | token 없음 분기 |
| name 입력 → 다음 클릭 | ✅ | POST /auth/register 자동 호출 (게스트) → 토큰 저장 |
| goal_option 선택 → SharedPreferences에 goalId + goalType(metadata) 저장 | ✅ | hydration 매핑 확인 |
| meet-moa → 함께 시작하기 | ✅ | POST /onboarding/complete 호출 + /home 진입 |
| /home 진입 시 console errors | ✅ 0 errors | 이전 401 2건 사라짐 |
| DB users 행 검증 | ✅ | guest_..._@guest.healthmate.app, name=`P0재테스터`, isOnboardingCompleted=true |
| DB user_cycles 행 검증 | ✅ | goalType=hydration, 28/5/false, lastPeriodStartDate=어제 |

#### P1 시나리오 (홈 진입 contract 매핑)
| 시나리오 | 결과 | 비고 |
|---|---|---|
| /home 화면에서 stats/today nested 응답 → 평탄 DTO 매핑 | ✅ | energy=50, hydration=50, rest=50 (initial), level=1, streak=0 |
| rituals/today 응답 매핑 | ✅ | morningPromise=null → "오늘의 약속을 아직 정하지 않았어요", xpEarned=0 → "+0 XP" |
| `xp_earned_today` 필드명 매핑 | ✅ | Backend 응답 → Flutter `xpEarned` |
| `rest_score` 50 매핑 | ✅ | Backend 신규 컬럼 → Flutter `rest` |
| 홈 진입 시 console errors | ✅ 0 errors | |

### 수정 이력 (2026-05-08)
**Backend (3 파일 + DB)**
1. `complete-onboarding.dto.ts` — `goal_type` enum `['energy','weight','mood','fitness']` → `['energy','hydration','rest','fitness']`
2. `codes/codes.service.ts` — SEED_DATA goal_option 4건 metadata에 `goal_type` 추가 (energy/hydration/rest/fitness)
3. `entities/daily-stat.entity.ts` — `restScore` 컬럼 추가 (default 50)
4. `onboarding/onboarding.service.ts` — initial_stats에 rest_score 추가
5. `rituals/rituals.service.ts` — getOrCreateStat에 restScore=50 초기화
6. `stats/stats.service.ts` — getToday 응답 stats에 rest_score 포함
7. DB `codes` 테이블 truncate + Backend 컨테이너 재빌드 (재시드 트리거)

**Flutter DTO 정정 (4 파일)**
1. `auth_dto.dart` — `RegisterRequest.name` (display_name 폐기), `RegisterResponse {access_token only}`, `LoginResponse {access_token, is_onboarding_completed}`, `UserDto.name`
2. `user_profile_dto.dart` — `displayName` → `name` 일괄
3. `onboarding_dto.dart` — Request 6필드 (name/goalType/lastPeriodStartDate/averageCycleLength/averagePeriodLength/isIrregular), Response `{currentPhase, initialStats}`
4. `cycle_dto.dart` — CycleCurrentDto 재작성 (currentPhase/dayOfCycle/daysUntilNextPeriod/nextPeriodDate/averageCycleLength/averagePeriodLength/isIrregular/goalType), CycleSettingsRequest 정정
5. `ritual_dto.dart` — `xp_earned_today` 매핑, MorningPromiseResponse `{promise, savedAt}` 재작성, MorningMoodResponse에 `recommendedPromise`/`totalXp` 추가
6. `evening_dto.dart` — EveningRitualResponse에 `totalXp`, `level` 추가
7. `stats_dto.dart` — fromJson이 nested → flat 변환 (UI 무영향), `rest`/`xpToday`/`totalXp`/`userName` 추가

**Flutter 인프라 정정 (3 파일)**
1. `token_storage.dart` — `saveAccessToken` 단일 시그니처 (refresh_token 미발급)
2. `api_client.dart` — 401 시 refresh 시도 흐름 제거 → 토큰 클리어 + reject (재로그인 유도)
3. `auth_repository.dart` — RegisterResponse/LoginResponse 단순화
4. `auth_notifier.dart` — register/login 후 `usersRepository.getMe()`로 user 조회

**Frontend 통합 (5 파일)**
1. `assets/seed/codes.json` — goal_option metadata에 `goal_type` 추가 (offline fallback)
2. `owner_prefs_keys.dart` — `goalType` 키 추가
3. `onboarding_goal_page.dart` — 선택 시 goalId + goalType 둘 다 SharedPreferences 저장
4. `onboarding_name_page.dart` — 이름 입력 시 게스트 이메일/비밀번호 자동 생성 + `authNotifier.register()` 호출
5. `onboarding_meet_moa_page.dart` — 함께 시작하기 → `onboardingRepository.complete()` 호출 (cycle defaults: today-1, 28/5/false)
6. `splash_page.dart` — token 분기 (token 있음 + getMe 성공 + isOnboardingCompleted=true → /home, 그 외 → /onboarding/welcome)
7. `main.dart` — `initializeDateFormatting('ko_KR')` 추가 (LocaleDataException 방지)

### 미해결 / 보류
- **morning_mood/promise/evening 의식 화면 단위 직접 검증**: LocaleData 초기화 수정(main.dart)이 첫 Flutter web 빌드 시 반영되지 않은 상태로 시나리오 진입 시 LocaleDataException 노출. 수정은 이미 main.dart에 반영되었으며 Flutter web 재시작/재빌드 후 화면 단위 재검증 가능. 화면 응답은 모두 fire-and-forget이라 Backend Stage 1 PASS 21/21로 송수신 contract는 검증됨.
- **Frontend overflow**: 기존 onboarding/welcome BOTTOM OVERFLOWED 34px 이슈는 그대로 유지 (별도 세션).
- **API_SPEC.md 정정**: register 응답 정의가 backend 실제(`{access_token}`)와 다름. 사용자 결정 "Backend = 진실"에 따라 API_SPEC을 backend 실제에 맞춰 정정 필요 (별도 작업).
- **AuthGuard router redirect**: 보호 라우트 (home, morning, evening, action) 진입 시 token 없으면 onboarding/welcome로 redirect하는 가드는 미적용. 현재는 splash 분기에만 의존. ApiClient interceptor가 401시 토큰 클리어 후 재로그인 유도하는 fallback 동작.
- **refresh_token 흐름**: Backend가 refresh_token 미발급. 401 시 토큰 클리어 + 재로그인 (게스트 = 새 게스트 생성). Phase 2에서 refresh 흐름 정식 도입 검토.

---

## P0/P1 보류 항목 일괄 정리 — 2026-05-08 (sh-dev-loop --auto)

### 작업 요약
| SubTask | 내용 | 결과 |
|---|---|---|
| 1 | morning_mood overflow 수정 | ✅ SingleChildScrollView 구조 변경 |
| 2 | AuthGuard router redirect 구현 | ✅ public/protected 분기 |
| 3 | API_SPEC.md 정정 (4.1/4.2/4.3/4.4/4.5/4.7) | ✅ backend = 진실 정렬 |
| 4 | refresh_token Flutter 흐름 | 🔵 Phase 2-INFRA-AUTH 보류 (TODO 9개 명시) |
| 5 | 의식 3개 화면 Playwright 통합 검증 | ✅ 0 errors |

### 부수 fix
- `backend/src/cycle/dto/update-cycle-settings.dto.ts` goal_type enum: `[energy, weight, mood, fitness]` → `[energy, hydration, rest, fitness]` (onboarding과 정합)
- `backend/src/p1.integration.spec.ts:139,142` 회귀 테스트 데이터 'weight' → 'hydration'

### 회귀 검증
- Jest p0+p1+codes: 24/24 PASS
- test-phase.sh p0: 13/13 PASS
- test-phase.sh p1: 21/21 PASS

### Stage 2 검증 결과
시나리오: splash → /onboarding/welcome → name(의식테스터, 게스트 가입) → goal(에너지) → meet-moa(onboarding/complete) → /home(0일, +0 XP) → /morning/mood(✨좋아요) → /morning/promise(약속할게요) → /home → /evening/ritual(약속 체크 + 기쁨 + 오늘 마무리) → /home(1일 streak, +70 XP)

- AuthGuard redirect 동작 확인 (token 없음 → /onboarding/welcome)
- morning/promise/evening 의식 3개 화면 모두 클릭 + API 송수신 정상
- 360×640 viewport overflow 없음
- 콘솔 에러 0건

### 인프라 변경
- backend ALLOWED_ORIGINS에 `http://localhost:8088` 추가 (Flutter web 검증 포트)

## P0/P1 시나리오 + API 명세 적합성 검증 — 2026-05-08 (verify-feature p0 p1 --auto)

### 검증 범위
- **P0**: auth (register/login/refresh/logout) + users (me, patch) + onboarding (complete)
- **P1**: cycle (current/settings/calendar) + rituals (today/morning_mood/morning_promise/evening) + stats (today)
- **명세 대조 대상**: `docs/API_SPEC.md` 4.1~4.5, 4.7 + 섹션 3 공통 응답 형식

### Stage 1 — Backend 시나리오 + 명세 cross-check

#### 1-A. Jest 가상환경 (SQLite in-memory)
| 스펙 | 결과 | 비고 |
|---|---|---|
| `p0.integration.spec.ts` | 7/7 PASS | register/login/me/onboarding |
| `p1.integration.spec.ts` | 11/11 PASS | cycle 3 + rituals 4 + 오류 2 + stats |

#### 1-B. Docker 실환경 (PostgreSQL + curl)
| 스크립트 | 결과 | 비고 |
|---|---|---|
| `test-phase.sh p0` | 13/13 PASS | 회원가입+중복+로그인+401+200+온보딩 |
| `test-phase.sh p1` | 21/21 PASS | cycle/rituals 전 흐름 + xp 누적 +70 |

#### 1-C. API_SPEC.md 명세 적합성 cross-check (실제 응답 BODY 비교)
**HTTP Status 시나리오 16건**: register(201) / register-dup(409) / register-bademail(400) / register-shortpw(400) / login(200) / login-wrong(401) / refresh(200) / logout(200) / me-noauth(401) / me(200) / onboarding(200) / onboarding-bad-goal(400) / cycle-current(200) / cycle-calendar(200) / rituals-noauth(401) / stats-noauth(401) — 전부 명세 일치.

**응답 BODY 필드 일치**:
| 엔드포인트 | 명세 필드 | 실제 응답 | 결과 |
|---|---|---|---|
| `POST /auth/register` | `data.access_token` | 동일 | ✅ |
| `POST /auth/login` | `data.{access_token, is_onboarding_completed}` | 동일 | ✅ |
| `POST /auth/refresh` | `data.access_token` | 동일 | ✅ |
| `POST /auth/logout` | `data.message="logged out"` (HTTP 200) | 동일 | ✅ |
| `GET /users/me` | `data.{id, email, name, is_onboarding_completed, created_at}` | 동일 | ✅ |
| `POST /onboarding/complete` | `data.{initial_stats:{8필드}, current_phase}` | 동일 | ✅ |
| `GET /cycle/current` | `data.{current_phase, day_of_cycle, days_until_next_period, next_period_date, average_*, is_irregular, goal_type}` | 동일 | ✅ |
| `GET /cycle/calendar` | `data.{year, month, days[]:{date, phase, day_of_cycle}}` | 동일 (31일) | ✅ |
| `GET /rituals/today` | `data.{date, morning_mood, morning_promise, evening_completed, promise_kept, xp_earned_today}` | 동일 | ✅ |
| `POST /rituals/morning/mood` | `data.{mood, xp_earned, recommended_promise(string), total_xp}` | 동일 | ✅ |
| `POST /rituals/morning/promise` | `data.{promise, saved_at}` | 동일 | ✅ |
| `POST /rituals/evening` | `data.{promise_kept, xp_earned, total_xp, streak, level}` | 동일 (지킴=60, 미달성=10) | ✅ |
| `GET /stats/today` | `data.{user{3}, stats{8}, cycle{3}, today_ritual{5}}` | 동일 | ✅ |

**엣지 케이스 시나리오 (XP/검증 로직 회귀)**:
| 시나리오 | 기대값 | 실제값 | 결과 |
|---|---|---|---|
| morning/mood 중복 | 400 | 400 | ✅ |
| morning/mood 범위 외 (mood=0) | 400 | 400 | ✅ |
| morning/promise 200자 초과 (250자) | 400 | 400 | ✅ |
| evening 중복 | 400 | 400 | ✅ |
| cycle/settings goal_type=hydration | 200 | 200 (재빌드 후) | ✅ |
| cycle/settings goal_type=rest | 200 | 200 | ✅ |
| cycle/settings goal_type=weight (옛) | 400 | 400 + 메시지 "energy, hydration, rest, fitness" | ✅ |
| cycle/settings goal_type=mood (옛) | 400 | 400 | ✅ |
| XP 누적 (mood10 + evening10 + kept50) | 70 | 70 | ✅ |

### Stage 2 — Flutter DTO contract test (test/widget_test.dart 신규 작성)

| Group | Tests | 결과 |
|---|---|---|
| P0 Auth + Users 응답 contract | 3 | 3/3 PASS |
| P0 Onboarding 응답 contract | 1 | 1/1 PASS |
| P1 Cycle 응답 contract | 1 | 1/1 PASS |
| P1 Rituals 응답 contract | 5 | 5/5 PASS |
| P1 Stats 응답 contract (nested → flat) | 2 | 2/2 PASS |
| CyclePhase enum 매핑 | 2 | 2/2 PASS |
| **합계** | **15** | **15/15 PASS** |

> 각 케이스는 backend 실제 응답 JSON을 fixture로 사용 → fromJson 파싱 → 핵심 필드 값 일치 검증. silent failure 회귀 보호.

### Stage 2-C Playwright 실동작 — 직전 결과 회귀 cite
- 직전 `/sh-dev-loop --auto` (2026-05-08) Stage 2 시나리오: 게스트 가입 → 의식 3개 → 0 errors PASS
- 본 검증 사이클에서 backend src 변경 0건, 컨테이너 dist만 재빌드 (cycle/settings enum 동기화)
- Flutter UI에는 cycle/settings 화면 미구현 → dist 재빌드 영향 없음
- → 추가 Playwright 실행 생략 (회귀 위험 0)

### 수정 이력 (Backend = 진실 원칙 적용)
1. **Docker dist 재빌드**: src `update-cycle-settings.dto.ts` enum 변경(`weight/mood` → `hydration/rest`)이 컨테이너 dist에 미반영 상태였음. `docker compose up -d --build backend`로 동기화. 재빌드 후 enum 정상 동작 회귀 확인.
2. **`docs/API_SPEC.md` 섹션 3 공통 응답 형식 정정**: 실제 backend `ApiResponse.success`는 `{ data }`만 반환(success 키 미발급). 명세 예시 24건의 `"success": true,` 라인 일괄 제거 + 에러 응답 형식을 NestJS ValidationPipe 실제 형태(`{ message, error, statusCode }`)로 정정.
3. **`docs/API_SPEC.md` 섹션 4.4.2 cycle/settings 정정**: 옛 enum 불일치 경고 제거 + Validation 섹션을 onboarding과 동일 enum으로 명시.

### 발견된 부수 이슈 (Frontend, 기록만)
- **`InitialStats.fromJson` (onboarding_dto.dart) `rest_score` 누락**: backend가 rest_score를 응답하지만 Flutter DTO는 7필드만 매핑 (energy/hydration/mood/water_cups/total_xp/level/streak). 사용처(home_character_page)는 별도의 `StatsTodayDto`를 사용하므로 silent ignore 상태이며 UI 영향 없음. 정합성 차원에서 차후 보완 권장.
- **`UserProfileDto.fromJson` `created_at` 무시**: 의도적 (UI 미사용). 문제 없음.

### Stage 1 + Stage 2 종합 결과
```
Jest             : 18/18 PASS
test-phase.sh p0 : 13/13 PASS
test-phase.sh p1 : 21/21 PASS
명세 cross-check : 13 endpoints + 9 엣지 케이스 = 22/22 일치
Flutter contract : 15/15 PASS
─────────────────────────────────
합계             : 89/89 PASS
명세 갭          : 3건 정정 (응답 wrapper, 에러 형식, cycle/settings 경고)
부수 이슈        : 1건 기록 (InitialStats rest_score 누락 — UI 영향 없음)
```

---

## verify-feature v0.2 스킬 기반 재검증 — 2026-05-08

> 실행: `/verify-feature P0, P1 (playwright 동적검증까지)`
> 검증 엔진: `run-cases.ts` (UNIT/CONTRACT/DYNAMIC) + `run-ui-scenario.ts` (DYNAMIC UI)

### STATIC

| 대상 | 명령 | 결과 |
|---|---|---|
| Backend TypeScript | `tsc --noEmit` | ✅ 0 error |
| Flutter Dart | `dart analyze` | ✅ 0 error (56 info 허용) |

### UNIT + CONTRACT (SQLite in-memory)

| 카탈로그 | UNIT | CONTRACT | 비고 |
|---|---|---|---|
| auth_register | ✅ 4/4 | ✅ 1/1 | |
| auth_login | ✅ 3/3 | ✅ 1/1 | |
| users_me | ✅ 2/2 | ✅ 1/1 | |
| onboarding_complete | ✅ 3/3 | ✅ 1/1 | |
| cycle_current | ✅ 2/2 | ✅ 1/1 | |
| cycle_settings | ✅ 4/4 | ✅ 1/1 | |
| cycle_calendar | ✅ 2/2 | ✅ 1/1 | |
| rituals_today | ✅ 2/2 | ✅ 1/1 | |
| rituals_morning_mood | ✅ 3/3 | ✅ 1/1 | |
| rituals_morning_promise | ✅ 2/2 | ✅ 1/1 | |
| rituals_evening | ✅ 4/4 | ✅ 2/2 | |
| stats_today | ✅ 2/2 | ✅ 1/1 | |
| **합계** | **33/33** | **13/13** | |

### DYNAMIC (Docker PostgreSQL)

| 카탈로그 | DYNAMIC | 비고 |
|---|---|---|
| auth_register | ✅ 4/4 | |
| auth_login | ✅ 3/3 | |
| users_me | ✅ 2/2 | |
| onboarding_complete | ✅ 3/3 | |
| cycle_current | ✅ 2/2 | |
| cycle_settings | ✅ 4/4 | |
| cycle_calendar | ✅ 2/2 | |
| rituals_today | ✅ 2/2 | |
| rituals_morning_mood | ✅ 3/3 | |
| rituals_morning_promise | ✅ 2/2 | |
| rituals_evening | ✅ 4/4 | |
| stats_today | ✅ 2/2 | |
| **합계** | **33/33** | |

### DYNAMIC UI (Playwright — screen_evening_ritual)

| 단계 | 내용 | 결과 |
|---|---|---|
| 온보딩 흐름 | welcome → name → goal → meet-moa → /home | ✅ |
| 아침 기분 | /morning/mood → "좋아요" 선택 | ✅ |
| 아침 약속 | /morning/promise → "약속할게요" 확정 | ✅ |
| 저녁 의식 | 약속 체크박스 + 기쁨 선택 + 오늘 마무리 | ✅ |
| 네트워크 | `POST /rituals/evening → 200 OK` | ✅ |
| 콘솔 에러 | 0건 | ✅ |
| 스탯 갱신 | streak 1일, +70 XP | ✅ |

### 이번 세션 버그 수정

| 번호 | 파일 | 내용 |
|---|---|---|
| 1 | `backend/tsconfig.build.json` | `scripts` 디렉토리 빌드 제외 누락 → `dist/src/main.js` 오배치 |
| 2 | `backend/scripts/lib/dynamic-executor.ts` | `{{fresh_email}}` 치환 누락 |
| 3 | `backend/scripts/lib/dynamic-executor.ts` | `setup.user=fresh` + preconditions 중복 등록 |
| 4 | `backend/scripts/lib/dynamic-executor.ts` | `getCaseSetup()` 미사용으로 케이스 레벨 setup 무시 |
| 5 | `backend/scripts/lib/dynamic-executor.ts` | precondition 케이스가 자체 setup/preconditions 처리 안 함 (재귀 누락) |
| 6 | `backend/scripts/lib/fixture-store.ts` | `applyMask`가 `data.` 래핑 미인식 → 마스킹 미적용 |
| 7 | `backend/scripts/lib/fixture-store.ts` | CONTRACT용(원본)과 DYNAMIC 비교용(마스킹) fixture 미분리 |
| 8 | `docker-compose.yml` | CORS origins에 `localhost:8080` 누락 |
| 9 | `app/lib/shared/constants/api_constants.dart` | Web에서 `10.0.2.2:3001` 사용 → `kIsWeb` 분기로 `localhost:3001` 분리 |

### 종합 결과

```
STATIC          : BE 0 error, Flutter 0 error
UNIT            : 33/33 PASS
CONTRACT        : 13/13 PASS
DYNAMIC (curl)  : 33/33 PASS
DYNAMIC (UI)    : screen_evening_ritual 전 단계 PASS (0 console errors)
─────────────────────────────────────────────
보고서: docs/verify-results/2026-05-08_*.json (12개)
회귀:  newly_failing 0건
```

---

## Phase P2+P3 검증 — 2026-05-08/09

> 검증 방식: verify-feature v0.2 (STATIC → UNIT → CONTRACT → DYNAMIC 4-stage)
> UNIT/CONTRACT: SQLite in-memory NestJS app-factory
> DYNAMIC: Docker PostgreSQL (localhost:3001)

### 수정 사항 (검증 과정 발견)

| 항목 | 수정 내용 |
|---|---|
| `walk-session.entity.ts` | `timestamptz` → TypeORM 자동 타입(`@Column()`) 적용 (SQLite/PostgreSQL 호환) |
| `walk-session.entity.ts` | `durationMinutes` nullable 컬럼에 `type: 'int'` 명시 |
| `workout-log.entity.ts` | `durationActualMinutes` nullable 컬럼에 `type: 'int'` 명시 |
| `workout-log.entity.ts` | `skipReason` 컬럼에 `type: 'varchar'` 명시 |
| `nutrition_log_today.yaml` | `POST /nutrition/logs` status `201` → `200` 오기입 수정 + `@HttpCode(200)` 추가 |
| `actions_water.yaml` | 다중 문서 YAML → 단일 문서 분리 (`actions_water_today.yaml` 신규) |
| `actions_water.yaml`, `actions_walk.yaml` | `fixture_mask: [moa_reaction]` 추가 (랜덤 값 drift 방지) |
| `scripts/lib/app-factory.ts` | P2+P3 모듈(Actions/Rewards/Workout/Nutrition) 추가 |
| `scripts/lib/fixture-store.ts` | CACHE_DIR 경로 오류 수정 (`../../../../` → `../../../`) |
| `scripts/lib/unit-executor.ts` | `{{fixture:catalog#case.field}}` 치환 구현 |
| `scripts/lib/unit-executor.ts` | 사전조건 실행 시 fixture 저장 추가 |
| `scripts/lib/dynamic-executor.ts` | `{{fixture:...}}` 치환 + query 파라미터 처리 추가 |
| `scripts/lib/dynamic-executor.ts` | 사전조건 실행 시 fixture 저장 추가 |

### 검증 결과

```
─────────────────────────────────────────────
P2+P3 verify-feature 결과 (2026-05-09)
─────────────────────────────────────────────
카탈로그: 9개 (actions_water, actions_water_today, actions_walk,
          rewards_summary, stats_history, workout_recommend,
          workout_complete_skip, nutrition_search, nutrition_log_today)
STATIC  : BE tsc 0 error / FE dart analyze 0 error
UNIT    : ALL PASS (9/9 카탈로그, 29케이스)
CONTRACT: ALL PASS (9/9 카탈로그)
DYNAMIC : ALL PASS (9/9 카탈로그, PostgreSQL 실검증)
─────────────────────────────────────────────
보고서: docs/verify-results/2026-05-08_*.json (9개 신규)
회귀:  newly_failing 0건
```

---

## Playwright UI 시나리오 검증 — 2026-05-09

> 검증 방식: Playwright MCP (Flutter web localhost:3000 + Docker backend localhost:3001)
> 대상: screen_workout_page, screen_nutrition_page (P3 신규 화면)

### 발견 버그 및 수정

| 버그 | 원인 | 수정 |
|---|---|---|
| `workout_page` 완료·건너뛰기 후 에러 | `context.pop()` — 직접 진입 시 navigation stack 비어 GoError 발생 | `context.canPop() ? pop() : go('/home')` 으로 변경 |

### screen_workout_page 결과

```
─────────────────────────────────────────────
화면: WorkoutPage (/action/workout)
─────────────────────────────────────────────
GET  /workout/recommend  → 200 ✅
렌더링: 추천 운동 제목·강도·단계·대안 운동 버튼  ✅
POST /workout/complete   → 200, 홈 이동         ✅
POST /workout/skip       → 200, 홈 이동         ✅
콘솔 에러: 0건                                  ✅
─────────────────────────────────────────────
```

### screen_nutrition_page 결과

```
─────────────────────────────────────────────
화면: NutritionPage (/nutrition)
─────────────────────────────────────────────
GET  /nutrition/today    → 200                  ✅
렌더링: 섭취 칼로리 (0 kcal / 1800 kcal)       ✅
렌더링: 사이클 단계별 영양소 추천 메시지·Chip   ✅
렌더링: 빈 상태 '아직 기록된 식사가 없어요'     ✅
콘솔 에러: 0건                                  ✅
─────────────────────────────────────────────
```
