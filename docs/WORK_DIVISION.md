# 메뉴별 업무 분장 — Health Mate (2인 개발)

> **목적**: 2인 동시 개발 시 코드 충돌을 최소화하기 위해 **메뉴(=화면/도메인) 단위**로 책임 영역을 분리한다.
> 각 메뉴는 *앱 화면 + 백엔드 모듈 + DB 테이블*을 한 묶음으로 한 명이 끝까지 책임진다.
>
> - 작성일: 2026-04-25
> - 대상 Phase: 1 (MVP) 중심, Phase 2/3 메뉴는 보류 표시
> - 변경 시: 양쪽 합의 후 본 문서를 PR로 갱신 (자세한 절차는 §21)
>
> **트랙 색상 표기**
> - 🟦 **A** : Track A
> - 🟩 **B** : Track B
> - 🟧 **공동** : 양쪽 합의 후 작업

---

## 0. 분배 원칙

1. **수직 슬라이스 소유**: 한 메뉴 = 한 명이 앱·백엔드·DB·테스트까지 책임
2. **디렉토리 격리**: `app/lib/features/{name}/`, `backend/src/{module}/`은 소유자만 수정
3. **공유 영역은 합의 룰 적용** (§17 참조)
4. **의존성 역전**: 메뉴끼리는 인터페이스(추상 클래스/DTO)로만 통신, 구현 직접 import 금지
5. **작업량(`XS/S/M/L`) 균형**을 맞춰 배분, Phase 2/3는 우선순위에서 제외

---

## 1. 한눈에 보기

| # | 메뉴 ID | 화면 | 핵심 기능 | Phase | 작업량 | 권장 담당 |
|---|---|---|---|---|---|---|
| 1 | `splash` | 스플래시 | 라우팅 분기 (온보딩 미완 vs 홈) | 1 | XS | 🟦 **A** |
| 2 | `auth` | 로그인·회원가입 | 이메일·소셜 로그인, JWT | 1 | M | 🟦 **A** |
| 3 | `onboarding` | 온보딩 | 이름·목표·모아 만남 | 1 | M | 🟦 **A** |
| 4 | `body_record` | 신체 기록 | 키·체중·체지방·Before/After 사진 | 1 | M | 🟦 **A** |
| 5 | `subscription` | 구독 결제 | RevenueCat entitlement | 1 | M | 🟦 **A** |
| 6 | `home` | 메인 홈 | 캐릭터·약속 카드·스탯 게이지 | 1 | M | 🟩 **B** |
| 7 | `dashboard` | 대시보드 | 스트릭·XP·배지·레벨 | 1 | L | 🟩 **B** |
| 8 | `morning_ritual` | 아침 의식 | 무드 입력·오늘의 약속 | 1 | S | 🟩 **B** |
| 9 | `action` | 데일리 액션 | 물·산책 액션 카운트 | 1 | S | 🟩 **B** |
| 10 | `evening_ritual` | 저녁 의식 | 회고·완료 체크 | 1 | S | 🟩 **B** |
| 11 | `evolution` | 진화 | 캐릭터 단계 풀스크린 전환 | 1 | S | 🟩 **B** |
| 12 | `workout` | 운동 | MET 추천·이행 체크 | 1 | L | 🟦 **A** |
| 13 | `nutrition` | 식단 | 식약처 API·칼로리 가이드 | 1 | L | 🟩 **B** |
| 14 | `wearable` | 웨어러블 | HealthKit·Health Connect | 2 | M | 🟧 **공동** |

**합계** — 🟦 A: 6개 메뉴 (XS+M+M+M+M+L ≈ 5.5L), 🟩 B: 7개 메뉴 (M+L+S+S+S+S+L ≈ 5.5L)
※ 🟧 `wearable`은 Phase 2 시작 시 별도 분장.

---

