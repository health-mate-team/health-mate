---
name: verify-feature
description: "health-mate 프로젝트 검증 오케스트레이터. 자연어 검증대상(화면/엔드포인트/Phase/flow)을 입력받아 라우팅맵 매핑→코드·명세 위치 식별→스토리보드→YAML 케이스 카탈로그→4단계 검증(STATIC/UNIT/CONTRACT/DYNAMIC)→정형 보고서까지 수행한다. 명세 우위(API_SPEC.md = 진실의 원천), 단위테스트 응답을 fixture로 자동 캡처하여 contract test·동작테스트가 공유. 사용자가 '검증', '검증해줘', '동작 테스트', '기능 테스트', 'P0 검증', '저녁 의식 화면 검증', '잘 동작하는지 봐줘' 등을 언급하면 반드시 이 스킬을 호출한다."
argument-hint: "[자연어 대상: 화면명 / 엔드포인트 / Phase(p0..p3) / flow] [--no-impact] [--auto] [--ci]"
---

# VERIFY-FEATURE — 검증 오케스트레이터

본 스킬은 `docs/verify-feature-spec.md` (v0.2)의 LLM 오케스트레이터 영역을 실행한다.
인터프리터(`run-cases.ts`, `run_cases.dart`, `run_ui_scenario.ts`)는 별도로 호출한다.

**권위 문서**: `docs/verify-feature-spec.md` ← 본 SKILL.md와 충돌 시 명세를 우위로 따름.

```
[입력 $ARGUMENTS]
   │
   ▼
DETECT → MAP → INSPECT → STORYBOARD → CASE → STAGE 실행 → REPORT
```

---

## 옵션 플래그

| 플래그 | 설명 |
|---|---|
| (미입력) | 기본 — Stage마다 사용자 확인 |
| `--auto` | Stage 간 사용자 확인 없이 무인 진행 |
| `--no-impact` | git diff 기반 파급 대상 제외 (입력만 검증) |
| `--ci` | LLM 단계 생략, 카탈로그 기존 → 인터프리터 단독 실행 (CI 호출용) |

---

## Phase 1 — DETECT

### 1-1. 입력 정규화

`$ARGUMENTS`를 `docs/verify-cases/_routing-map.yaml`에 대조하여 정규화 대상을 결정한다.

| 입력 패턴 | 정규화 결과 |
|---|---|
| `p0`, `p1`, `p2`, `p3`, `infra` | `phase:{name}` (해당 features의 모든 endpoint·screen 전개) |
| 자연어 화면 ("저녁 의식 화면") | `screen:{name}` (aliases 매칭) |
| 엔드포인트 직접 (`POST /rituals/evening`) | `endpoint:{method+path}` |
| 자연어 동작 ("약속 확정") | endpoint aliases 매칭 |
| 흐름 ("온보딩→홈 흐름") | `flow:{name}` |
| 미지정 | `git diff --name-only` 기반 자동 추론 |

**매핑 실패 처리**: 라우팅맵에 없으면 후보 3개(편집 거리 + alias 유사도) 제시 → 사용자 선택 또는 신규 등록 PR 후보 생성.

### 1-2. git diff 기반 영향도

```bash
git diff --name-only HEAD..origin/main
```

변경 파일 → 라우팅맵 역참조 → 파급 대상 추출.

```
명시 대상  = 입력 정규화 결과
파급 대상  = git diff ∖ 명시 대상  (--no-impact 시 빈 집합)
```

DETECT 결과 출력 후 사용자 확인 (기본) 또는 자동 진행 (--auto):

```
[DETECT 결과]
명시 대상: endpoint:POST /rituals/evening
파급 대상: screen:evening_ritual_page (git diff: morning_mood_page.dart 변경 → 추론)
Stage 분기: STATIC + UNIT + CONTRACT + DYNAMIC (FE+BE 연동)
```

---

## Phase 2 — MAP

라우팅맵으로 다음을 결정:

- `spec_section` (API_SPEC.md 섹션 위치)
- `backend_files[]` (BE 컨트롤러·서비스)
- `flutter_files[]` (FE DTO·페이지)
- 화면 입력일 경우: 호출하는 endpoint 자동 추가 (transitive)
- flow 입력일 경우: steps의 모든 endpoint·screen 전개

미구현 모듈(`status: not_implemented`)은 검증 대상에서 제외하고 사용자에게 안내.

---

