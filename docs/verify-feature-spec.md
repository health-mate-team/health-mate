# verify-feature 명세 (초안 v0.1)

> 본 문서는 `.claude/skills/verify-feature/SKILL.md`를 대체할 새 검증 워크플로우의 **명세 초안**이다.
> 확정 후 SKILL.md로 이관 + 인터프리터(`backend/scripts/run-cases.ts` 등) 구현.
>
> 핵심 전환:
> - **Phase 단위 하드코딩 → 검증대상 자연어 입력 + 자동 매핑**
> - **shell case 함수 → 선언적 YAML 케이스 카탈로그**
> - **수기 fixture 복사 → 단위테스트 응답 자동 캡처 → 동작테스트·contract test 공유**
> - **자유 서술형 보고 → 정형 JSON 보고서 + 회귀 diff**

---

## 0. 용어

| 용어 | 정의 |
|---|---|
| **검증대상** | 사용자가 자연어로 지정한 검증 단위. "screen / endpoint / phase / flow" 4종 중 하나로 정규화됨 |
| **케이스 카탈로그** | `docs/verify-cases/{target}.yaml`. 시나리오 + 요청 + 기대응답을 선언적으로 기술. 단일 진실의 원천 |
| **라우팅 맵** | `docs/verify-cases/_routing-map.yaml`. 자연어→정규화 대상, 화면→엔드포인트, 엔드포인트→Phase·feature 매핑표 |
| **명시 대상** | 사용자 입력으로 직접 지정된 검증대상 |
| **파급 대상** | git diff + import graph로 추론된 부수 검증 대상 |
| **Stage** | 검증 단계. STATIC / UNIT / CONTRACT / DYNAMIC 4종 |
| **Fixture artifact** | UNIT Stage에서 캡처된 실제 응답 body. `.verify-cache/{target}/{case_id}.json` |
| **검증 보고서** | `docs/verify-results/{YYYY-MM-DD}_{target}.json` (머신) + `docs/TEST_RESULTS.md` 부록(사람) |

---

## 1. 입력 → 출력 파이프라인

```
[사용자 입력 (자연어)]
        │
        ▼
DETECT ── 자연어 + git diff → 명시·파급 대상 정규화
        │
        ▼
MAP    ── 라우팅맵으로 화면·엔드포인트·Phase 결정
        │
        ▼
INSPECT ─ FE/BE 코드 + API_SPEC.md 동시 확인
        │  (명세 우위 — 코드 ≠ 명세 시 코드 FAIL 후보)
        ▼
STORYBOARD ─ 시나리오 1줄 요약 + 단계별 흐름
        │   (보고서 본문 첫 섹션이 됨)
        ▼
CASE   ── 케이스 카탈로그 작성/갱신 (YAML)
        │
        ▼
┌─ STATIC ────── tsc / dart analyze / lint
│
├─ UNIT ──────── Jest + flutter test (카탈로그 기반)
│              └ 응답 body → .verify-cache/ 캡처
│
├─ CONTRACT ──── 카탈로그 기대응답 ↔ 캡처 fixture 스키마 비교
│
└─ DYNAMIC ───── curl(test-phase 대체) + Playwright (카탈로그 인터프리트)
        │
        ▼
REPORT ── JSON 머신 보고서 + TEST_RESULTS.md 부록 + 회귀 diff
```

---

## 2. DETECT — 자연어 입력 정규화

### 2.1 입력 종류

| 형태 | 예시 | 정규화 결과 |
|---|---|---|
| 자연어 화면 | "저녁 의식 화면", "온보딩 첫 화면" | `screen:evening_ritual_page` |
| 자연어 동작 | "물 1잔 추가", "약속 확정" | `endpoint:POST /actions/water` (라우팅맵 매칭) |
| 엔드포인트 직접 | `POST /rituals/evening` | `endpoint:POST /rituals/evening` |
| Phase | `p1`, `Phase 1`, `P1 ritual 흐름` | `phase:p1` (포함된 모든 endpoint·screen 자동 전개) |
| 흐름(flow) | "온보딩→홈 진입 흐름" | `flow:onboarding_to_home` (라우팅맵 정의) |

### 2.2 매핑 실패 처리

라우팅맵에 없는 자연어 입력 → 사용자에게 후보 3개 제시(가장 가까운 화면/엔드포인트) + 선택 또는 "신규 등록" 분기.