## 2. 🟦 **A** · `splash`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 스플래시 |
| **앱 화면** | `app/lib/features/splash/presentation/splash_page.dart` |
| **백엔드 모듈** | — (앱 단독) |
| **DB 테이블** | — |
| **핵심 기능** | 1) 마스코트 2초 노출 2) `owner_onboarding_done` SharedPreferences 조회 3) `/onboarding` 또는 `/home`으로 분기 |
| **선행 의존** | `auth` (토큰 존재 여부 판정), `onboarding` (완료 플래그) |
| **후행 의존** | 모든 메뉴 (앱 진입점) |
| **결정 사항** | 토큰 만료 시 → 로그인 화면, 토큰 유효 + 온보딩 미완 시 → 온보딩 |
| **검증** | `flutter analyze`, 콜드 스타트 진입 동선 수동 |

---

## 3. 🟦 **A** · `auth`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 로그인 / 회원가입 |
| **앱 화면** | `app/lib/features/auth/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/auth/` |
| **DB 테이블** | `users` (id, email, password_hash, social_provider, social_id, created_at) |
| **핵심 기능** | 1) 이메일 회원가입·로그인 2) Apple·Google·Kakao 소셜 로그인 3) JWT 발급·갱신 4) 비밀번호 재설정 |
| **API 엔드포인트** | `POST /auth/signup`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/social/{provider}`, `POST /auth/password-reset` |
| **선행 의존** | — |
| **후행 의존** | 모든 인증 필요 메뉴 (`AuthGuard` 제공) |
| **공통 인프라 산출물** | `JwtAuthGuard`, Dio 인터셉터(401 시 refresh 자동 재시도) |
| **환경변수** | `JWT_SECRET`, `JWT_EXPIRES_IN` |
| **검증** | E2E: 회원가입→로그인→토큰 만료→갱신 |

---

## 4. 🟦 **A** · `onboarding`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 온보딩 |
| **앱 화면** | `app/lib/features/onboarding/presentation/` (환영·이름·목표·모아 만남) |
| **백엔드 모듈** | `backend/src/onboarding/` |
| **DB 테이블** | `onboarding_progress` (user_id, step, display_name, goal_type, goal_value, completed_at) |
| **핵심 기능** | 1) 표시 이름 입력 2) 목표 선택(다이어트·근육·건강유지) 3) 모아 캐릭터 첫 만남 연출 4) 진행률 서버 저장 |
| **API 엔드포인트** | `GET /onboarding/progress`, `PATCH /onboarding/step`, `POST /onboarding/complete` |
| **선행 의존** | `auth` |
| **후행 의존** | `home`, `splash` |
| **공유 키** | `SharedPreferences: owner_onboarding_done` (앱), `onboarding_progress.completed_at` (서버 권위) |
| **검증** | 진입→입력→완료→재진입 시 홈 직행 |

---

## 5. 🟦 **A** · `body_record`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 신체 기록 |
| **앱 화면** | `app/lib/features/body_record/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/body-record/` |
| **DB 테이블** | `body_records` (id, user_id, weight, body_fat, muscle_mass, recorded_at), `body_photos` (id, user_id, s3_key, type[before/after], taken_at) |
| **핵심 기능** | 1) 키·체중·체지방·근육량 기록 2) Before/After 사진 업로드(presigned URL) 3) 비교 슬라이더 4) 변화 추이 차트 데이터 제공 |
| **API 엔드포인트** | `GET/POST /body-records`, `GET /body-records/series?from&to`, `POST /body-photos/presign`, `GET /body-photos` |
| **선행 의존** | `auth` |
| **후행 의존** | `dashboard` (차트 소비), `workout`/`nutrition` (기초 신체값 사용) |
| **로컬 DB** | Drift 테이블 `body_records_local` (`isSynced: false` → workmanager 동기화) |
| **환경변수** | `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME` |
| **검증** | 오프라인 입력 → 온라인 복귀 시 동기화 확인 |

---

## 6. 🟦 **A** · `subscription`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 구독 결제 |
| **앱 화면** | `app/lib/features/subscription/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/subscriptions/` |
| **DB 테이블** | `subscriptions` (user_id, revenuecat_id, entitlement, status, expires_at, raw_payload_jsonb) |
| **핵심 기능** | 1) RevenueCat Paywall 노출 2) 구매·복원 3) Webhook으로 entitlement 동기화 4) Premium feature gate |
| **API 엔드포인트** | `POST /subscriptions/webhook` (RevenueCat 서명 검증), `GET /subscriptions/me` |
| **선행 의존** | `auth` |
| **후행 의존** | Phase 2 유료 기능 (월간 리포트 등) |
| **환경변수** | `REVENUECAT_API_KEY`, `REVENUECAT_WEBHOOK_SECRET` |
| **검증** | 샌드박스 결제 → Webhook → 앱 entitlement 갱신 |

---

## 7. 🟩 **B** · `home`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 메인 홈 |
| **앱 화면** | `app/lib/features/home/presentation/` |
| **백엔드 모듈** | — (집계 데이터를 다른 메뉴에서 fetch) |
| **DB 테이블** | (읽기 전용 — `rituals`, `stats`, `streaks` 조인) |
| **핵심 기능** | 1) `OwnerMoaAvatar` 캐릭터 2) 오늘의 약속 카드 3) 에너지·수분·휴식 스탯 게이지 4) 빠른 액션 진입 버튼 |
| **API 엔드포인트** | `GET /home/today` (집계 응답: 약속 + 스탯 + 스트릭 1쿼리) |
| **선행 의존** | `morning_ritual`(약속), `action`(스탯), `dashboard`(스트릭 카운트) |
| **후행 의존** | `evolution`, `evening_ritual` |
| **공유 위젯 사용** | `OwnerMoaAvatar`, `OwnerStatGauge`, `OwnerCard` |
| **검증** | 약속 저장 직후 홈 즉시 반영, pull-to-refresh |

---

## 8. 🟩 **B** · `dashboard`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 대시보드 (리워드) |
| **앱 화면** | `app/lib/features/dashboard/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/rewards/` |
| **DB 테이블** | `streaks` (user_id, current, longest, last_check_in), `xp_logs` (user_id, delta, reason, created_at), `badges` (user_id, badge_code, earned_at) |
| **핵심 기능** | 1) 연속 스트릭 카운트 2) XP 누적·레벨업 곡선 3) 배지 획득 룰 엔진(이행 N회·연속 N일 등) 4) 체중 변화 추이 차트(`fl_chart`) |
| **API 엔드포인트** | `GET /rewards/dashboard`, `POST /rewards/check-in`, `GET /rewards/badges` |
| **선행 의존** | `body_record`, `workout`, `nutrition` (이행 데이터 소스) |
| **후행 의존** | `home`(스트릭 표시), `evolution`(레벨 → 진화 단계) |
| **룰 엔진** | 클라/서버 양쪽 동일 입력→출력이 되도록 순수 함수 `lib/shared/rewards/rules.dart`로 추출 (양쪽 합의) |
| **검증** | 이행 트리거 → 스트릭·XP 증가 → 레벨업 → 배지 획득 시나리오 |

---

## 9. 🟩 **B** · `morning_ritual`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 아침 의식 |
| **앱 화면** | `app/lib/features/morning_ritual/presentation/` |
| **백엔드 모듈** | `backend/src/rituals/` (공통 — `evening_ritual`과 공유) |
| **DB 테이블** | `morning_rituals` (user_id, date, mood, promise_text, created_at) |
| **핵심 기능** | 1) 무드 선택(coral100·말풍선) 2) 오늘의 약속 입력 3) 홈 카드와 동기화 |
| **API 엔드포인트** | `GET /rituals/morning?date`, `POST /rituals/morning` |
| **선행 의존** | `auth` |
| **후행 의존** | `home`, `evening_ritual`(약속 이행 여부 평가) |
| **로컬 DB** | Drift `morning_rituals_local` |
| **공유 키** | `SharedPreferences: today_promise_*` |
| **검증** | 동일 일자 재입력 시 갱신 (insert가 아닌 upsert) |

---

## 10. 🟩 **B** · `action`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 데일리 액션 (물 / 산책) |
| **앱 화면** | `app/lib/features/action/presentation/` |
| **백엔드 모듈** | `backend/src/stats/` (수분·활동 카운트 누적) |
| **DB 테이블** | `daily_actions` (user_id, date, action_type, count, target, completed_at) |
| **핵심 기능** | 1) 물 잔 수 +/- 카운트 2) 산책 3상태(시작·진행·완료) 3) 일일 목표 대비 진행률 4) 완료 시 XP 트리거 |
| **API 엔드포인트** | `GET /actions/today`, `POST /actions/{type}/increment`, `POST /actions/{type}/complete` |
| **선행 의존** | `auth` |
| **후행 의존** | `home`(스탯 게이지), `dashboard`(스트릭 평가) |
| **외부 연동(Phase 2)** | `health` 패키지 → 산책 걸음수 자동 동기화 |
| **검증** | 오프라인 카운트 → 온라인 복귀 시 합산 정확성 |

---

## 11. 🟩 **B** · `evening_ritual`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 저녁 의식 |
| **앱 화면** | `app/lib/features/evening_ritual/presentation/` (다크 테마) |
| **백엔드 모듈** | `backend/src/rituals/` (`morning_ritual`과 공유) |
| **DB 테이블** | `evening_rituals` (user_id, date, reflection, promise_kept_bool, created_at) |
| **핵심 기능** | 1) 오늘의 회고 입력 2) 아침 약속 이행 체크 3) 저녁 푸시 알림 진입 |
| **API 엔드포인트** | `GET /rituals/evening?date`, `POST /rituals/evening` |
| **선행 의존** | `morning_ritual`(약속 텍스트 표시) |
| **후행 의존** | `dashboard`(스트릭 마감 평가) |
| **푸시** | `notifications` 모듈에서 매일 20:00 트리거 |
| **검증** | 약속 미설정 시 회고만 노출 |

---

## 12. 🟩 **B** · `evolution`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 진화 (캐릭터 단계) |
| **앱 화면** | `app/lib/features/evolution/presentation/` (풀스크린, 단색 단계 전환) |
| **백엔드 모듈** | (`rewards` 안에서 stage 계산 함수 제공) |
| **DB 테이블** | (`xp_logs` 누적값으로 stage 계산 — 별도 테이블 없음) |
| **핵심 기능** | 1) 누적 XP → 진화 단계 매핑 2) 단계 전환 애니메이션 3) 단계별 배경 토큰 변경 4) (Phase 2) 공유 시트 |
| **API 엔드포인트** | `GET /rewards/evolution` (stage, next_threshold) |
| **선행 의존** | `dashboard`(XP) |
| **후행 의존** | `home`(아바타 단계 반영) |
| **디자인 룰** | **그라디언트 금지**, 단색 토큰만 사용 |
| **검증** | 임계값 직전·직후 XP에서 단계 변경 정확성 |

---

## 13. 🟦 **A** · `workout`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 운동 |
| **앱 화면** | `app/lib/features/workout/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/workout/` |
| **DB 테이블** | `workout_plans` (user_id, date, plan_jsonb), `workout_logs` (user_id, date, exercise_code, met, duration_min, calories) |
| **핵심 기능** | 1) MET 테이블 기반 Rule 추천 (사용자 신체 기반 칼로리 산출) 2) 일일 플랜 생성 3) 이행 체크 + 시간 기록 4) 오프라인 저장 |
| **API 엔드포인트** | `GET /workout/recommend?date`, `POST /workout/logs`, `GET /workout/logs?from&to` |
| **선행 의존** | `body_record`(체중·목표), `auth` |
| **후행 의존** | `dashboard`(이행 → XP·스트릭) |
| **외부 데이터** | 2024 Adult Compendium of Physical Activities (MET) — `backend/src/workout/data/met_table.json` 정적 데이터 |
| **로컬 DB** | Drift `workout_logs_local` |
| **검증** | 추천→이행→리워드 트리거 단위 |

---

## 14. 🟩 **B** · `nutrition`

| 항목 | 내용 |
|---|---|
| **메뉴명** | 식단 |
| **앱 화면** | `app/lib/features/nutrition/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/nutrition/` |
| **DB 테이블** | `nutrition_logs` (user_id, date, meal_type, food_code, food_name, kcal, protein, carb, fat), `food_cache` (food_code PK, food_name, nutrient_jsonb, fetched_at) |
| **핵심 기능** | 1) 식약처 API 음식 검색 2) Redis로 검색 결과 캐시(24h) 3) 일일 칼로리 가이드 (BMR·활동지수) 4) 끼니별 기록 |
| **API 엔드포인트** | `GET /nutrition/search?q`, `POST /nutrition/logs`, `GET /nutrition/today`, `GET /nutrition/guide` |
| **선행 의존** | `body_record`(BMR 계산), `auth` |
| **후행 의존** | `dashboard`(이행 → XP) |
| **외부 API** | 식약처 식품영양성분 DB OpenAPI |
| **환경변수** | `MFDS_API_KEY`, `REDIS_URL` |
| **로컬 DB** | Drift `nutrition_logs_local` |
| **검증** | 검색→캐시 적중→기록→일일 칼로리 합산 |

---

## 15. 🟧 **공동** · `wearable` (Phase 2)

| 항목 | 내용 |
|---|---|
| **메뉴명** | 웨어러블 연동 |
| **앱 화면** | `app/lib/features/wearable/{data,domain,presentation}/` |
| **백엔드 모듈** | `backend/src/wearable/` |
| **DB 테이블** | `wearable_syncs` (user_id, source[apple/google], synced_at, payload_jsonb) |
| **핵심 기능** | 1) HealthKit / Health Connect 권한 요청 2) 걸음·심박·수면 데이터 수집 3) 백엔드 업로드 |
| **외부 패키지** | `health` ^13.3.1 |
| **Phase** | 2 — MVP 시점에는 디렉토리 구조만 유지, 구현 보류 |

---

## 16. 🚦 메뉴 의존성 그래프

```
🟦 auth ─┬─ 🟦 onboarding ─ 🟦 splash
         ├─ 🟦 body_record ─┬─ 🟦 workout ─┐
         ├─ 🟦 subscription │              ├─ 🟩 dashboard ─┬─ 🟩 home
         └─ 🟩 rituals ─────┤              │                ├─ 🟩 evolution
                            └─ 🟩 nutrition┘                └─ (push)
       🟩 action ───────────────────────────┘