## Phase 3 — INSPECT

### 3-1. 책임 한계 (명세 우위)

INSPECT는 **위치 식별만 수행**. 명세 ↔ 코드 일치 검증은 LLM이 아닌 CONTRACT Stage에서 자동 비교.

수행 작업:
1. `spec_section` 위치를 API_SPEC.md에서 Read (실제 본문)
2. `backend_files[]`, `flutter_files[]` 위치 Read
3. 산출물: 단순히 "어디에 무엇이 있는지" 매핑 — 일치 판단 금지

### 3-2. 화면 입력일 때만 추가 작업

- 화면 코드 → 호출하는 endpoint 매핑이 라우팅맵의 `screens.{name}.calls`와 일치하는지 확인 (불일치 시 라우팅맵 갱신 후보)
- 입력 폼 필드 → boundary 케이스 후보 추출 (CASE 단계 보강)

---

## Phase 4 — STORYBOARD

각 명시 대상에 대해 **3줄 이내 요약 + 단계별 흐름**을 작성한다. 영속화는 카탈로그 YAML의 `storyboard:` 필드에 저장.

```
[StoryBoard: endpoint:POST /rituals/evening]
요약: 약속을 확정한 사용자가 저녁에 진입해 promise_kept를 보고, XP·streak·level이 갱신된다.
단계:
  1. 사전조건: morning/mood + morning/promise 완료
  2. 액션: POST /rituals/evening { promise_kept }
  3. 기대: xp_earned·total_xp·streak·level 갱신
분기:
  - 약속 지킴 → xp_earned=60
  - 약속 미달성 → xp_earned=10
  - 중복 호출 → 400
```

---

## Phase 5 — CASE (카탈로그 작성/갱신)

### 5-1. 카탈로그 발견

`docs/verify-cases/{target_filename}.yaml` 존재 여부 확인:

| 상태 | 동작 |
|---|---|
| 없음 | INSPECT + STORYBOARD 결과로 LLM이 초안 생성 → 사용자 검토 요청 (--auto면 자동 진행) |
| 있음 + 명세 변경 감지 | API_SPEC diff 표시 + 카탈로그 갱신 동의 (--auto면 자동 갱신, 단 갱신 사항을 보고서에 명시) |
| 있음 + 명세 동일 | 그대로 사용 (재현성 보장) |

### 5-2. 카탈로그 형식

본문은 `docs/verify-feature-spec.md` 6장 참조. 핵심 규칙:

- `body_schema`: JSON Schema (Backend Ajv, Flutter json_schema 패키지)
- `capture_fixture`: 기본 ON. 변동 필드는 `fixture_mask: [field1, ...]`로 마스킹
- `setup.preconditions`: 최대 깊이 5, DAG 강제, 동일 case_ref 캐시
- 화면 단위는 `dynamic.ui_scenario`에 action 시퀀스 (navigate/click/type/fill_form/wait_for/snapshot/assert_network/assert_console 7종)

---

## Phase 6 — STAGE 실행

### 6-1. STATIC

| 대상 | 명령 | 통과 조건 |
|---|---|---|
| Backend | `cd backend && npx tsc --noEmit && npx eslint src --ext .ts` | 0 error |
| Flutter | `cd app && dart analyze` | 0 error (info/warning 허용) |

검증대상이 BE 단독이면 Backend만, FE 단독이면 Flutter만 실행.

### 6-2. UNIT (카탈로그 인터프리트)

```bash
# Backend (SQLite in-memory NestJS)
npx ts-node backend/scripts/run-cases.ts --target {target} --stage unit
# → .verify-cache/{target}/{case_id}.json 캡처

# Flutter (캡처된 fixture → fromJson)
flutter test app/test/contract/run_cases.dart --dart-define=TARGET={target}
```

### 6-3. CONTRACT (스키마 적합성)

```bash
npx ts-node backend/scripts/run-cases.ts --target {target} --stage contract
# → .verify-cache/{target}/*.json ↔ body_schema 검증
```

UNIT의 비즈니스 검증과 분리: CONTRACT는 **형식만** (필드 존재·타입·enum·required). FE-BE 양쪽 적용.

### 6-4. DYNAMIC (Docker + Playwright)

**Backend (curl, test-phase.sh 대체)**:
```bash
docker compose up -d --build backend   # 항상 --build (gotcha #6)
until curl -s http://localhost:3001/api &>/dev/null; do sleep 2; done
npx ts-node backend/scripts/run-cases.ts --target {target} --stage dynamic
```