### 2.3 git diff 통합

```
명시 대상 = 입력 정규화 결과
파급 대상 = git diff --name-only HEAD..{base}
            ─→ 변경 파일 목록
            ─→ 라우팅맵 역방향 검색 (file → endpoints/screens)
            ─→ 명시 대상과 합집합, 단 보고서엔 [명시] / [파급] 태그로 구분
```

`--no-impact` 플래그로 파급 대상 제외 (입력만 검증).

---

## 3. 라우팅 맵 (`docs/verify-cases/_routing-map.yaml`)

자연어 매핑·역참조의 단일 정의.

```yaml
# v1 — 수동 작성, 변경 시 PR로 검토
phases:
  p0:
    features: [auth, users, onboarding]
  p1:
    features: [cycle, rituals, stats]
  p2:
    features: [actions, rewards]
  p3:
    features: [workout, nutrition]

features:
  rituals:
    backend_module: backend/src/rituals
    flutter_features:
      - app/lib/features/morning_ritual
      - app/lib/features/evening_ritual
    endpoints:
      - GET /rituals/today
      - POST /rituals/morning/mood
      - POST /rituals/morning/promise
      - POST /rituals/evening
    screens:
      - morning_mood_page
      - morning_promise_page
      - evening_ritual_page

screens:
  evening_ritual_page:
    file: app/lib/features/evening_ritual/presentation/evening_ritual_page.dart
    aliases: [저녁 의식, 저녁 의식 화면, evening ritual]
    calls: [POST /rituals/evening, GET /rituals/today]

endpoints:
  POST /rituals/evening:
    backend_file: backend/src/rituals/rituals.controller.ts
    aliases: [저녁 의식 완료, evening complete]
    feature: rituals
    phase: p1

flows:
  onboarding_to_home:
    description: 게스트 가입 → 온보딩 → 홈 진입
    steps:
      - endpoint: POST /auth/register
      - endpoint: POST /onboarding/complete
      - screen: home_character_page
```

**검증 시점**: 라우팅맵에 변경된 파일이 등록 안 되어 있으면 검증 시작 시 경고 + 등록 요청.

---

## 4. INSPECT — 코드 + 명세 위치 식별

### 4.1 INSPECT의 책임 한계

INSPECT는 **위치 식별만 수행**한다. 명세 ↔ 코드 일치 검증은 LLM 판단에 맡기지 않고 CONTRACT Stage에 일임 (재현성 보장).

1. **API_SPEC.md** 해당 섹션 위치를 식별 (target → spec_section 매핑)
2. 코드 위치 식별 (BE controller/service 파일, FE DTO 파일)
3. INSPECT 산출물: `spec_section`, `backend_files[]`, `flutter_files[]` — 이후 단계에서 참조

### 4.2 명세 우위 원칙 (검증 시점)

CONTRACT Stage에서 코드 ≠ 명세 시:
- 케이스는 항상 명세 기준으로 작성됨
- 코드가 명세와 다르면 → CONTRACT FAIL → **코드 수정**이 기본 액션
- 명세가 잘못된 것이 명백하면 → 사용자에게 명세 수정 동의 요청 (검증 일시 중단)

### 4.3 화면 코드 확인의 목적

- "이 화면이 어느 엔드포인트를 호출하는가" 매핑 확인 (라우팅맵 검증)
- 입력 폼 필드명·타입 → 단위테스트 케이스의 변형(boundary) 후보 추출
- **금지**: 코드의 동작을 시나리오로 채택 → 명세 위배 silent pass 위험

---

## 5. STORYBOARD — 시나리오 명문화

### 5.1 형식

각 검증대상에 대해 **3줄 이내** 요약 + 단계별 흐름.

```
[StoryBoard: evening_ritual_page]
요약: 사용자가 약속을 확정한 뒤 저녁에 진입해 promise_kept를 선택, XP·streak가 갱신된다.

단계:
  1. 사전조건: morning/mood + morning/promise 완료 상태
  2. 사용자 액션: "약속 지킴" 버튼 탭 → POST /rituals/evening { promise_kept: true }
  3. 기대 결과: xp_earned≥60, streak +1, total_xp 갱신
  4. 분기 케이스:
     - 약속 미달성: promise_kept=false → xp_earned=10
     - 중복 호출: 같은 날 두 번째 → 400
```