```

**핵심 직렬 경로**: `🟦 auth` → `🟦 body_record` → (`🟦 workout`/`🟩 nutrition`) → `🟩 dashboard` → `🟩 home`/`🟩 evolution`

→ Sprint 1 시작 시 **🟦 A의 `auth` JWT mock guard와 `body_record` 인터페이스가 가장 먼저 합의**되어야 🟩 B의 작업이 풀림.

---

## 17. ⚠️ 공유 영역 충돌 방지 규칙

| 파일/디렉토리 | 위험 | 규칙 |
|---|---|---|
| `app/lib/core/theme/owner/` | 토큰 동시 수정 | **PR 합의 후만 수정**, 신규 색은 `extra_colors.dart` 분리 |
| `app/lib/shared/widgets/owner/` | 공용 위젯 충돌 | 신규 추가는 자유, **기존 위젯 수정은 양쪽 리뷰** |
| `app/lib/routing/app_router.dart` | 라우트 동시 추가 | `routing/routes/{menu}_routes.dart` 분리 후 main에서 import |
| `app/lib/core/di/` | Provider 충돌 | 메뉴별 파일 분리 (`auth_providers.dart`, `home_providers.dart` …) |
| Drift schema 파일 | 마이그레이션 번호 충돌 | 메뉴별 prefix 테이블, 마이그레이션 번호는 **PR 머지 직전 rebase 시 재정렬** |
| `backend/src/app.module.ts` | imports 배열 충돌 | alphabetical 정렬 강제 |
| `.env.example` | 변수 추가 충돌 | 메뉴 주석 블록(`# === auth ===` …)으로 구획 |
| `docker-compose.yml` | 서비스 추가 | **변경 시 양쪽 리뷰 필수** |
| `app/pubspec.yaml` / `backend/package.json` | 의존성 충돌 | 동일 영역에 두 사람이 추가 시 PR 머지 직전 락파일 재생성 |