**UI 시나리오** (화면·flow 대상만):
- Flutter web 백그라운드 기동: `cd app && flutter run -d web-server --web-port=8080`
- Playwright MCP로 `dynamic.ui_scenario` action 시퀀스 인터프리트
- chrome-devtools MCP로 네트워크 캡처 (`assert_network` 검증)
- 두 MCP는 단일 Chromium:9222 공유 (CLAUDE.md `reference_mcp_browser_sharing.md`)

### 6-5. Stage 분기 매트릭스

| 검증대상 | STATIC | UNIT | CONTRACT | DYNAMIC |
|---|---|---|---|---|
| BE 단일, 명세 미변경 | ✅ | ✅ | ✅ | — |
| BE 단일, 명세 변경 | ✅ | ✅ | ✅ | ✅ |
| FE 단일 (DTO·UI) | ✅ FE | — | ✅ (캡처 fixture 재활용) | ✅ UI |
| FE+BE 연동 | ✅ both | ✅ | ✅ | ✅ both |
| flow | ✅ both | ✅ all | ✅ | ✅ |

기준: "FE인가 BE인가"가 아니라 "**명세 변경 여부 + 단일 모듈 변경 여부**".

### 6-6. 인터럽트 시 처리

- STATIC FAIL → 즉시 보고 + 수정 후 재실행 (Backend 오류 즉시 수정, Frontend는 기록)
- UNIT FAIL → 케이스 단위 보고 + 사용자 결정
- CONTRACT FAIL → 코드가 명세를 위반 → **코드 수정 기본** (명세가 잘못된 경우만 명세 수정 동의 후 진행)
- DYNAMIC FAIL → SQLite vs Postgres 차이 또는 dist 미동기화(gotcha #6) 의심 → `--build` 재실행

---

## Phase 7 — REPORT

### 7-1. 머신 보고서

`docs/verify-results/{ISO}_{target_safe}.json` 작성. 포맷은 명세 9.1 참조.

### 7-2. 사람 부록

`docs/TEST_RESULTS.md`에 1줄 요약 + 보고서 경로 추가.

### 7-3. 회귀 비교

직전 같은 target 보고서와 자동 diff:
```bash
npx ts-node backend/scripts/diff-results.ts --target {target}
```
`newly_failing`이 있으면 보고서 상단에 강조.

---

## CI 모드 (`--ci`)

LLM 단계(DETECT~CASE) 생략, 카탈로그가 이미 존재해야 함:
```bash
npx ts-node backend/scripts/run-cases.ts \
  --target {target} \
  --stages static,unit,contract \
  --ci
```
종료 코드: 0(전체 PASS) / 1(FAIL) / 2(설정 오류).
DYNAMIC은 main merge 또는 nightly로 분리 권장.

---

## 부속 문서

- **명세**: `docs/verify-feature-spec.md` (v0.2) — 권위 문서
- **라우팅맵**: `docs/verify-cases/_routing-map.yaml`
- **카탈로그**: `docs/verify-cases/{target}.yaml` (점진 등록)
- **함정**: `gotchas.md` (자동 누적, Stop hook)
- **선례**: `knowledge.md` (수동 누적)

---

## 마이그레이션 진행도

| Phase | 작업 | 상태 |
|---|---|---|
| A | 라우팅맵 v1 골격 + .gitignore + 결과 디렉토리 정책 | ✅ (2026-05-08) |
| B | test-phase.sh 케이스를 카탈로그 YAML로 이전 | ⏳ (시범 1건 완료: rituals_evening) |
| C | Backend 인터프리터(`run-cases.ts`) 구현 | ⏳ |
| D | Flutter contract 인터프리터 + 위젯 test key 부착 규약 | ⏳ |
| E | Playwright 어댑터 (`run_ui_scenario.ts`) | ⏳ |
| F | test-phase.sh 폐기 + 회귀 비교기 자동화 | ⏳ |

각 Phase는 별도 `/sh-dev-loop`로 실행. 의존 그래프 A→B→C→D→E→F.

---

## 종료 처리

- Flutter web 백그라운드 종료
- Playwright MCP 페이지 닫기 (`browser_close`)
- 결과 요약 + 다음 액션 가이드

응답 마지막에 반드시 `---DONE---` 블록 포함.