### 5.2 저장

스토리보드는 케이스 카탈로그 YAML의 `storyboard:` 키로 영속화 (별도 파일 X).

---

## 6. 케이스 카탈로그 (`docs/verify-cases/{target}.yaml`)

### 6.1 스키마

```yaml
# docs/verify-cases/rituals_evening.yaml
target: endpoint:POST /rituals/evening
spec_section: docs/API_SPEC.md#4.5.4
phase: p1
feature: rituals

storyboard:
  summary: |
    약속 확정 후 저녁에 진입해 promise_kept를 선택, XP·streak이 갱신된다.
  steps:
    - 사전조건: morning/mood + morning/promise 완료
    - 액션: POST /rituals/evening { promise_kept }
    - 기대: xp_earned·streak·total_xp·level 갱신
  branches:
    - 약속 미달성 → xp_earned=10
    - 중복 호출 → 400

setup:
  user: fresh   # fresh | shared | seed:{name}
                # endpoint 단위 기본: fresh
                # flow 단위 기본: shared (flow 내부) + fresh (flow 간)
  preconditions:
    # 최대 깊이 5, 사이클 빌드 타임 에러, 동일 case_ref는 한 번만 실행(캐시)
    - case_ref: rituals_morning_mood#happy
    - case_ref: rituals_morning_promise#happy

cases:
  - id: happy_kept
    name: 약속 지킴 → xp_earned≥60
    request:
      method: POST
      path: /rituals/evening
      body: { promise_kept: true }
      auth: required
    expect:
      status: 200
      body_schema:                      # JSON Schema (Ajv on Backend, json_schema on Flutter)
        type: object
        required: [promise_kept, xp_earned, total_xp, streak, level]
        properties:
          promise_kept: { const: true }
          xp_earned:    { type: integer, minimum: 60 }
          streak:       { type: integer, minimum: 1 }
          total_xp:     { type: integer }
          level:        { type: integer, minimum: 1 }
    # capture_fixture 기본 ON. opt-out 또는 noisy 필드 마스킹.
    fixture_mask: [created_at, updated_at, saved_at]   # 선택, 시간/UUID 등 변동 필드

  - id: happy_not_kept
    name: 약속 미달성 → xp_earned=10
    request:
      method: POST
      path: /rituals/evening
      body: { promise_kept: false }
      auth: required
    expect:
      status: 200
      body_schema:
        properties:
          promise_kept: { const: false }
          xp_earned:    { const: 10 }
    setup_override:
      preconditions: [rituals_morning_mood#happy, rituals_morning_promise#happy]

  - id: error_duplicate
    name: 같은 날 중복 호출 → 400
    request:
      method: POST
      path: /rituals/evening
      body: { promise_kept: true }
      auth: required
    expect:
      status: 400
    setup_override:
      preconditions: [rituals_evening#happy_kept]

dynamic:
  ui_scenario: null   # 엔드포인트 단위는 UI 시나리오 없음

screen_targets: []    # 화면 대상일 때만 채움
```

### 6.2 화면 단위 카탈로그 추가 필드

```yaml
# docs/verify-cases/screen_evening_ritual.yaml
target: screen:evening_ritual_page

dynamic:
  ui_scenario:
    - action: navigate
      to: /evening/ritual
    - action: snapshot
      label: initial
    - action: click
      selector: '[data-test=promise-kept-yes]'
    - action: wait_for
      condition: 'response:POST /rituals/evening'
    - action: assert_network
      request: POST /rituals/evening
      expect_body: { promise_kept: true }
      expect_status: 200
    - action: assert_console
      level: error
      count: 0

screen_targets:
  - calls: [POST /rituals/evening]   # 이 화면이 호출하는 엔드포인트 카탈로그 자동 참조
```

### 6.3 카탈로그 발견 + 갱신 규칙

- 카탈로그 없음 → INSPECT + STORYBOARD 결과로 LLM이 초기 파일 생성, 사용자 검토 요청
- 카탈로그 있음 + 명세 변경 감지 → diff 표시 후 갱신 동의
- 카탈로그 있음 + 명세 동일 → 그대로 사용 (재현성 보장)

### 6.4 fixture 캡처 정책

