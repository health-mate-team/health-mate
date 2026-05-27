# Owner (오우너) Backend API 명세서

> **작성일**: 2026-05-06  
> **최종 업데이트**: 2026-05-09 (P0~P3 구현 완료 + verify-feature 전 단계 PASS 기준)  
> **기준 브랜치**: feature/silver_sh  
> **백엔드 현황**: P0~P3 전체 구현 완료 (Auth/Users/Onboarding/Cycle/Rituals/Stats/Actions/Rewards/Workout/Nutrition)  
> **앱 현황**: 주요 화면 API 연결 완료 (Riverpod Provider + 3계층 data/domain/presentation)

---

## 목차

1. [변경된 항목 요약](#1-변경된-항목-요약)
2. [API 미연결 화면 전체 목록](#2-api-미연결-화면-전체-목록)
3. [공통 규칙](#3-공통-규칙)
4. [모듈별 API 명세](#4-모듈별-api-명세)
   - [4.1 Auth — 인증](#41-auth--인증)
   - [4.2 Users — 사용자 프로필](#42-users--사용자-프로필)
   - [4.3 Onboarding — 온보딩](#43-onboarding--온보딩)
   - [4.4 Cycle — 사이클 OS](#44-cycle--사이클-os)
   - [4.5 Rituals — 아침/저녁 의식](#45-rituals--아침저녁-의식)
   - [4.6 Actions — 데일리 액션](#46-actions--데일리-액션)
   - [4.7 Stats — 스탯 & 대시보드](#47-stats--스탯--대시보드)
   - [4.8 Rewards — XP & 레벨 & 배지](#48-rewards--xp--레벨--배지)
   - [4.9 Workout — 운동 추천](#49-workout--운동-추천)
   - [4.10 Nutrition — 식단](#410-nutrition--식단)
5. [데이터 모델 (Entity)](#5-데이터-모델-entity)
6. [구현 우선순위 로드맵](#6-구현-우선순위-로드맵)

---

## 1. 변경 이력

### P0~P3 구현 완료 (2026-05-08~09)

| Phase | 완료 내용 | 검증 |
|-------|-----------|------|
| INFRA | Codes 테이블 + CyclePhase enum + Flutter fallback | verify-feature PASS |
| P0 | Auth + Users + Onboarding, JWT, 게스트 자동가입 | verify-feature PASS |
| P1 | Cycle OS + 아침/저녁 의식 + Stats/today | verify-feature PASS |
| P2 | Actions(water/walk) + Rewards + stats/history + Flutter 연동 | verify-feature PASS |
| P3 | Workout(in-memory) + Nutrition(stub) + Flutter 연동 | verify-feature PASS |

---

### origin/main → feature/silver_sh 병합 내용 (2026-05-06)

커밋 `edec6fd` (Bumpist): `docs: relocate owner mock specs to docs/design and planning`

| 구분 | 변경 내용 |
|------|-----------|
| **목업 이동** | `app/assets/오우너목업파일/` → `docs/design/owner-mock/` |
| **개발 목업 이동** | `app/assets/오우너 목업디벨롭파일/` → `docs/design/owner-mock-develop/` |
| **신규 기획서** | `docs/planning/owner-femtech-mvp/` (7개 JSON + MD + PDF 추가) |
| **주석 경로 수정** | 9개 Dart 화면 파일의 목업 참조 경로 갱신 |
| **feat summary** | `docs/2026-04-25_feat`, `docs/2026-04-26_feat` 경로 주석 갱신 |

#### 신규 기획서 파일 (`docs/planning/owner-femtech-mvp/`)

| 파일 | 내용 |
|------|------|
| `00_OVERVIEW.md` | 펨테크 MVP 전체 개요 및 가치 제안 |
| `01_HYPOTHESES.json` | 검증 가설 4개 + 합격선 정의 |
| `02_CYCLE_OS.json` | 28일 호르몬 주기 OS — **모든 추천 로직의 SOURCE OF TRUTH** |
| `03_WORKOUT_MATRIX.json` | 4단계 × 5유형 = 20개 운동 콘텐츠 명세 |
| `04_SUCCESS_METRICS.json` | KPI 5개 + 이벤트 트래킹 명세 |
| `05_TIMELINE.json` | 8주 개발 + 4주 베타 일정 |
| `06_RISKS.json` | 리스크 목록 및 대응 전략 |
| `AGENT_GUIDE.md` | AI 에이전트 개발 가이드 |

> **핵심 영향**: `02_CYCLE_OS.json`이 백엔드 추천 엔진의 입력/출력 스키마를 정의함.  
> 이 파일을 기준으로 `cycle` 모듈 API를 설계해야 한다.

---

## 2. 화면별 API 연결 현황

> P0~P3 구현 완료 기준 (2026-05-09)

| # | 화면 ID | 화면명 | 연결 API 모듈 | 상태 |
|---|---------|--------|--------------|------|
| 1 | `01_splash` | 스플래시 | Auth (토큰 검증) → `/auth/register` 자동 게스트 가입 | ✅ API 연결 |
| 2 | `02_onboarding_welcome` | 온보딩 환영 | — | ✅ 순수 UI |
| 3 | `03_onboarding_name` | 이름 입력 | Onboarding | ✅ API 연결 |
| 4 | `04_onboarding_goal` | 목표 설정 | Onboarding | ✅ API 연결 |
| 5 | `05_onboarding_meet_moa` | 모아 만나기 | Onboarding → `POST /onboarding/complete` | ✅ API 연결 |
| 6 | `06_morning_ritual_mood` | 아침 기분 체크 | Rituals → `POST /rituals/morning/mood` | ✅ API 연결 |
| 7 | `07_morning_ritual_promise` | 오늘의 약속 | Rituals → `POST /rituals/morning/promise` | ✅ API 연결 |
| 8 | `08_home_character` | 캐릭터 홈 | Stats → `GET /stats/today`, `GET /rituals/today` | ✅ API 연결 |
| 9 | `09_action_water` | 물 마시기 | Actions → `POST /actions/water`, `GET /actions/water/today` | ✅ API 연결 |
| 10 | `10_action_walk` | 산책 | Actions → `POST /actions/walk/start`, `/walk/complete` | ✅ API 연결 |
| 11 | `11_evening_ritual` | 저녁 의식 | Rituals → `POST /rituals/evening` | ✅ API 연결 |
| 12 | `12_evolution` | 모아 진화 | Rewards → `GET /rewards/summary` | ✅ API 연결 |
| 13 | `workout_page` | 운동 | Workout → `GET /workout/recommend`, `POST /workout/complete`, `/skip` | ✅ API 연결 |
| 14 | `nutrition_page` | 식단 | Nutrition → `GET /nutrition/today`, `POST /nutrition/logs` | ✅ API 연결 |
| — | `/login` | 로그인 | Auth → `POST /auth/login` | ⚠️ 화면 미구현 (엔드포인트는 존재) |

---

## 3. 공통 규칙

### Base URL
```
로컬 개발 (Docker):  http://localhost:3001/api
협업/테스트 서버:    http://43.201.67.1:3001/api  (AWS EC2 서울)
프로덕션 (향후):     https://api.healthmate.io/api  (TBD)
```

### 인증 헤더
```
Authorization: Bearer <JWT_ACCESS_TOKEN>
```
- 인증 불필요 엔드포인트: `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `GET /codes/*`
- 나머지 모든 엔드포인트: JWT 필수
- **글로벌 prefix**: 모든 경로 앞에 `/api`가 붙는다 (예: `POST /api/auth/login`). 본 문서는 표기 간결성을 위해 `/api` 생략.

### 공통 응답 형식
```jsonc
// 성공 (backend `ApiResponse.success(data)` 래퍼)
{
  "data": { ... }
}

// 오류 (NestJS 기본 ValidationPipe / Exception 응답)
{
  "message": "구체 에러 메시지 또는 ['validation msg', ...]",
  "error": "Bad Request",
  "statusCode": 400
}
```

> backend `backend/src/common/dto/api-response.dto.ts`는 `success` 키 없이 `{ data: T }`만 반환한다. 본 문서의 모든 응답 예시도 동일하게 `{ data: ... }`만 표기한다 (이전 `success: true` 키는 미발급).

### 공통 에러 코드

| HTTP | 발생 상황 | 응답 예시 |
|------|---------|-----------|
| 400 | DTO 검증 실패 (`@IsEmail`, `@MinLength` 등) | `{ "message": ["email must be an email"], "error": "Bad Request", "statusCode": 400 }` |
| 400 | 비즈니스 룰 위반 (이미 완료된 의식 중복 등) | `{ "message": "이미 ...", "error": "Bad Request", "statusCode": 400 }` |
| 401 | JWT 토큰 없음/만료 | `{ "message": "Unauthorized", "statusCode": 401 }` |
| 404 | 리소스 없음 (cycle 미생성 등) | `{ "message": "...", "statusCode": 404 }` |
| 409 | 이메일 중복 | `{ "message": "이미 가입된 이메일입니다.", "statusCode": 409 }` |
| 500 | 서버 내부 오류 | `{ "message": "Internal server error", "statusCode": 500 }` |

---

## 3.5 구현 가드 & 검증 완료 현황

> P0~P3 전 단계 구현 및 verify-feature PASS 완료 (2026-05-09)  
> 아래 항목은 실제 구현 과정에서 발생한 함정과 적용된 해결 사례 기록.

### 🐳 A. 인프라 — Docker 빌드 동기화 ✅ 적용 완료

**함정 (P1 사례)**: enum 변경이 src에는 반영됐지만 컨테이너 dist에 미반영 → Jest PASS, Docker FAIL.

**규칙** (P2/P3 전 단계 준수):
- [x] src 변경 후 `docker compose up -d --build backend` 필수
- [x] Jest PASS만으로 완료 처리 금지 — DYNAMIC stage(Docker) 병행 검증
- [x] verify-feature `--stages unit,contract,dynamic` 3단계 통과 = 완료 기준

### 📦 B. 응답 형식 — `{ data }` only ✅ 적용 완료

- [x] 전체 컨트롤러 `return ApiResponse.success(...)` 형식 (raw object 반환 없음)
- [x] 응답 예시 `{ "data": { ... } }` 형식 통일
- [x] 에러: NestJS 기본 `{ message, error, statusCode }` (별도 ExceptionFilter 미구현)

### 🔠 C. DTO enum 정합성 — 단일 위치 정의 ✅ 적용 완료

**P2 완료**:
- [x] `badge_code`: `backend/src/rewards/enums/badge-code.enum.ts` 단일 정의
- [x] `goal_type`: `['energy','hydration','rest','fitness']` — onboarding/cycle 통일

**P3 완료**:
- [x] `meal_type`: `backend/src/nutrition/enums/meal-type.enum.ts` (`breakfast|lunch|dinner|snack`)
- [x] `workout_type`: `backend/src/workout/enums/workout-type.enum.ts` (`strength_training|cardio|yoga|stretching|light_cardio|hiit|breathing_meditation`)
- [x] `intensity`: `backend/src/workout/enums/intensity.enum.ts` (`low|moderate|high`)
- [x] `skip_reason`: `WorkoutSkipDto` `@IsIn([...])` 단일 검증

### 🔗 C2. Flutter DTO 매핑 — 응답 필드 누락 금지 ✅ 적용 완료

- [x] P2 DTO: `WaterActionResponse`, `WalkCompleteResponse`, `RewardsSummaryDto` — 전 필드 nullable fallback 포함
- [x] P3 DTO: `WorkoutRecommendDto` (`alternative: null` 허용), `NutritionLogResponse`, `NutritionTodayDto` (`focus_nutrients: const []` fallback)
- [x] 신규 fromJson마다 `app/test/widget_test.dart` contract test 추가 (P2 6건, P3 8건 — 총 29/29 PASS)

### 🗄️ D. Entity 컬럼 — default 정책 ✅ 적용 완료

**P2/P3 신규 엔티티 가드 적용 결과**:
- [x] `WalkSession.durationMinutes`: `type: 'int', nullable: true, default: null`
- [x] `WorkoutLog.durationActualMinutes`: `type: 'int', nullable: true, default: null`
- [x] `WorkoutLog.skipReason`: `type: 'varchar', nullable: true, length: 50`
- [x] `WalkSession.startedAt/endedAt`: 명시적 type 제거 → TypeORM DB별 자동 타입 (SQLite/PostgreSQL 호환)

> **SQLite↔PostgreSQL 타입 호환 주의**: `timestamptz`(Postgres 전용), `datetime`(SQLite 전용) 모두 불가. `@Column()` 타입 미지정 + TS `Date` 타입으로 TypeORM 자동 선택.

### 📅 E. 날짜/타임존 — `localDateString()` ✅ 적용 완료

- [x] `ActionsService.getOrCreateStat()`: `date ?? localDateString()`
- [x] `WorkoutService.complete/skip()`: `dto.date ?? localDateString()`
- [x] `NutritionService.logMeal/getToday()`: `localDateString()` 사용

### 🎨 F. Flutter AuthGuard ✅ 적용 완료

- [x] `app_router.dart` top-level redirect: public 라우트 외 자동 보호
- [x] 401 핸들러: `api_client.dart` 단일 위치

### ✅ G. 검증 절차 — STATIC + UNIT + CONTRACT + DYNAMIC 4단계 ✅ 완료

- [x] P2+P3 verify-feature 결과: STATIC ✅ / UNIT ✅ / CONTRACT ✅ / DYNAMIC(PostgreSQL) ✅
- [x] 카탈로그 9개 전체 ALL PASS (2026-05-09)
- [x] `app/test/widget_test.dart` 29/29 PASS (Flutter contract)

---

## 4. 모듈별 API 명세

### 4.1 Auth — 인증

#### `POST /auth/register`
회원가입 (이메일 + 비밀번호)

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "Abcd1234!",
  "name": "지민이"
}
```

**Validation** (`backend/src/auth/dto/register.dto.ts`):
- `email`: `@IsEmail()`
- `password`: `@MinLength(6)`
- `name`: `@IsString()` (필수)

**Response `201`**:
```json
{
  "data": {
    "access_token": "eyJ..."
  }
}
```

> 현재 구현은 `refresh_token`을 발급하지 않는다. 클라이언트는 access_token만 보관.

---

#### `POST /auth/login`
로그인

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "Abcd1234!"
}
```

**Response `200`**:
```json
{
  "data": {
    "access_token": "eyJ...",
    "is_onboarding_completed": true
  }
}
```

> `is_onboarding_completed: false`이면 앱이 온보딩 플로우로 리다이렉트.

---

#### `POST /auth/refresh`
액세스 토큰 갱신

**Request Body**:
```json
{
  "refresh_token": "eyJ..."
}
```

> ⚠️ 현재 backend는 별도의 refresh_token을 발급하지 않으며, 입력받은 토큰을 `JwtService.verify`로 검증한 후 새 access_token을 발급한다. 즉 클라이언트는 access_token을 그대로 refresh 입력으로 보낼 수 있다 (만료 후에는 검증 실패).

**Response `200`**:
```json
{
  "data": {
    "access_token": "eyJ..."
  }
}
```

---

#### `POST /auth/logout`
로그아웃

**Response `200`**:
```json
{
  "data": {
    "message": "logged out"
  }
}
```

> 현재 서버 측 토큰 무효화 처리는 없다. 클라이언트는 로컬 토큰을 삭제한다.

---

### 4.2 Users — 사용자 프로필

#### `GET /users/me`
내 프로필 조회 (스플래시에서 토큰 유효 시 호출, JWT 필요)

**Response `200`**:
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "지민이",
    "is_onboarding_completed": true,
    "created_at": "2026-04-01T00:00:00.000Z"
  }
}
```

> level/current_xp/streak/goal_type 등 게임화·사이클 필드는 별도 엔드포인트(`GET /stats/today`, `GET /cycle/current`)로 분리되어 있다.

---

#### `PATCH /users/me`
프로필 수정 (JWT 필요)

**Request Body** (부분 업데이트 허용):
```json
{
  "name": "수정된이름"
}
```

**Response `200`**: `GET /users/me`와 동일한 shape.

---

### 4.3 Onboarding — 온보딩

#### `POST /onboarding/complete`
온보딩 전체 완료 처리 (화면 `05_onboarding_meet_moa` 마지막에 호출, JWT 필요)

**Request Body**:
```json
{
  "name": "지민이",
  "goal_type": "energy",
  "last_period_start_date": "2026-04-28",
  "average_cycle_length": 28,
  "average_period_length": 5,
  "is_irregular": false
}
```

**Validation** (`backend/src/onboarding/dto/complete-onboarding.dto.ts`):
- `goal_type`: `"energy" | "hydration" | "rest" | "fitness"`
- `last_period_start_date`: ISO 8601 날짜 문자열
- `average_cycle_length`: 21~45 정수
- `average_period_length`: 1~10 정수
- `is_irregular`: boolean

**Response `200`**:
```json
{
  "data": {
    "initial_stats": {
      "energy_score": 50,
      "hydration_score": 50,
      "mood_score": 50,
      "rest_score": 50,
      "water_cups": 0,
      "total_xp": 0,
      "level": 1,
      "streak": 0
    },
    "current_phase": "follicular"
  }
}
```

> **서버 사이드 이펙트**:
> - `is_onboarding_completed = true` 설정
> - `user_cycles` 행 생성 (last_period_start_date / average_*/is_irregular / goal_type)
> - `daily_stats` 행 초기화 (모든 score=50, xp/level/streak/water_cups=0)
> - 현재 day_of_cycle을 기반으로 `current_phase` 계산하여 응답에만 포함 (DB에는 미저장)

---

### 4.4 Cycle — 사이클 OS

> **SOURCE OF TRUTH**: `docs/planning/owner-femtech-mvp/02_CYCLE_OS.json`

#### `GET /cycle/current`
오늘의 사이클 상태 조회 (홈 화면, 아침 의식에서 호출)

**Response `200`**:
```json
{
  "data": {
    "current_phase": "follicular",
    "day_of_cycle": 8,
    "days_until_next_period": 20,
    "next_period_date": "2026-05-26",
    "average_cycle_length": 28,
    "average_period_length": 5,
    "is_irregular": false,
    "goal_type": "energy"
  }
}
```

> 사이클 데이터가 없으면 `404` `NOT_FOUND` 반환. 표현용 라벨/이모지/색상 토큰은 클라이언트가 `current_phase` 값으로 매핑한다.

---

#### `PATCH /cycle/settings`
사이클 정보 수정 (설정 화면에서 호출). 모든 필드 optional.

**Request Body**:
```json
{
  "last_period_start_date": "2026-05-01",
  "average_cycle_length": 28,
  "average_period_length": 5,
  "is_irregular": false,
  "goal_type": "energy"
}
```

**Validation** (`backend/src/cycle/dto/update-cycle-settings.dto.ts`):
- `goal_type`: `"energy" | "hydration" | "rest" | "fitness"` (onboarding과 동일)
- `last_period_start_date`: ISO 8601 날짜 문자열
- `average_cycle_length`: 21~45 정수
- `average_period_length`: 1~10 정수
- `is_irregular`: boolean

**Response `200`**: `GET /cycle/current`와 동일한 shape (변경된 필드 반영).

---

#### `GET /cycle/calendar?year=2026&month=05`
월별 사이클 캘린더 데이터. query 누락 시 현재 연/월.

**Response `200`**:
```json
{
  "data": {
    "year": 2026,
    "month": 5,
    "days": [
      {
        "date": "2026-05-01",
        "phase": "menstrual",
        "day_of_cycle": 3
      }
    ]
  }
}
```

---

### 4.5 Rituals — 아침/저녁 의식

#### `GET /rituals/today`
오늘의 의식 상태 조회 (홈 화면 "오늘의 약속" 카드)

**Response `200`**:
```json
{
  "data": {
    "date": "2026-05-06",
    "morning_mood": 3,
    "morning_promise": "10분 산책하기",
    "evening_completed": false,
    "promise_kept": false,
    "xp_earned_today": 10
  }
}
```

> 데이터 없는 날은 `morning_mood: null`, `morning_promise: null`, `evening_completed: false`, `promise_kept: false`, `xp_earned_today: 0` 반환. flat 구조 (nested morning/evening 객체 아님).

---

#### `POST /rituals/morning/mood`
아침 기분 기록 (화면 `06_morning_ritual_mood`)

**Request Body**:
```json
{
  "mood": 3
}
```

**Validation**:
- `mood`: 정수 1~5 (`codes.numeric_value`. great=5, okay=3, tired=2, exhausted=1)

**Response `200`**:
```json
{
  "data": {
    "mood": 3,
    "xp_earned": 10,
    "recommended_promise": "오늘은 10분 가볍게 산책해볼까요?",
    "total_xp": 10
  }
}
```

> 이미 같은 날 mood가 기록된 경우 `400 BAD_REQUEST`. `recommended_promise`는 단일 문자열(객체 아님). 서버는 +10 XP 지급.

---

#### `POST /rituals/morning/promise`
오늘의 약속 확정 (화면 `07_morning_ritual_promise`)

**Request Body**:
```json
{
  "promise": "10분 산책하기"
}
```

**Validation**:
- `promise`: 문자열, `MaxLength(200)`

**Response `200`**:
```json
{
  "data": {
    "promise": "10분 산책하기",
    "saved_at": "2026-05-06T07:15:00.000Z"
  }
}
```

---

#### `POST /rituals/evening`
저녁 의식 기록 (화면 `11_evening_ritual`)

**Request Body**:
```json
{
  "promise_kept": true
}
```

**Response `200`**:
```json
{
  "data": {
    "promise_kept": true,
    "xp_earned": 60,
    "total_xp": 80,
    "streak": 4,
    "level": 1
  }
}
```

> `xp_earned`: 약속 지킴 시 60 (base 10 + bonus 50), 미달성 시 10. 이미 완료된 날은 `400 BAD_REQUEST`. level_up 트랜지션은 클라이언트가 `total_xp`/`level` 변화로 자체 판단.

---

### 4.6 Actions — 데일리 액션

> **P2 구현 가드** (섹션 3.5 참조):
> - `cups_added` 검증: `@IsInt() @Min(1) @Max(20)` (1잔 ~ 20잔 범위 강제)
> - `started_at`/`ended_at` 비교 시 `localDateString()` 헬퍼로 같은 날 판정
> - `walk_session_id`는 외래 키 `nullable: true` + complete 호출 시 검증
> - 응답의 `today_cups_total`/`daily_target_cups`/`hydration_stat`/`xp_earned`/`moa_reaction` 5필드 모두 Flutter DTO에 매핑 (silent ignore 금지)
> - `daily_target_cups`는 user 설정 값 (default 8) — Entity `users` 또는 `daily_stats`에 컬럼 신설 시 `default: 8`

#### `POST /actions/water`
물 마시기 기록 (화면 `09_action_water`)

**Request Body**:
```json
{
  "date": "2026-05-06",
  "cups_added": 1
}
```

**Response `200`**:
```json
{
  "data": {
    "today_cups_total": 4,
    "daily_target_cups": 8,
    "hydration_stat": 62,
    "xp_earned": 5,
    "moa_reaction": "물 마셨군요! 수분이 채워지고 있어요 💧"
  }
}
```

---

#### `GET /actions/water/today`
오늘 물 섭취량 조회 (화면 진입 시 현재값 복원)

**Response `200`**:
```json
{
  "data": {
    "date": "2026-05-06",
    "cups_total": 3,
    "daily_target_cups": 8
  }
}
```

---

#### `POST /actions/walk/start`
산책 시작 (화면 `10_action_walk` 진입)

**Request Body**:
```json
{
  "started_at": "2026-05-06T18:30:00Z"
}
```

**Response `201`**:
```json
{
  "data": {
    "walk_session_id": "uuid",
    "started_at": "2026-05-06T18:30:00Z"
  }
}
```

---

#### `POST /actions/walk/complete`
산책 완료 기록

**Request Body**:
```json
{
  "walk_session_id": "uuid",
  "ended_at": "2026-05-06T18:45:00Z",
  "duration_minutes": 15,
  "steps_count": 1800,
  "distance_km": 1.26
}
```

**Response `200`**:
```json
{
  "data": {
    "duration_minutes": 15,
    "distance_km": 1.26,
    "energy_stat_delta": 8,
    "xp_earned": 30,
    "moa_reaction": "15분 걸었어요! 모아가 기뻐해요 🐾"
  }
}
```

---

### 4.7 Stats — 스탯 & 대시보드

#### `GET /stats/today`
홈 화면 전체 데이터 단일 쿼리 (화면 `08_home_character`)

**Response `200`**:
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "name": "지민이",
      "email": "user@example.com"
    },
    "stats": {
      "energy_score": 75,
      "hydration_score": 62,
      "mood_score": 70,
      "rest_score": 80,
      "water_cups": 4,
      "total_xp": 240,
      "level": 3,
      "streak": 7
    },
    "cycle": {
      "current_phase": "follicular",
      "day_of_cycle": 8,
      "goal_type": "energy"
    },
    "today_ritual": {
      "morning_mood": 3,
      "morning_promise": "10분 산책하기",
      "evening_completed": false,
      "promise_kept": false,
      "xp_earned_today": 10
    }
  }
}
```

> - `stats`, `cycle`, `today_ritual` 세 필드는 데이터 없을 시 **null**. `user`는 항상 존재.
> - 모아 표정/메시지 등 표현 결정은 클라이언트가 stat/phase 값으로 매핑한다 (서버 결정 안 함).
> - Flutter `StatsTodayDto.fromJson`이 이 nested 응답을 평탄 구조로 변환.

---

#### `GET /stats/history?days=30`
최근 N일 스탯 히스토리 (대시보드 차트용)

**Response `200`**:
```json
{
  "data": {
    "period_days": 30,
    "daily_records": [
      {
        "date": "2026-05-06",
        "energy": 75,
        "hydration": 62,
        "rest": 80,
        "morning_completed": true,
        "evening_completed": false,
        "phase": "follicular"
      }
    ]
  }
}
```

---

### 4.8 Rewards — XP & 레벨 & 배지

> **P2 구현 가드** (섹션 3.5 참조):
> - 응답이 nested 구조 (`streak{}`, `evolution_stage{}`, `badges[]`, `xp_log[]`) — Flutter `RewardsSummaryDto.fromJson`은 평탄 변환 vs 그대로 사용 사전 결정 (P1 stats/today와 동일 패턴 권장 = 그대로 nested 보존 + UI에서 접근)
> - `badges[].code` (string)는 enum 분산 금지 — `backend/src/rewards/enums/badge-code.enum.ts` 단일 정의 또는 codes 테이블 활용
> - `evolution_stage.color_token`은 클라이언트 토큰 문자열 매핑이지만, 서버에서 결정하지 말고 **stage 번호만 반환 + Flutter가 매핑** 권장 (UI 결정은 클라이언트 — P1 stats/today 패턴 일관성)
> - `xp_log[].reason` enum: `morning_mood, evening_completed, promise_completed, water_added, walk_completed, workout_completed, meal_logged` — 단일 enum 강제
> - 레벨업 판정 로직(`level_up: { from, to, evolution_stage_changed }` 등) 신설 시 P2-INFRA로 분리 검토 (advisor 호출 권장)

#### `GET /rewards/summary`
레벨·XP·배지 요약 (화면 `12_evolution` 및 대시보드)

**Response `200`**:
```json
{
  "data": {
    "level": 3,
    "current_xp": 240,
    "xp_to_next_level": 60,
    "total_xp_earned": 340,
    "streak": {
      "current": 7,
      "longest": 12
    },
    "evolution_stage": {
      "stage": 2,
      "name": "새싹 모아",
      "color_token": "OwnerColors.accentMint",
      "next_stage_xp_threshold": 500,
      "xp_to_next": 260
    },
    "badges": [
      {
        "code": "first_ritual",
        "name": "첫 의식 완료",
        "description": "처음으로 아침 의식을 완료했어요",
        "earned_at": "2026-04-30T07:20:00Z"
      }
    ],
    "xp_log": [
      {
        "delta": 50,
        "reason": "promise_completed",
        "label": "오늘의 약속 달성",
        "created_at": "2026-05-05T20:30:00Z"
      }
    ]
  }
}
```

#### XP 지급 기준표

| 행동 | XP |
|------|----|
| 아침 의식 완료 | +10 |
| 저녁 의식 완료 | +10 |
| 오늘의 약속 달성 | +50 |
| 물 마시기 1잔 | +5 |
| 산책 완료 | +30 |
| 운동 완료 | +30 |
| 식사 기록 | +10 |

#### 레벨 임계값

| 레벨 | 누적 XP | 진화 단계 |
|------|---------|-----------|
| 1 | 0 | 🐣 새싹 모아 |
| 5 | 300 | 🧡 성장 모아 |
| 10 | 700 | ✨ 개화 모아 |
| 20 | 1500 | 💫 빛남 모아 |
| 30 | 3000 | 👑 마스터 모아 |

---

### 4.9 Workout — 운동 추천

> 콘텐츠 기준: `docs/planning/owner-femtech-mvp/03_WORKOUT_MATRIX.json`

> **P3 구현 가드** (섹션 3.5 참조):
> - **enum 단일 정의**: `workout_type` (`strength_training | cardio | yoga | stretching | light_cardio`), `intensity` (`low | moderate | high`), `phase_fit` (`menstrual | follicular | ovulation | luteal` — `CyclePhase` enum 재사용)
> - `recommendation` (필수) + `alternative` (nullable) — Flutter DTO `fromJson`에서 alternative null 처리 누락 주의
> - `based_on{phase, mood, goal}`: mood는 string vs int? — P1 mood는 `int 1~5` (codes.numeric_value)였으므로 P3도 일관성 위해 **`int`** 사용 또는 매핑 변환 명시 (silent failure 위험)
> - `video_url: null` + `is_video_ready: false` + `fallback_type: "svg_animation"` — Flutter는 fallback_type 매핑 누락 시 영상 없는 영역에 placeholder 깨짐 (rest_score 사례 재발 위험)
> - `workout_logs` Entity: `completion_rate`는 `decimal(3,2)` (0.00~1.00), default 1.0
> - `skip_reason` 자유 string 허용 시 `MaxLength(50)` 강제 (XSS/저장 폭증 방지)

#### `GET /workout/recommend`
오늘의 운동 추천 (사이클 + 기분 + 목표 기반)

**Query Params**: `date=2026-05-06` (기본값: 오늘)

**Response `200`**:
```json
{
  "data": {
    "recommendation": {
      "workout_id": "follicular_strength_01",
      "title": "활력 근력 루틴",
      "type": "strength_training",
      "intensity": "moderate",
      "duration_minutes": 20,
      "phase_fit": "follicular",
      "thumbnail_url": "https://cdn.owner-app.io/workouts/follicular_strength_01.jpg",
      "video_url": null,
      "is_video_ready": false,
      "fallback_type": "svg_animation"
    },
    "based_on": {
      "phase": "follicular",
      "mood": "okay",
      "goal": "energy"
    },
    "alternative": {
      "workout_id": "follicular_cardio_01",
      "title": "경쾌한 가벼운 걷기",
      "type": "light_cardio"
    }
  }
}
```

---

#### `POST /workout/complete`
운동 완료 기록

**Request Body**:
```json
{
  "workout_id": "follicular_strength_01",
  "date": "2026-05-06",
  "duration_actual_minutes": 18,
  "completion_rate": 0.9
}
```

**Response `200`**:
```json
{
  "data": {
    "xp_earned": 30,
    "energy_stat_delta": 10,
    "streak_updated": { "current_streak": 8 },
    "level_up": null
  }
}
```

---

#### `POST /workout/skip`
운동 건너뜀 기록

**Request Body**:
```json
{
  "workout_id": "follicular_strength_01",
  "date": "2026-05-06",
  "skip_reason": "tired"
}
```

**Response `200`**:
```json
{
  "data": {
    "skipped": true,
    "workout_id": "follicular_strength_01"
  }
}
```

---

### 4.10 Nutrition — 식단

> **P3 구현 가드** (섹션 3.5 참조):
> - **enum 단일 정의**: `meal_type` (`breakfast | lunch | dinner | snack`) — `backend/src/nutrition/enums/meal-type.enum.ts` 단일 위치
> - `meal_logs.date` 저장 시 `localDateString()` 헬퍼 강제 (P1 KST 사례 재발 방지)
> - `total_calories`/`total_protein_g`/... 누적 필드는 service 계산 후 응답에 포함 — Flutter가 별도 계산 금지 (silent drift 위험)
> - **외부 API 캐시 (식약처)**: Phase 2-INFRA-CACHE 트리거 조건(메모리 참조) 충족 시점에만 Redis TTL 도입 — 초기 구현은 in-memory cache로 충분
> - `food_id` 외부 ID는 `string` (식약처 형식 e.g., `mfds_001234`) — UUID 변환 금지
> - `nutrition_recommendation.phase`/`focus_nutrients[]`/`message` 응답 필드 모두 Flutter DTO에 매핑 + null fallback (`focus_nutrients: const []`)

#### `GET /nutrition/search?q=닭가슴살&limit=10`
음식 검색 (식약처 API 캐시 레이어)

**Response `200`**:
```json
{
  "data": {
    "query": "닭가슴살",
    "results": [
      {
        "food_id": "mfds_001234",
        "name": "닭가슴살 (삶은 것)",
        "calories_per_100g": 109,
        "protein_g": 23.1,
        "carbs_g": 0,
        "fat_g": 1.2,
        "source": "식약처"
      }
    ]
  }
}
```

---

#### `POST /nutrition/logs`
식사 기록

**Request Body**:
```json
{
  "date": "2026-05-06",
  "meal_type": "lunch",
  "foods": [
    {
      "food_id": "mfds_001234",
      "amount_g": 150
    }
  ]
}
```

**Validation**: `meal_type`: `"breakfast" | "lunch" | "dinner" | "snack"`

**Response `201`**:
```json
{
  "data": {
    "meal_log_id": "uuid",
    "total_calories": 164,
    "xp_earned": 10
  }
}
```

---

#### `GET /nutrition/today`
오늘 식사 요약

**Response `200`**:
```json
{
  "data": {
    "date": "2026-05-06",
    "total_calories": 1240,
    "daily_target_calories": 1800,
    "phase_recommendation": {
      "phase": "follicular",
      "focus_nutrients": ["단백질", "복합 탄수화물"],
      "message": "난포기에는 단백질 섭취를 늘려 근육 회복을 도와요"
    },
    "meals": [
      {
        "meal_type": "lunch",
        "calories": 520,
        "foods_count": 3
      }
    ]
  }
}
```

---

## 5. 데이터 모델 (Entity)

> 실제 구현 코드(`backend/src/entities/`) 기준. TypeORM 필드명은 camelCase, DB 컬럼명은 자동 snake_case 변환.  
> 마지막 동기화: 2026-05-09 (P0~P3 전체 구현 완료 후)

### ⚠️ 응답 필드명 매핑 주의

XpLog는 Entity 컬럼명(`amount`, `source`)과 API 응답 필드명(`delta`, `reason`)이 다릅니다.  
서비스 레이어에서 변환: `amount → delta`, `source → reason` (Entity 수정 없이 응답 레이어에서 처리).

---

### User
```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true }) email: string;
  @Column() password: string;                    // bcrypt 해시 저장
  @Column() name: string;
  @Column({ default: false }) isOnboardingCompleted: boolean;
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
  @OneToOne(() => UserCycle, (cycle) => cycle.user, { cascade: true, eager: false })
  cycle: UserCycle;
}
```

> `goal_type`, `level`, `current_xp`, `streak_days`는 User Entity에 없음. 각각 `UserCycle.goalType`, `DailyStat.level`, `DailyStat.totalXp`, `DailyStat.streak`에서 집계.

---

### UserCycle
```typescript
@Entity('user_cycles')
export class UserCycle {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'date' }) lastPeriodStartDate: string;   // 'YYYY-MM-DD'
  @Column({ default: 28 }) averageCycleLength: number;
  @Column({ default: 5 }) averagePeriodLength: number;
  @Column({ default: false }) isIrregular: boolean;
  @Column({ default: 'energy' }) goalType: string;          // 'energy'|'hydration'|'rest'|'fitness'
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
}
```

---

### DailyRitual
```typescript
@Entity('daily_rituals')
export class DailyRitual {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'date' }) date: string;                          // 'YYYY-MM-DD'
  @Column({ type: 'integer', nullable: true, default: null }) morningMood: number;   // 1~5
  @Column({ type: 'text', nullable: true, default: null }) morningMoodAt: string;
  @Column({ type: 'text', nullable: true, default: null }) morningPromise: string;
  @Column({ type: 'text', nullable: true, default: null }) morningPromiseAt: string;
  @Column({ default: false }) eveningCompleted: boolean;
  @Column({ type: 'text', nullable: true, default: null }) eveningCompletedAt: string;
  @Column({ default: false }) promiseKept: boolean;
  @Column({ default: 0 }) xpEarned: number;
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
}
```

---

### DailyStat
```typescript
@Entity('daily_stats')
export class DailyStat {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'date' }) date: string;
  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 }) energyScore: number;
  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 }) hydrationScore: number;
  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 }) moodScore: number;
  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 }) restScore: number;
  @Column({ default: 0 }) waterCups: number;
  @Column({ default: 0 }) totalXp: number;
  @Column({ default: 1 }) level: number;
  @Column({ default: 0 }) streak: number;
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
}
```

---

### XpLog
```typescript
@Entity('xp_logs')
export class XpLog {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'date' }) date: string;
  @Column() amount: number;                           // API 응답에서는 'delta'로 변환
  @Column() source: string;                          // API 응답에서는 'reason'으로 변환
  @Column({ nullable: true, type: 'text' }) description: string | null;
  @CreateDateColumn() createdAt: Date;
}
```

> `source` 유효값: `morning_mood | morning_promise | evening | promise_kept | water_added | walk_completed | workout_completed | meal_logged`

---

### UserBadge
```typescript
@Entity('user_badges')
export class UserBadge {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column() badgeCode: string;   // BadgeCode enum: first_ritual|7day_streak|30day_streak|water_goal|walk_complete
  @CreateDateColumn() earnedAt: Date;
}
```

---

### WalkSession (P2 신규)
```typescript
@Entity('walk_sessions')
export class WalkSession {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column() startedAt: Date;                                        // TypeORM 자동 타입 (DB별 호환)
  @Column({ nullable: true, default: null }) endedAt: Date;        // complete 호출 시 설정
  @Column({ type: 'int', nullable: true, default: null }) durationMinutes: number | null;
  @Column({ default: 0 }) stepsCount: number;
  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 }) distanceKm: number;
  @CreateDateColumn() createdAt: Date;
}
```

---

### WorkoutLog (P3 신규)
```typescript
@Entity('workout_logs')
export class WorkoutLog {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column() workoutId: string;                // e.g. 'follicular_strength_01'
  @Column({ type: 'date' }) date: string;
  @Column() workoutType: string;             // WorkoutType enum 값
  @Column({ type: 'int', nullable: true, default: null }) durationActualMinutes: number | null;
  @Column({ type: 'decimal', precision: 3, scale: 2, default: 1.0 }) completionRate: number;
  @Column({ default: false }) isSkipped: boolean;
  @Column({ type: 'varchar', nullable: true, length: 50, default: null }) skipReason: string | null;
  @CreateDateColumn() createdAt: Date;
}
```

---

### MealLog (P3 신규)
```typescript
@Entity('meal_logs')
export class MealLog {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'date' }) date: string;
  @Column() mealType: string;   // MealType enum: breakfast|lunch|dinner|snack
  @Column({ default: 0 }) totalCalories: number;
  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 }) totalProteinG: number;
  @CreateDateColumn() createdAt: Date;
}
```

---

### MealLogItem (P3 신규)
```typescript
@Entity('meal_log_items')
export class MealLogItem {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() mealLogId: string;           // MealLog.id 참조
  @Column() foodId: string;              // 식약처 형식 e.g. 'mfds_001234'
  @Column() foodName: string;
  @Column() amountG: number;             // 섭취량 (g)
  @Column({ default: 0 }) calories: number;
  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 }) proteinG: number;
}
```

---

## 6. 구현 현황 로드맵

> 2026-05-09 기준 — verify-feature UNIT + CONTRACT + DYNAMIC 전 단계 PASS 완료

### ✅ INFRA — 공통 인프라

| 모듈 | 엔드포인트 | 상태 |
|------|-----------|------|
| Codes | GET /codes/:groupId, GET /codes?groups= | ✅ 완료 |

### ✅ P0 — Auth + Users + Onboarding

| 모듈 | 엔드포인트 | 상태 |
|------|-----------|------|
| Auth | POST /auth/register | ✅ 완료 |
| Auth | POST /auth/login | ✅ 완료 |
| Auth | POST /auth/refresh | ✅ 완료 (stub — access_token 재발급만, refresh_token 미도입) |
| Auth | POST /auth/logout | ✅ 완료 |
| Users | GET /users/me | ✅ 완료 |
| Users | PATCH /users/me | ✅ 완료 |
| Onboarding | POST /onboarding/complete | ✅ 완료 |

### ✅ P1 — Cycle + Rituals + Stats

| 모듈 | 엔드포인트 | 상태 |
|------|-----------|------|
| Cycle | GET /cycle/current | ✅ 완료 |
| Cycle | PATCH /cycle/settings | ✅ 완료 |
| Cycle | GET /cycle/calendar | ✅ 완료 |
| Rituals | GET /rituals/today | ✅ 완료 |
| Rituals | POST /rituals/morning/mood | ✅ 완료 |
| Rituals | POST /rituals/morning/promise | ✅ 완료 |
| Rituals | POST /rituals/evening | ✅ 완료 |
| Stats | GET /stats/today | ✅ 완료 |

### ✅ P2 — Actions + Rewards + Stats history

| 모듈 | 엔드포인트 | 상태 |
|------|-----------|------|
| Actions | POST /actions/water | ✅ 완료 |
| Actions | GET /actions/water/today | ✅ 완료 |
| Actions | POST /actions/walk/start | ✅ 완료 |
| Actions | POST /actions/walk/complete | ✅ 완료 |
| Rewards | GET /rewards/summary | ✅ 완료 |
| Stats | GET /stats/history | ✅ 완료 |

### ✅ P3 — Workout + Nutrition

| 모듈 | 엔드포인트 | 상태 |
|------|-----------|------|
| Workout | GET /workout/recommend | ✅ 완료 (in-memory WORKOUT_CATALOG) |
| Workout | POST /workout/complete | ✅ 완료 |
| Workout | POST /workout/skip | ✅ 완료 |
| Nutrition | GET /nutrition/search | ✅ 완료 (in-memory stub 10개 식품) |
| Nutrition | POST /nutrition/logs | ✅ 완료 |
| Nutrition | GET /nutrition/today | ✅ 완료 |

### 🔵 보류 / 미구현

| 항목 | 상태 | 진입 조건 |
|------|------|-----------|
| INFRA-AUTH: Refresh Token 정식 흐름 | 🔵 보류 | Phase 2 운영 단계 진입 후 |
| INFRA-CACHE: Redis TTL + ETag | 🔵 보류 | GET /codes p99 > 100ms OR 일 5K req+ |
| 식약처 실 API 연동 | 🔵 별도 TODO | data.go.kr API key 발급 후 |
| Auth: POST /auth/social | 🔵 미구현 | Phase 2 소셜 로그인 |
| Wearable: GET /wearable/sync | 🔵 미구현 | Phase 2, HealthKit/Connect |

---

> **참고 문서**:
> - 사이클 OS 상세: `docs/planning/owner-femtech-mvp/02_CYCLE_OS.json`
> - 운동 콘텐츠 명세: `docs/planning/owner-femtech-mvp/03_WORKOUT_MATRIX.json`
> - KPI 측정 이벤트: `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json`
> - 화면 목업 스펙: `docs/design/owner-mock-develop/`
