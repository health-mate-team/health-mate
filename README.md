# 오우너 (Owner) — 호르몬 주기 기반 펨테크 운동 앱

> 매일 같은 추천을 하면 펨테크 앱이 아니다.
> 사용자가 "오늘 며칠차" 냐에 따라 앱 전체가 다른 모습으로 보인다.

한국 첫 펨테크 운동 앱. 28일 호르몬 주기 4단계 (월경기·난포기·배란기·황체기) 에 맞춰 운동·식사·휴식 가이드와 캐릭터(모아) 의 표정·메시지가 매일 분기됩니다. 캐릭터는 외피, **펨테크 가치 전달이 본질**.

---

## 검증 가설 (4주 베타)

| ID | 가설 | 합격선 |
|----|------|--------|
| **H1 (P0, 가장 위험)** | 4주 사용 후 사용자가 자기 사이클을 더 잘 이해한다 | 70% |
| **H2 (P0)** | 추천한 5분 운동을 실제로 한다 | 주 3회+ 40% |
| **H3 (P1)** | D7 리텐션 30%+, D30 20%+ | 일반 헬스앱(15–25%) 초과 |
| **H4 (P1)** | 자기 몸을 미워하지 않게 된다 | 자기 돌봄 60%+ / NPS 50+ |

**합격 못 하면 출시하지 않는다.** 마스터 플랜 전체: [`docs/planning/owner-femtech-mvp/`](docs/planning/owner-femtech-mvp/00_OVERVIEW.md)

---

## 차별화 5원칙

| 원칙 | 의미 |
|---|---|
| **사이클 OS** | 모든 추천은 단계 단위로 분기. SOURCE OF TRUTH = `02_CYCLE_OS.json` |
| **5분 이하** | 30대 직장인의 "시간 부족" 페인포인트 정조준 |
| **자기혐오 금지** | "힘내자 / 참아 / 조절해" 등 죄책감 단어가 단계별로 차단 (`avoidWords`) |
| **로컬 우선 / 익명화** | 생리일·증상은 디바이스에만. 분석 데이터는 SHA-256 익명화 |
| **캐릭터로 전달** | 큰 숫자·차트 대신 모아의 표정·자세·메시지 |

---

## 사이클 OS 한눈에

| 단계 | 비유 | 일자(28일 기준) | 컬러 토큰 | 모아 표정 | 운동 우선 | 운동 회피 |
|---|---|---|---|---|---|---|
| 🌑 월경기 | 겨울 | 1–5 | `cocoa800` | sleepy | 요가·호흡 | hiit·근력 |
| 🌱 난포기 | 봄 | 6–12 | `beige300` | happy | 근력·카디오·hiit | — |
| ☀️ 배란기 | 여름 | 13–15 | `coral500` | starEyes | hiit·근력 | — |
| 🍂 황체기 | 가을 | 16–28 (early/late 분기) | `accentLavender` | default → sleepy | 요가·산책·호흡 | hiit |

---

## 진행 상태 (2026-05-05 기준 ~80%)

### ✅ 완료

- **인프라** — Drift + Riverpod + Freezed 코드 생성 파이프라인 가동
- **사이클 OS** — 28일 4단계 자동 계산, 21–35일 변동·불규칙·missed-period·황체기 sub_phase 처리
- **추천 엔진** — phase priority + skip 제외 + `userGoalId` 가산 + 한 줄 rationale (transparency 원칙)
- **운동 매트릭스 17종** — `02_CYCLE_OS` × `03_WORKOUT_MATRIX` 그대로 const 데이터 (영상 없이 텍스트+동작리스트로 작동)
- **분석 이벤트 6종** — `app_open / workout_completed / workout_skipped / morning_ritual_completed / cycle_phase_changed / survey_response`. 디바이스 로컬 SQLite 큐 + SHA-256 user_id_hash
- **설문 인프라** — D0/D14/D28 ±1일 윈도우 자동 트리거. KPI_01·04·05 + OBS_01·03 측정 회로 닫힘
- **화면 11종** — splash · onboarding(welcome/name/goal/cycle/meet-moa) · home(사이클 인디케이터+추천) · morning(mood/promise) · evening · workout_session · cycle_calendar(28일 원형) · survey · evolution
- **WorkoutSession** — fallback (일러스트+카운트다운) + audio_guide TTS (`flutter_tts`) + 백그라운드 wallclock 보정
- 정적 검증: `flutter analyze` **0 error / 0 warning**