- **기본값**: 모든 case의 응답 body를 `.verify-cache/{target}/{case_id}.json`에 자동 저장 (회귀 diff 사각지대 제거)
- **opt-out**: case 항목에 `capture_fixture: false` 명시 시 캡처 스킵
- **마스킹**: `fixture_mask: [field1, field2]` — 시간/UUID 등 변동 필드를 "<MASKED>"로 치환하여 저장. 회귀 비교 시 마스킹 필드는 무시
- **디스크 정책**: `.verify-cache/`는 .gitignore. 기준 fixture 보관이 필요한 경우 `.verify-cache/baselines/`로 명시적 복사

### 6.5 case_ref 사전조건 안전 정책

- 최대 깊이 **5**. 6 이상은 빌드 타임 에러
- **사이클 검출**: 사전조건 그래프가 DAG가 아니면 빌드 타임 에러
- **중복 실행 방지**: 동일 case_ref가 같은 검증 회차에서 여러 번 참조되면 첫 실행 결과를 캐시하여 재사용

---

## 7. Stage 정의 — 4단계 분리

### 7.1 STATIC — 정적 분석

| 대상 | 명령 | 통과 조건 |
|---|---|---|
| Backend | `npx tsc --noEmit && npx eslint src` | 0 error |
| Flutter | `dart analyze` | 0 error (info/warning 허용) |

검증대상이 BE 단독이면 Backend만, FE 단독이면 Flutter만 실행.

### 7.2 UNIT — 단위테스트 (카탈로그 인터프리트)

**Backend 인터프리터**: `backend/scripts/run-cases.ts` (신규)

```
입력: docs/verify-cases/{target}.yaml
실행:
  1. SQLite in-memory NestJS 부트
  2. setup.preconditions 순차 실행 (다른 case_ref 호출)
  3. cases[].request 송신
  4. cases[].expect.status, body_schema 검증 (Ajv 또는 zod)
  5. capture_fixture: true → .verify-cache/{target}/{case_id}.json 저장
출력:
  PASS/FAIL per case + 캡처된 fixture 경로
```

**Flutter 인터프리터**: `app/test/contract/run_cases.dart` (신규)

```
입력: .verify-cache/{target}/*.json (Backend가 캡처한 실제 응답)
실행:
  1. 해당 fixture를 fromJson에 주입
  2. DTO 필드 누락·타입 mismatch 검사
출력:
  PASS/FAIL per fixture
```

### 7.3 CONTRACT — 명세 적합성 비교

UNIT 결과의 캡처 fixture와 카탈로그 `expect.body_schema`를 다시 한번 스키마 검증 (UNIT은 SQLite in-memory, CONTRACT는 별도 분리하여 명세-fixture만 비교).

차이점:
- UNIT: 비즈니스 로직 (값 범위·streak 갱신)
- CONTRACT: **형식만** (필드 존재·타입·enum) — Flutter DTO와 동일 기준 적용
- CONTRACT FAIL은 BE-FE 양쪽 어디든 명세 위반

### 7.4 DYNAMIC — 실동작 (Docker + Playwright)

**Backend curl 흐름**: 인터프리터가 카탈로그 `cases`를 Docker `localhost:3001`로 재실행 (test-phase.sh 대체).

```
1. docker compose up -d --build backend  ← 항상 --build (gotcha #6)
2. wait_for_server
3. cases[] 순차 실행 (UNIT과 동일 케이스, 환경만 다름)
4. UNIT의 fixture와 DYNAMIC의 응답 비교 → drift 검출
```

**UI 시나리오**: 카탈로그 `dynamic.ui_scenario`를 Playwright MCP로 인터프리트.

```
action 종류:
  - navigate, click, type, fill_form, wait_for, snapshot
  - assert_network: chrome-devtools MCP로 캡처 후 expect와 비교
  - assert_console: error level 0건 확인
```

각 action은 멱등 또는 idempotency_key 명시.

### 7.5 Stage 실행 분기

| 검증대상 | STATIC | UNIT | CONTRACT | DYNAMIC |
|---|---|---|---|---|
| BE 단일 (endpoint, 명세 미변경) | ✅ | ✅ | ✅ | — |
| BE 단일 (명세 변경) | ✅ | ✅ | ✅ | ✅ |
| FE 단일 (DTO·UI 변경) | ✅ FE | — | ✅ (캡처 fixture 재활용) | ✅ UI |
| FE+BE 연동 | ✅ both | ✅ | ✅ | ✅ both |
| flow (다중 endpoint) | ✅ both | ✅ all cases | ✅ | ✅ |

