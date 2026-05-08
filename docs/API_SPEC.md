# Owner (오우너) Backend API 명세서

> **작성일**: 2026-05-06  
> **기준 브랜치**: feature/silver_sh (origin/main 동기화 완료)  
> **백엔드 현황**: NestJS 골격만 구현, 실제 엔드포인트 전무  
> **앱 현황**: 전체 화면 SharedPreferences 목업 상태, API 연결 없음

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

## 1. 변경된 항목 요약

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

## 2. API 미연결 화면 전체 목록

> 현재 **13개 화면 모두** API 연결 없음. 데이터 저장소 = SharedPreferences (로컬 전용).

| # | 화면 ID | 화면명 | Track | 필요한 API 모듈 | 현재 상태 |
|---|---------|--------|-------|----------------|-----------|
| 1 | `01_splash` | 스플래시 | A | Auth (토큰 검증) | SharedPrefs 플래그만 |
| 2 | `02_onboarding_welcome` | 온보딩 환영 | A | — | 순수 UI (API 불필요) |
| 3 | `03_onboarding_name` | 이름 입력 | A | Users, Onboarding | SharedPrefs 저장 |
| 4 | `04_onboarding_goal` | 목표 설정 | A | Onboarding | SharedPrefs 저장 |
| 5 | `05_onboarding_meet_moa` | 모아 만나기 | A | Onboarding, Cycle | SharedPrefs 완료 플래그만 |
| 6 | `06_morning_ritual_mood` | 아침 기분 체크 | B | Rituals, Cycle | SharedPrefs 저장 |
| 7 | `07_morning_ritual_promise` | 오늘의 약속 | B | Rituals | 하드코딩 추천 규칙 |
| 8 | `08_home_character` | 캐릭터 홈 | B | Stats, Cycle, Rewards | SharedPrefs 로드 |
| 9 | `09_action_water` | 물 마시기 | B | Actions | 로컬 setState만 |
| 10 | `10_action_walk` | 산책 | B | Actions | 스텁 타이머 |
| 11 | `11_evening_ritual` | 저녁 의식 | B | Rituals, Rewards | SharedPrefs 저장 |
| 12 | `12_evolution` | 모아 진화 | B | Rewards | 하드코딩 레벨 규칙 |
| — | `/login` (미구현) | 로그인 | A | Auth | 라우트만 존재 |

---

## 3. 공통 규칙