---

## 18. 🌳 브랜치·커밋 규칙 (제안)

- 브랜치: `feature/{owner}-{menu}-{topic}` 예) `feature/silver-auth-jwt`, `feature/blue-dashboard-streak`
- 커밋 prefix: `feat({menu})`, `fix({menu})`, `chore({menu})` — 메뉴명을 scope로 강제
- PR 단위: **메뉴 1개 = PR 1개** 권장 (대규모 메뉴는 sub-PR 허용)
- 머지 전 체크: `bash verify.sh` 통과

---

## 19. 📅 권장 진행 순서 (Sprint)

| Sprint | 🟦 **A** | 🟩 **B** | 합의 산출물 |
|---|---|---|---|
| 1 | `auth`, `splash` | `morning_ritual`, `home` 골격 | API 클라이언트 컨벤션, JWT mock guard |
| 2 | `onboarding`, `body_record` | `action`, `evening_ritual` | Drift 동기화 패턴, `rituals` DTO |
| 3 | `workout` | `nutrition`, `dashboard` 룰 엔진 | 리워드 룰 순수 함수 합의 |
| 4 | `subscription` | `evolution`, 푸시 알림 | RevenueCat entitlement·푸시 트리거 |
| 통합 | `verify.sh` 통과, E2E 시나리오 | `verify.sh` 통과, E2E 시나리오 | 통합 회귀 테스트 |