**기준**: "FE인가 BE인가"가 아니라 "**명세 변경이 동반되는가 + 단일 모듈 변경인가**".

### 7.6 CI 모드

LLM 오케스트레이터(SKILL.md) 단계는 사람-구동, 인터프리터는 CI에서 단독 실행 가능.

```
조건: 카탈로그 YAML이 이미 존재 + 라우팅맵 등록 완료
명령: npx ts-node backend/scripts/run-cases.ts --target <target> --stages static,unit,contract[,dynamic]
종료 코드: 0(전체 PASS) / 1(FAIL) / 2(설정 오류 — 카탈로그 누락 등)
출력: docs/verify-results/{ISO}_{target}.json + stdout 요약
```

CI에서는 DYNAMIC을 매 PR에 돌리지 않고 main merge 시 또는 nightly로 분리 권장.

---

## 8. Fixture 자동 전파

```
UNIT Stage (Backend, SQLite)
   │
   ├─ 응답 body → .verify-cache/{target}/{case_id}.json 저장
   │
   ▼
CONTRACT Stage
   │
   ├─ Backend 측: fixture ↔ body_schema 비교
   ├─ Flutter 측: fixture → fromJson → 누락·mismatch 확인
   │
   ▼
DYNAMIC Stage (Docker)
   │
   ├─ 같은 케이스 재실행 → 응답 ↔ fixture 비교
   ├─ drift 발생 시: SQLite vs Postgres 차이 또는 dist 미동기화 의심
   │
   ▼
회귀 시
   └─ 다음 검증에서 fixture 재사용 → "이전과 동일" 빠른 패스
```

`.verify-cache/`는 `.gitignore` 추가, CI에선 매 회 새로 생성.

---

## 9. 보고서 형식

### 9.1 머신 보고서 — `docs/verify-results/{ISO}_{target}.json`

```json
{
  "schema_version": 1,
  "ran_at": "2026-05-08T10:30:00Z",
  "target": "endpoint:POST /rituals/evening",
  "explicit_targets": ["endpoint:POST /rituals/evening"],
  "impacted_targets": ["screen:evening_ritual_page"],
  "git_head": "27025ed",
  "stages": {
    "static": { "backend": "pass", "flutter": "pass" },
    "unit":   { "total": 3, "pass": 3, "fail": 0, "cases": [...] },
    "contract": { "total": 3, "pass": 3, "fail": 0 },
    "dynamic": { "total": 3, "pass": 3, "fail": 0 }
  },
  "regression": {
    "compared_to": "docs/verify-results/2026-05-07_..._.json",
    "newly_failing": [],
    "newly_passing": []
  }
}
```

### 9.2 사람 부록 — `docs/TEST_RESULTS.md` 추가 섹션

```
## 2026-05-08 — endpoint:POST /rituals/evening
- 명시 대상: POST /rituals/evening
- 파급 대상: screen:evening_ritual_page (git diff 추론)
- Stage: STATIC ✅ / UNIT 3/3 ✅ / CONTRACT 3/3 ✅ / DYNAMIC 3/3 ✅
- 회귀: ⏸ 동일 (전회 대비 변화 없음)
- 보고서: docs/verify-results/2026-05-08_rituals_evening.json
```

머신 보고서가 진실, MD는 사람용 인덱스.

### 9.3 회귀 diff

다음 검증 시작 시 직전 같은 target 보고서를 자동 비교 → newly_failing 즉시 노출.

---

## 10. 인터프리터 구현 책임 분리