### ⏳ 다음 (앱)

- 백엔드 합의 후 dio retrofit 클라이언트 스텁 + workmanager 동기화 잡 (`analytics_events.synced` 활용)
- 설문 dismissal 쿨다운 / walk 의 `general_walk` id / D14 척도 매핑
- WorkoutSession 음성 설정 UI / 사이클 캘린더 과거 누적

### 🎬 외부 의존

- **운동 영상 20개** — 트레이너 1명 8시간 + 편집 13일 (~ 300–400만 원). 베타 합격 후 가동. 그 전까지 fallback 모드로 작동.
- **시스템 환경** — `flutter test` 가 `Could not prepare isolate` 로 hang. 시스템 재부팅 / SDK 재설치 필요. (정적 검증은 통과)

### 🔵 백엔드 미정 (각 일자 §5 누적, 베타 D-7 마감)

- `POST /v1/analytics/events:batch` — 6종 이벤트 DTO + idempotency + `device_user_hash`
- `response_value` string 통일 + `kind` 메타 동반
- freeText PII 필터 (클라/서버 이중)
- `survey_id` enum 표기 통일 (`baseline_d0/pulse_d14/final_d28`)
- D28+ 응답 KPI 집계 제외 (`is_within_window` ETL 플래그)
- **`cycle_inputs` 미저장 정책의 CI 자동 검사** (R03 critical — 생리일·증상은 서버 컬럼 자체 금지)
- `GET /v1/workouts` (Phase 2), `GET /v1/internal/recommendation-stats` (베타 후)

---

## 기술 스택

### 모바일 (`app/`)

| 카테고리 | 기술 | 버전 |
|---|---|---|
| 프레임워크 | Flutter | 3.41 |
| 언어 | Dart | 3.11 |
| 상태 관리 | flutter_riverpod / riverpod_annotation | ^2.6.1 |
| 로컬 DB | drift (SQLite ORM) | ^2.21.0 |
| 라우팅 | go_router | ^14.6.2 |
| 차트 | fl_chart | ^0.69.0 |
| 음성 안내 | flutter_tts | ^4.2.0 |
| 익명화 해시 | crypto | ^3.0.5 |
| 백그라운드 동기화 | workmanager | ^0.5.2 |
| 푸시 알림 | firebase_messaging | ^15.1.4 |
| 건강 데이터 (Phase 2) | health (HealthKit + Health Connect) | ^13.3.1 |
| BLE (Phase 2) | flutter_blue_plus | ^1.34.5 |
| 인앱 결제 (Phase 2) | purchases_flutter (RevenueCat) | ^9.16.0 |
| 네트워킹 | dio + retrofit | (retrofit_generator 일시 비활성화) |

### 백엔드 (`backend/`)

| 카테고리 | 기술 |
|---|---|
| 프레임워크 | NestJS 11 + TypeScript 5 |
| ORM / DB | TypeORM + PostgreSQL 16 |
| 캐시 | Redis 7 |
| 인증 | JWT (`@nestjs/jwt`) |
| 검증 | class-validator |

### AI 서비스 (`ai-service/`)

| 항목 | 값 |
|---|---|
| 프레임워크 | FastAPI 0.115.6 |
| 상태 | MVP 스텁 (Phase 2에서 ML 구현) |

### 인프라

Docker Compose · 프로덕션은 AWS ECS Fargate / S3 + CloudFront 예정.

---

## 프로젝트 구조