---

## 20. 🔗 일일 작업 기록과의 관계

본 문서는 **분장 마스터 문서**이고, **일일 작업 기록**은 별개로 `FEAT_SUMMARY_작성가이드.md`에 따라 운영한다.

| 구분 | 본 문서 (`WORK_DIVISION.md`) | 일일 Feat Summary (`docs/YYYY-MM-DD_feat/…/summary.md`) |
|---|---|---|
| 목적 | 메뉴별 책임·의존·공유 규칙 정의 | 하루 작업 결과·협업 요청 기록 |
| 갱신 주기 | 분장 변동 시(드물게) | 매일 또는 PR 직전 |
| 갱신 권한 | 양쪽 합의 후 PR | 본인 역할 파일만 (앱/백엔드 분리) |
| 협업 채널 | §17 공유 규칙 + §16 의존성 | 각 summary `§5. 상대에게 전달·요청` |

→ 메뉴 작업 중 발생한 협업 이슈(API 스펙 협의, 파괴적 변경 등)는 **일일 summary §5**에 기록하고, 본 문서의 메뉴 카드 변경이 필요하면 별도 PR로 본 문서 갱신.

---

## 21. 📝 본 문서 갱신 규칙

> FEAT_SUMMARY 가이드의 **충돌 방지 정신**을 본 문서에도 적용한다.