| 컴포넌트 | 위치 | 역할 |
|---|---|---|
| 라우팅맵 | `docs/verify-cases/_routing-map.yaml` | 자연어→대상 매핑, 역참조 (수동 작성·PR 검토) |
| 케이스 카탈로그 | `docs/verify-cases/{target}.yaml` | 시나리오·요청·기대응답 (LLM 초안 + 사람 검토) |
| Backend 인터프리터 | `backend/scripts/run-cases.ts` | UNIT(SQLite) + DYNAMIC(curl) 실행 |
| Flutter 인터프리터 | `app/test/contract/run_cases.dart` | CONTRACT(fixture↔fromJson) 실행 |
| Playwright 어댑터 | `app/test/e2e/run_ui_scenario.ts` | DYNAMIC UI scenario 실행 |
| SKILL 오케스트레이터 | `.claude/skills/verify-feature/SKILL.md` | LLM이 DETECT→MAP→INSPECT→STORYBOARD→CASE 수행 후 인터프리터 호출 |
| 회귀 비교기 | `backend/scripts/diff-results.ts` | 직전 보고서와 자동 diff |

---

## 11. 마이그레이션 (test-phase.sh 폐기 경로)

**원칙**: **점진적 이전**. 라우팅맵·카탈로그를 한 번에 다 만들지 않고, 검증 요청이 오는 대상부터 등록한다.

| Phase | 작업 | blockedBy |
|---|---|---|
| **A** | 라우팅맵 **골격** 작성 (phases/features 4종 등록 + 검증 요청 들어온 대상부터 점진 추가). `.gitignore`에 `.verify-cache/` 추가. `docs/verify-results/` 커밋 정책 결정 (현재: 커밋 ON, 누적 시 별도 ignore 검토) | — |
| **B** | 기존 test-phase.sh의 case들을 카탈로그 YAML로 1:1 이전 (`p0_auth.yaml`, `p1_rituals.yaml` 등). 점진적 이전 — Phase A의 등록 진행과 병렬 가능 | A |
| **C** | Backend 인터프리터(`run-cases.ts`) 구현 → 기존 test-phase.sh와 결과 동등성 검증 (Phase B로 이전된 케이스로 회귀 비교) | B |
| **D** | Flutter contract 인터프리터(`run_cases.dart`) 구현 → widget_test.dart 케이스 카탈로그 기반으로 재작성. **Phase D 진입 전 화면별 위젯 test key 부착 규약** 별도 문서화 (`Key('promise-kept-yes')` 또는 `Semantics(identifier:)`) | C |
| **E** | Playwright 어댑터 구현 → 첫 화면 1건 시범 (test key 규약 적용된 화면만) | D |
| **F** | SKILL.md 갱신, test-phase.sh 폐기 (gotchas에 lesson 박제), 회귀 비교기 자동화 | E |

**라우팅맵 미등록 대상 처리 규칙**: 검증 시작 시 라우팅맵에 입력 대상이 없으면, INSPECT 결과를 토대로 **자동 추가 PR 후보**를 생성하여 사용자에게 제시 (전수 작성 강제 금지).

각 Phase는 별도 `/sh-dev-loop` 단위로 실행.

---

## 12. 결정 확정 항목 (advisor 검토 v0.1 → v0.2 반영)

| # | 항목 | 결정 |
|---|---|---|
| 1 | body_schema 표현 | **JSON Schema 채택** — Backend(Ajv) + Flutter(json_schema). API_SPEC.md는 markdown 유지 |
| 2 | fixture 캡처 정책 | **기본 ON + 마스킹 + opt-out** (6.4 참조) |
| 3 | flow setup 기본 user | **flow 내부 shared, flow 간 fresh** (6.1 setup 주석 반영) |
| 4 | 라우팅맵 v1 생성 | **수동 점진** — NestJS metadata 자동 추출은 follow-up |
| 5 | UI scenario action | **7종 유지 + 점진 추가** — 함수형 expression 금지 |

---

## 13. 비-목표 (의도적 제외)

- 부하·성능 테스트 (별도 도구)
- 보안 침투 테스트 (별도 도구)
- AI 서비스(FastAPI) 검증 (MVP 스텁이라 제외, Phase 2에서 추가)
- 시각적 회귀(스크린샷 diff): 단계 1에서 제외 — 추후 별도 stage로 추가 가능

---

**v0.1 작성: 2026-05-08**
**v0.2 갱신: 2026-05-08** — advisor 피드백 반영 (B1/B2/B3 + punt 5건 + N1/N3/N5 본문 흡수, N2/N4는 11장 Phase A·D에 작업 항목으로 포함)
**다음 단계**: 사용자 승인 → SKILL.md 이관 + 인터프리터 구현 SubTask 분리 (`/sh-dev-loop`로 Phase A→F 순차 실행)