```
health-mate/
├── app/                                  # Flutter 앱
│   ├── lib/
│   │   ├── core/
│   │   │   ├── analytics/                # AnalyticsEvent sealed + Drift recorder + user_id_hash
│   │   │   ├── db/                       # AppDatabase + cycle_inputs/analytics_events DAO
│   │   │   ├── di/                       # 전역 Riverpod provider
│   │   │   └── theme/owner/              # 디자인 토큰 (color/typo/spacing/radius/motion)
│   │   ├── features/                     # Feature-First (data/domain/presentation 3계층)
│   │   │   ├── action/                   # 물·산책 액션 (단계별 분기)
│   │   │   ├── cycle/                    # ★ 사이클 OS — SOURCE OF TRUTH
│   │   │   │   ├── domain/{entities,services,repositories}/
│   │   │   │   ├── data/cycle_repository_impl.dart
│   │   │   │   ├── presentation/
│   │   │   │   │   ├── cycle_providers.dart
│   │   │   │   │   └── pages/{onboarding_cycle,cycle_calendar,workout_session}.dart
│   │   │   │   └── static_data/          # phase_profiles, workout_matrix (02·03 JSON 1:1)
│   │   │   ├── evening_ritual/
│   │   │   ├── evolution/
│   │   │   ├── home/
│   │   │   ├── morning_ritual/
│   │   │   ├── onboarding/
│   │   │   ├── splash/
│   │   │   └── survey/                   # ★ D0/D14/D28 설문
│   │   │       ├── domain/{entities,services}/
│   │   │       └── presentation/{survey_providers,pages/survey_page}.dart
│   │   ├── routing/app_router.dart
│   │   └── shared/{widgets/owner,constants,utils}/
│   ├── test/features/cycle/              # 단위 테스트 4종
│   ├── pubspec.yaml
│   ├── build.yaml                        # retrofit_generator 일시 비활성화
│   └── analysis_options.yaml
│
├── backend/                              # NestJS API (포트 3000)
├── ai-service/                           # FastAPI (포트 8000, MVP 스텁)
│
├── docs/
│   ├── planning/owner-femtech-mvp/       # ★ 마스터 플랜 (가설·사이클 OS·운동·KPI·타임라인·리스크)
│   ├── design/owner-mock-develop/        # 화면 JSON 명세 + reference 위젯 (격리된 dart 패키지)
│   ├── 2026-MM-DD_feat/{app,backend}/    # 일별 Feat Summary
│   └── FEAT_SUMMARY_작성가이드.md
│
├── .cursor/rules/                        # 디자인 룰 + Feat Summary 룰
├── docker-compose.yml
├── .env.example
├── CLAUDE.md                             # Claude Code 운영 규칙
└── verify.sh                             # 빌드·린트·구조 검증
```

---

## 시작하기

### 사전 준비

- Docker Desktop · Node.js 20+ · Flutter 3.41+

### 백엔드 + DB 실행

```bash
cp .env.example .env
# .env에서 JWT_SECRET 등 필수값 변경

docker compose up -d
curl http://localhost:3000/api
```

### 모바일 앱 실행

```bash
cd app

flutter pub get

# Drift / Riverpod / Freezed 코드 생성 (필수)
dart run build_runner build --delete-conflicting-outputs

# 정적 검증 — 사이클/설문 신규 코드 0 error / 0 warning
flutter analyze

# 단위 테스트 (환경 hang 시 시스템 재부팅 후 재시도)
flutter test

# 실제 실행
flutter run
```

### 골든 패스 (수동 QA)

```
splash → onboarding(welcome → name → goal → cycle 신규 → meet-moa) → home

home 진입:
  ├ 헤더 우측: 🌑 4/28 (사이클 인디케이터, 탭 → /cycle/calendar)
  ├ 추천 카드: "월경기 따뜻한 5분 요가 / 월경기라 격한 운동은 피해요"
  │             (탭 → /cycle/workout/{id} → 5분 카운트다운 → workout_completed)
  ├ D0 윈도우면 자동 /survey/baseline_d0 (KPI_01 baseline)
  └ analytics_events 테이블에 app_open + 진행 상황별 추가
```

---

## 디자인 룰 (요약)

`.cursor/rules/owner-design.mdc` 와 `app/lib/core/theme/owner/` 가 SOURCE OF TRUTH.

- **캐릭터 우선** — 큰 숫자·차트보다 모아 표정·자세·카피
- **따뜻함** — 모서리 `OwnerRadius.md` 이상, 시맨틱 토큰(`actionPrimary` 등)만 사용
- **부담 없음** — 죄책감·협박 카피 금지. 단계별 `avoidWords` 코드 차단
- **한 화면 한 가지** — 핵심 액션 1, 보조 최대 2
- **미세 모션** — `OwnerMotion` 만. 캐릭터 호흡 ~2.4s, scale 1.0↔1.02
- **금지** — 그라디언트, 같은 컴포넌트 3색 이상, 모아 회색조·잘림

