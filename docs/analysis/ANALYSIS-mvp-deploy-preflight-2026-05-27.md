# MVP 운영 배포 사전점검 — 취약점·오류 종합 분석

> 분석일: 2026-05-27
> 프로젝트: health-mate (여성 건강/사이클 + 데일리 의식 MVP)
> 분석 관점: feature/security-hardening → main 운영 배포 직전, 보안 그룹A 완료 상태에서 CI(run-cases)가 드러낸 보안-무관 기존 결함 전수 검토
> 방법: code-reviewer 에이전트(backend/src 전역, HIGH-confidence) + verify-cases 시간취약 fixture 직접 전수 스캔

---

## 0. 요약

보안 그룹A(H-1·H-3·M-4·L-2) + auth refresh_token 정합 수정은 완료됐고 **자체 검증은 green**(auth_register, Jest 31/31). 그러나 CI가 진행되며 **사이클(cycle) 도메인의 날짜 계산 결함군**과 **시간취약 테스트 fixture**가 드러났다. 핵심 결론:

- **CI를 막는 직접 원인은 cycle_current 1건** — 근본은 `cycle.service`가 경과 시간을 롤오버하지 않아 `days_until_next_period`가 음수가 되는 것(스키마 `min:0` 위반).
- 같은 계열의 **실제 운영 버그가 5건 더** 있음 (calendar 음수, history phase 고정, NaN→500, 배지 오판정, 온보딩 TZ, 온보딩 재호출 크래시).
- 시간취약 fixture는 `onboarding_complete.yaml`의 고정 날짜 1종(3곳)이 유일하며, cycle_current이 이를 상속해 실패.

→ **B 실행 권장 경로**: 근본 cycle 버그(P0-1)를 고치면 fixture를 안 바꿔도 CI가 통과하고 실제 버그도 해소된다(권장). 최소 우회만 원하면 fixture를 `{{today}}`로 교체(아래 §5-A).

---

## 1. 프로젝트 개요