1. **단독 갱신 금지** — 분장·의존성·공유 규칙 변경은 **양쪽 리뷰 PR**로만 머지
2. **갱신 트리거**
   - 메뉴 신설·삭제 / 담당자 교체 / 작업량 재산정
   - 외부 의존(API·SDK·DB 스키마) 추가 → 메뉴 카드의 `환경변수`·`외부 API` 필드 갱신
   - §17 공유 영역 신규 추가
3. **갱신 절차**
   - PR 제목: `docs(work-division): {변경 요약}`
   - PR 본문에 변경 전/후 표 또는 diff 인용
   - 머지 전 양쪽 합의 코멘트(`LGTM` 등) 1건 이상 필수
4. **변경 이력(§22)** — 모든 변경 PR은 §22 표에 한 줄 추가
5. **상충 시 우선순위**
   - 본 문서 §17(공유 규칙) > 메뉴 카드 개별 결정 사항
   - 본 문서 ↔ 일일 summary 충돌 시 본 문서가 우선 (단, 일일 summary §5에 기재된 합의가 우선되는 사례는 PR로 본 문서를 갱신)

---

## 22. 변경 이력

| 일자 | 작성자 | PR | 내용 |
|---|---|---|---|
| 2026-04-25 | (초안) | — | 메뉴 14개 분장, 공유 영역 규칙 정의, 트랙 색상 표기(🟦/🟩/🟧) |