---

## Phase 로드맵

> 펨테크 검증 합격(H1 + H2)이 모든 단계의 게이트.

### Phase 1 — 펨테크 MVP (현재 ◐ 진행 중, ~80%)

검증 게이트: 4주 베타 후 H1 + H2 합격 시 Phase 2 진입.

- [x] 사이클 OS — 28일 4단계 자동 계산
- [x] 추천 엔진 — phase priority + goal 가산 + rationale
- [x] 운동 매트릭스 17종 (fallback 모드)
- [x] 분석 이벤트 6종 (디바이스 로컬 큐)
- [x] D0/D14/D28 설문 자동 트리거
- [x] 화면 11종 + 사이클 캘린더 + 워크아웃 세션
- [x] WorkoutSession audio_guide (TTS) + 백그라운드 보정
- [ ] 백엔드 분석 이벤트 수집 API + 동기화 잡
- [ ] 운동 영상 20개 (외부 촬영 — 베타 합격 후 가동)
- [ ] 50명 4주 베타 + KPI 동결 + 결정

### Phase 2 — 펨테크 확장 (베타 합격 후)

- [ ] 운동 영상 20개 + v1.1 추가 20개 (총 40개)
- [ ] 13_cycle_calendar 과거 사이클 누적·추세 (H1 강화)
- [ ] HealthKit / Health Connect — 수면·심박·걸음 자동 입력
- [ ] PMS 증상 트래킹 + 단계별 패턴 분석
- [ ] 영양 가이드 단계별 (`food_focus / food_avoid` 매트릭스 코드 → 콘텐츠로 확장)
- [ ] 모아 옷장·진화 시각 다양화 (캐릭터 록인 강화 → H3)
- [ ] 친구 초대·사이클 공유 (선택, 익명 우선)
- [ ] RevenueCat 유료 구독 (월간 심층 리포트)

### Phase 3 — 펨테크 글로벌·B2B

- [ ] LLM 기반 사이클 코칭 채팅 (Claude API, 의료 키워드 차단)
- [ ] InBody / Withings 등 BLE 체성분 연동 — 단계별 수분 변동 자동 보정
- [ ] B2B 여성 복지 패키지 (기업 헬스케어)
- [ ] 다국어 (영어·일본어 우선 — 펨테크 시장이 큰 지역)
- [ ] 의료 파트너십 (산부인과 클리닉 데이터 협업)

---

## 운영 룰

| 룰 | 내용 |
|---|---|
| `CLAUDE.md` | Claude Code 운영 규칙 — 기술 스택 고정, 디렉토리 책임, 금지 사항 |
| `.cursor/rules/owner-design.mdc` | 오우너 디자인 룰 (토큰·카피·금지) |
| `.cursor/rules/docs-feat-summary.mdc` | 일별 Feat Summary 작성 룰 (app/backend 분리) |
| `docs/FEAT_SUMMARY_작성가이드.md` | 사람용 Feat Summary 가이드 |
| `githooks/commit-msg` | `with cursor` / `Made-with: Cursor` 차단 |

---

## 핵심 원칙

> 펨테크 + 건강 앱이 진짜로 작동해야 한다는 압박이 본질입니다.
> 캐릭터는 외피, 펨테크 가치 전달이 본질입니다.

이 문장이 모든 결정의 충돌 시 최종 판단 기준입니다.
([AGENT_GUIDE.md](docs/planning/owner-femtech-mvp/AGENT_GUIDE.md) 의 마지막 줄)

---

## 참고 자료

- [마스터 플랜 인덱스](docs/planning/owner-femtech-mvp/00_OVERVIEW.md) — 가설·사이클 OS·운동·KPI·타임라인·리스크 6개 모듈
- [에이전트 가이드](docs/planning/owner-femtech-mvp/AGENT_GUIDE.md) — AI 에이전트가 마스터 플랜을 어떻게 활용하는지
- [최근 일별 Feat Summary](docs/2026-05-05_feat/app/summary.md) — 진행·검증·백엔드 요청 누적
- [리서치 보고서](docs/research/RESEARCH-healthcare-app-2026-04-06.md) — 시장 분석·API·기술 스택 비교
- [health package v13](https://pub.dev/packages/health)
- [flutter_tts](https://pub.dev/packages/flutter_tts)