| 분류 | 기술 | 비고 |
|---|---|---|
| 모바일 | Flutter 3.41 + Riverpod 3.0 + Drift | |
| API | NestJS 11 + TypeScript + TypeORM | backend/ (포트 3001→3000) |
| DB/캐시 | PostgreSQL 16 / Redis 7 | Redis는 H-3 블랙리스트에 사용 |
| 배포 | Docker Compose, GitHub Actions → AWS EC2(서울) | main 머지 시 자동배포 |
| 검증 | verify-feature 자체 하네스(run-cases.ts, unit+contract) | docs/verify-cases/*.yaml |

**완성도**: P0~P3 백엔드 + Flutter 연동 구현됨. 보안 하드닝 15/17 완료(잔여 C-1·H-5 도메인 종속). 사이클/통계 도메인에 날짜 계산 결함 다수.

---

## 2. 우선순위별 이슈 목록

### 🔴 P0 — 운영 계약 위반 / 크래시 (배포 전 권장 수정)

| # | 위치 | 문제 | 트리거 | 신뢰도 |
|---|---|---|---|---|
| **P0-1** | `cycle.service.ts:65-72` `getCurrent` | `nextPeriodDate = lastPeriodStart + cycleLength` (롤오버 없음) → 한 주기 경과 시 `days_until_next_period` **음수** (스키마 `min:0` 위반). `day_of_cycle`도 28 초과. **← CI cycle_current 실패 원인** | 마지막 생리일이 1주기(≈28일) 이상 지난 사용자 (앱 미접속·예정일 경과) | 100 (CI 재현) |
| **P0-2** | `cycle.service.ts:113-127` `getCalendar` | JS `%`가 부호 보존 → 조회 월이 `lastPeriodStartDate` 이전이면 `day_of_cycle` **음수** | 가입 이전 월 캘린더 조회 / 미래 날짜 설정 후 이전 월 요청 | 95 |
| **P0-3** | `onboarding.service.ts:23-51` `complete` | `isOnboardingCompleted` 가드 없이 `cycleRepo.create`/`statRepo.create` 재호출 → UNIQUE면 **500**, 없으면 UserCycle **중복행** | 더블탭·네트워크 재시도 | 88 |
| **P0-4** | `stats.service.ts:22-28` `getHistory` | `?days=abc` → `Number→NaN` → `new Date(NaN)` → `"NaN-NaN-NaN"`이 `Between`에 전달 → **PostgreSQL 500** | 비숫자 days 쿼리파라미터 | 90 |

> P0-1·P0-2는 동일 근본 원인(사이클 날짜 계산이 경과/범위초과를 안전 처리하지 않음). 한 곳의 안전 모듈로 헬퍼로 함께 해결 권장.

### 🟡 P1 — 로직 오류 / 잘못된 데이터

| # | 위치 | 문제 | 신뢰도 |
|---|---|---|---|
| **P1-1** | `stats.service.ts:46-50` `getHistory` | `calculateCyclePhase`가 항상 **오늘** 기준 → 모든 과거 daily_record의 `phase`가 오늘 페이즈로 채워짐 (30일 차트 대부분 오진) | 100 |
| **P1-2** | `rewards.service.ts:53-59` WaterGoal 배지 | 필터 없는 `findOne` → 임의 행의 `waterCups`로 판정 → 8잔 달성일이 아닌 행이면 배지 영구 누락/오수여 | 95 |
| **P1-3** | `onboarding.service.ts:76-80` `calculatePhase` | `parseLocalDate` 미사용(UTC파싱 vs 로컬now) → KST 0~9시 사이 `dayOfCycle` 1 틀어짐 | 85 |

### 🟢 P2 — 시간취약 테스트 fixture (B 작업 직접 대상)

| # | 위치 | 문제 | 조치 |
|---|---|---|---|
| **P2-1** | `onboarding_complete.yaml:47,88,106` | `last_period_start_date: "2026-04-28"` 고정 → 오늘 기준 stale. cycle_current이 setup으로 상속해 P0-1 발현 | `{{today}}`로 교체 (또는 P0-1 근본 수정 시 불필요) |
| **P2-2** | `actions_walk.yaml` (수정완료) | `started_at/ended_at` 2026-05-08 고정 → M-4(±36h) 위반 | `{{now}}`로 교체 **완료** (7e53137) |

> 전수 확인: verify-cases에서 고정 날짜 리터럴은 위 2종뿐. harness에 `{{today}}`(date)·`{{now}}`(ISO) 치환 토큰 추가 완료(7e53137). 향후 "오늘 기준" fixture는 토큰 사용 규약화 권장.

### ⚪ P3 — 보안 잔여 / 알려진 미완 (별도 추적)

| # | 항목 | 상태 |
|---|---|---|
| **P3-1** | C-1 HTTPS · H-5 도메인 swap | 도메인 발급 종속 → 배포 게이트(mvp-deploy-gate)로 추적. C-1은 건강 PII 평문 → 공개 출시 절대 게이트 |
| **P3-2** | TypeORM 마이그레이션 체계 | NODE_ENV=production 시 synchronize OFF → 다음 스키마 변경 전 필수 |
| **P3-3** | `/auth/refresh` dormant | type='refresh' 토큰을 아무도 발급 안 함(refresh_token 응답 제거 후) → 항상 401. 스펙 미완 영역(verify_issues 추적). 의도된 상태 |

---

## 3. 코드 품질 — 강점 / 부채

**강점**: 보안 하드닝 일관성(throttler·helmet·DTO 검증·Redis 블랙리스트), Feature 모듈 분리, DTO+class-validator 패턴, `parseLocalDate`/`localDateString` 헬퍼 존재(단 일부 미사용).

**핵심 부채**: 사이클 날짜 계산이 **여러 곳에 중복·불일치**(`cycle.service`엔 `parseLocalDate`, `onboarding.service`엔 raw `new Date`; getCurrent/getCalendar/stats가 각자 phase 계산). → 날짜/사이클 계산을 **단일 유틸로 통합 + 기준일 파라미터화**하면 P0-1·P0-2·P1-1·P1-3을 한 번에 해소.

---

## 4. 보안 점검 (그룹A 반영 후)

OWASP 관점에서 그룹A로 brute-force(H-1)·세션무효화(H-3)·입력검증(M-4)·DoS표면(L-2)이 처리됨. 잔여 위험은 전송계층(C-1 HTTPS, P3-1)뿐. 에이전트 검토에서 **신규 authz/IDOR/injection HIGH 이슈 없음** (date-계약 위반이 주). 단 P0-3(온보딩 재호출)은 가용성/데이터정합 리스크.

---

## 5. 개선 로드맵

### Quick Win (각 1~수 줄)
- [ ] **P0-4**: `getHistory` 진입부 `if (Number.isNaN(days)) days = 30;`
- [ ] **P1-2**: `statRepo.count({ where:{ userId, waterCups: MoreThanOrEqual(8) }}) > 0`
- [ ] **P0-2**: `normalizedDay = ((((dayOfCycle-1) % len) + len) % len) + 1` (음수 안전 모듈로)
- [ ] **P0-3**: `complete()` 상단 `if (user.isOnboardingCompleted) throw new ConflictException(...)`
- [ ] **P1-3**: `onboarding.service`에서 `parseLocalDate` 사용 통일

### B 실행 (CI green → main 머지) — 두 경로
- **A. 근본 수정(권장)**: P0-1 `getCurrent` + (가능하면 dayOfCycle 래핑)을 안전 모듈로로 수정 → fixture 안 바꿔도 cycle_current 통과 + 실제 버그 해소.
  ```
  daysSince = today - lastPeriodStart
  dayOfCycle = (daysSince % cycleLength) + 1
  daysUntilNext = cycleLength - (daysSince % cycleLength)
  nextPeriodDate = today + daysUntilNext
  ```
- **B. 최소 우회**: `onboarding_complete.yaml` 3곳 `"2026-04-28"` → `"{{today}}"`. CI는 green되나 P0-1 실버그는 잔존(→ 별도 추적 필수).

> 권장: **A로 P0-1을 고치고**, P0-2도 함께(같은 함수군) 처리 후 CI 확인 → main 머지. Quick Win 나머지는 같은 PR 또는 후속.

### 단기 (1~2주)
- [ ] 사이클/날짜 계산 단일 유틸 통합 + 기준일 파라미터화 (P1-1 포함)
- [ ] cycle.service.spec에 "경과 1주기↑" / "이전 월 calendar" 경계 케이스 추가 (재발 방지)

### 중장기
- [ ] TypeORM 마이그레이션 체계(P3-2), `/auth/refresh` 스킴 완성 또는 제거(P3-3)

---

## 6. 비고
- 외부 기술트렌드 리서치는 본 분석 목적(오류·취약점 전수)과 무관해 생략.
- P0-1과 code-reviewer #1(P0-2)은 동일 근본(사이클 경과/범위 미처리)의 두 발현부.
- 코드 미수정 — 본 보고서는 읽기전용 분석. 실제 수정은 B 단계에서 사용자 승인 후 진행.

---

> 이 보고서는 Claude Code `/analyze` 스킬로 생성되었습니다.