### Base URL
```
개발: http://localhost:3000/api
프로덕션: https://api.owner-app.io/api  (추후 결정)
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

## 3.5 P2/P3 구현 시 사전 가드 체크리스트

> P0/P1 검증(2026-05-08, `/verify-feature p0 p1 --auto`)에서 발견된 함정을 P2/P3 구현 시 사전 차단하기 위한 가드. 각 카테고리는 실제 사례 기반.

### 🐳 A. 인프라 — Docker 빌드 동기화

**함정 (P1 사례)**: `update-cycle-settings.dto.ts`의 enum 변경(`weight/mood` → `hydration/rest`)이 src에는 적용됐지만 컨테이너 dist에는 미반영. Jest는 PASS, Docker 환경에서만 silent FAIL.

**원인**: `backend/Dockerfile`은 builder stage에서 `npm run build` → `dist` 생성, runtime은 `dist/main` 실행. `docker-compose.yml`의 `./backend/src:/app/src` mount는 무의미.

**가드**:
- [ ] **Backend src 변경 후 반드시** `docker compose up -d --build backend` (단순 `restart` 금지)
- [ ] Stage 1-A (Jest, ts-jest로 src 직접) PASS 만으로 Stage 1-B (Docker dist) 스킵 금지
- [ ] CI에서 src 변경 PR은 docker rebuild 필수 step

### 📦 B. 응답 형식 — `{ data }` only

**함정**: `ApiResponse.success(data)`는 `{ data }`만 반환하며 `success: true` 키 미발급. 명세에 `{ success: true, data }`로 표기하면 Flutter DTO가 잘못 파싱하거나 명세 불일치 발생.

**가드**:
- [ ] 신규 컨트롤러 메서드는 `return ApiResponse.success(...)` 형식 강제 (raw object 반환 금지)
- [ ] 명세 응답 예시는 `{ "data": { ... } }` 만 표기 (success 키 추가 금지)
- [ ] 에러 응답은 NestJS 기본 `{ message, error, statusCode }` — 별도 ExceptionFilter 미구현 상태이므로 명세도 동일 형식 표기

### 🔠 C. DTO enum 정합성 — 분산 정의 금지

**함정 (P1 사례)**: `goal_type` enum이 onboarding(`["energy","hydration","rest","fitness"]`)과 cycle/settings(`["energy","weight","mood","fitness"]`)에 분산 정의되어 불일치. 회귀 테스트 누락 시 silent failure.

**가드**:
- [ ] 같은 도메인 enum은 **단일 위치에서 정의**하고 import 재사용 (e.g., `backend/src/cycle/enums/goal-type.enum.ts`)
- [ ] 또는 **codes 테이블 활용** (P0/P1 INFRA 패턴) — 운영자가 코드 변경 가능한 옵션은 codes로 외부화
- [ ] **P2 영향 enum**: `cup_size` (water 액션), `walk_intensity`, `badge_code`, `evolution_stage`
- [ ] **P3 영향 enum**: `meal_type` (breakfast/lunch/dinner/snack), `workout_type`, `workout_intensity`, `skip_reason`

### 🔗 C2. Flutter DTO 매핑 — 응답 필드 누락 금지

**함정 (P1 사례)**: Backend가 `rest_score`를 추가했지만 `InitialStats.fromJson`이 매핑 누락 → silent ignore. UI 영향 없으면 발견 어려움.

**가드**:
- [ ] 신규 `fromJson` 작성 시 **backend 응답 모든 필드 매핑** + nullable fallback (`as num? ?? default`)
- [ ] 신규/변경 fromJson마다 `app/test/widget_test.dart`에 **contract test 동시 추가** (backend 실제 응답 fixture로 회귀 보호)
- [ ] **P2 영향 응답**: `WaterActionResponse` (today_cups_total, hydration_stat, xp_earned, moa_reaction), `WalkCompleteResponse` (energy_stat_delta), `RewardsSummaryDto` (nested level/streak/evolution_stage/badges/xp_log)
- [ ] **P3 영향 응답**: `WorkoutRecommendDto` (recommendation + alternative + based_on), `NutritionLogResponse`

### 🗄️ D. Entity 신규 컬럼 — default 정책 명확화

**함정 (P1 사례)**: `daily_stats.rest_score` 신설 시 default=50 누락하면 기존 행에 NOT NULL 위반.

**가드**:
- [ ] 신규 컬럼은 `@Column({ default: ..., nullable: false })` 또는 `nullable: true` 중 **명시 선택** (모호 금지)
- [ ] 누적 카운터(cups, steps, total_xp 등)는 `default: 0`
- [ ] 외래 ID(walk_session_id, food_id)는 `nullable: true` + 외래 키 제약 명시
- [ ] 마이그레이션은 dev `synchronize: true`만 사용, **production은 마이그레이션 파일 작성** (CLAUDE.md 규칙)

### 📅 E. 날짜/타임존 — `localDateString()` 강제

**함정 (P1 사례)**: KST 환경에서 `new Date().toISOString().split('T')[0]`가 UTC 날짜를 반환 → `day_of_cycle` 계산 오프바이원.

**가드**:
- [ ] 모든 "오늘" 판정/저장은 `backend/src/common/utils/local-date.ts:localDateString()` 헬퍼 사용
- [ ] **P2 영향**: water/today, walk_session 시작/종료, evening_completed 일자
- [ ] **P3 영향**: workout_logs.date, meal_logs.date, nutrition/today

### 🎨 F. Flutter UX — 401/AuthGuard 일관성

**가드**:
- [ ] 신규 보호 라우트는 `app_router.dart` redirect 콜백이 자동 처리 (별도 가드 코드 불필요 — `_isPublicRoute()` 외 라우트는 자동 보호)
- [ ] 401 핸들러는 `api_client.dart` 단일 위치에서 처리 (`tokenStorage.clearTokens()`) — Phase 2-INFRA-AUTH 도입 시 refresh 흐름 추가

### ✅ G. 검증 절차 — Stage 1-A 통과만으로 종료 금지

**함정**: Jest는 ts-jest로 src 직접 실행 → src의 enum 변경이 즉시 반영. Docker는 dist 사용 → 재빌드 누락 시 silent FAIL.

**가드**:
- [ ] `/verify-feature p2 --auto` 실행 시 **Stage 1-A + Stage 1-B 둘 다 PASS 확인**
- [ ] DTO/enum 변경한 PR은 docker rebuild 후 test-phase.sh 회귀 필수
- [ ] **명세 cross-check**: 응답 BODY 필드를 backend 실제 응답과 1:1 비교 (Flutter DTO만 보고 명세 작성 금지)

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

> TypeORM Entity 설계 기준

### User
```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true }) email: string;
  @Column() password_hash: string;
  @Column() name: string;
  @Column({ type: 'enum', enum: ['energy','hydration','rest','shape'], nullable: true })
  goal_type: string;
  @Column({ default: false }) is_onboarding_completed: boolean;
  @Column({ default: 1 }) level: number;
  @Column({ default: 0 }) current_xp: number;
  @Column({ default: 0 }) streak_days: number;
  @Column({ nullable: true }) streak_last_date: Date;
  @CreateDateColumn() created_at: Date;
  @UpdateDateColumn() updated_at: Date;
}
```

### UserCycle
```typescript
@Entity('user_cycles')
export class UserCycle {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() user_id: string;
  @Column({ type: 'date' }) last_period_start_date: string;
  @Column({ default: 28 }) average_cycle_length: number;
  @Column({ default: 5 }) average_period_length: number;
  @Column({ default: false }) is_irregular: boolean;
  @UpdateDateColumn() updated_at: Date;
}
```

### DailyRitual
```typescript
@Entity('daily_rituals')
export class DailyRitual {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() user_id: string;
  @Column({ type: 'date' }) date: string;
  @Column({ nullable: true }) morning_mood: string;
  @Column({ nullable: true }) morning_promise_text: string;
  @Column({ nullable: true }) morning_promise_scheduled_time: string;
  @Column({ default: 50 }) morning_promise_reward_xp: number;
  @Column({ default: false }) morning_promise_completed: boolean;
  @Column({ nullable: true }) evening_mood: string;
  @Column({ nullable: true }) reflection: string;
  @Column({ nullable: true }) morning_completed_at: Date;
  @Column({ nullable: true }) evening_completed_at: Date;
}
```

### DailyStat
```typescript
@Entity('daily_stats')
export class DailyStat {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() user_id: string;
  @Column({ type: 'date' }) date: string;
  @Column({ default: 80 }) energy: number;
  @Column({ default: 70 }) hydration: number;
  @Column({ default: 70 }) rest: number;
  @Column({ default: 0 }) water_cups: number;
  @Column({ default: 0 }) walk_minutes: number;
}
```

### XpLog
```typescript
@Entity('xp_logs')
export class XpLog {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() user_id: string;
  @Column() delta: number;
  @Column() reason: string;
  @CreateDateColumn() created_at: Date;
}
```

### Badge
```typescript
@Entity('user_badges')
export class UserBadge {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() user_id: string;
  @Column() badge_code: string;
  @CreateDateColumn() earned_at: Date;
}
```

---

## 6. 구현 우선순위 로드맵

### P0 — Critical (앱 동작 필수)

| 모듈 | 엔드포인트 | 연결 화면 |
|------|-----------|-----------|
| Auth | POST /auth/register, /login, /refresh | 스플래시, 로그인 |
| Users | GET /users/me | 스플래시 |
| Onboarding | POST /onboarding/complete | 온보딩 5단계 |
| Cycle | GET /cycle/current | 홈, 아침 의식 |
| Rituals | POST /rituals/morning/mood, /morning/promise | 아침 의식 |
| Stats | GET /stats/today | 홈 |

### P1 — High (핵심 기능 루프)

| 모듈 | 엔드포인트 | 연결 화면 |
|------|-----------|-----------|
| Rituals | POST /rituals/evening | 저녁 의식 |
| Actions | POST /actions/water, GET /actions/water/today | 물 마시기 |
| Actions | POST /actions/walk/start, /walk/complete | 산책 |
| Rewards | GET /rewards/summary | 진화, 대시보드 |

### P2 — Medium (완성도)

| 모듈 | 엔드포인트 | 연결 화면 |
|------|-----------|-----------|
| Workout | GET /workout/recommend, POST /workout/complete | 운동 모듈 |
| Stats | GET /stats/history | 대시보드 차트 |
| Cycle | PATCH /cycle/settings, GET /cycle/calendar | 설정, 캘린더 |

### P3 — Low (MVP 이후)

| 모듈 | 엔드포인트 | 비고 |
|------|-----------|------|
| Nutrition | GET /nutrition/search, POST /nutrition/logs | 식약처 API 연동 필요 |
| Auth | POST /auth/social (Google, Apple) | Phase 2 |
| Wearable | GET /wearable/sync | Phase 2, HealthKit/Connect |

---

> **참고 문서**:
> - 사이클 OS 상세: `docs/planning/owner-femtech-mvp/02_CYCLE_OS.json`
> - 운동 콘텐츠 명세: `docs/planning/owner-femtech-mvp/03_WORKOUT_MATRIX.json`
> - KPI 측정 이벤트: `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json`
> - 화면 목업 스펙: `docs/design/owner-mock-develop/`
