# 에이전트 활용 가이드

> 이 문서는 AI 에이전트가 `docs/planning/owner-femtech-mvp/` 폴더를 어떻게 읽고 활용해야 하는지 정의합니다.

---

## 핵심 원칙

이 폴더는 **에이전트가 매번 작업할 때 참조하는 SOURCE OF TRUTH**입니다. 한 번 읽고 끝이 아니라, 코드를 짜거나 디자인을 결정할 때마다 다시 봅니다.

**모든 새 코드/디자인 작업은 이 질문으로 시작합니다:**

> "이 작업이 `01_HYPOTHESES`의 어떤 가설 검증에 기여하는가?"

기여하지 않으면 MVP에 넣지 않습니다.

---

## 작업 종류별 참조 모듈

### Flutter 코드 작성 시

**필수 참조**:
- `02_CYCLE_OS.json` — 데이터 모델, 추천 엔진 로직
- `04_SUCCESS_METRICS.json` — 분석 이벤트 송신 (events_required_in_app)
- `06_RISKS.json` (R02, R03) — 불규칙 사용자 처리 + 데이터 보안

**작업 패턴**:
```
1. view 02_CYCLE_OS.json
2. data_model + computation_logic 섹션 확인
3. 코드 작성
4. view 04_SUCCESS_METRICS.json
5. analytics_implementation.events_required_in_app에서 해당 이벤트 송신 추가
```

### 화면 디자인 / Flutter UI 구현 시

**필수 참조**:
- `02_CYCLE_OS.json` — visual_indicators (어디에 사이클 정보 표시?)
- `02_CYCLE_OS.json` — phases[*].moa_visual_state (모아 표정/장식)
- `docs/design/owner-mock-develop/01_DESIGN_RULES.md` — 디자인 5원칙
- `docs/design/owner-mock-develop/` · `docs/design/owner-mock/` 내 `{XX}_{name}.json` — 해당 화면 기존 명세

**작업 패턴**:
```
1. view docs/design/owner-mock-develop/ 또는 docs/design/owner-mock/{대상화면}.json (기존 명세)
2. view 02_CYCLE_OS.json visual_indicators 섹션
3. 사이클 정보 통합 방법 결정
4. 디자인/구현 작업
```

### 콘텐츠 작성 시 (모아 메시지, 운동 타이틀)

**필수 참조**:
- `02_CYCLE_OS.json` — phases[*].moa_messaging_tone (단계별 톤 + 예시 + 금지어)
- `06_RISKS.json` (R01) — 의료 키워드 차단 리스트
- `06_RISKS.json` (R07) — 단계별 인과 설명 명시 필요

**작업 패턴**:
```
1. view 02_CYCLE_OS.json
2. 작성할 메시지의 단계 결정 (4개 중 하나)
3. 해당 단계의 moa_messaging_tone.examples 형식 따름
4. moa_messaging_tone.avoid 단어 회피
5. R01 의료 키워드 차단 리스트 점검: 진단/치료/처방/약/질환/병
```

### 콘텐츠 제작 (운동 영상) 시

**필수 참조**:
- `03_WORKOUT_MATRIX.json` — matrix 전체
- `03_WORKOUT_MATRIX.json` — production_priority_order (어떤 순서로 제작?)
- `03_WORKOUT_MATRIX.json` — production_pipeline (제작 절차)

**작업 패턴**:
```
1. view 03_WORKOUT_MATRIX.json
2. priority 1 그룹 6개 영상부터 제작
3. 각 영상의 phase + workout_type 조합에서 moves 리스트 확인
4. 영상 길이 = duration_seconds 정확히 준수
```

### 분석 / 데이터 작업 시

**필수 참조**:
- `04_SUCCESS_METRICS.json` — 전체
- `01_HYPOTHESES.json` — 어떤 가설과 연결되는지

**작업 패턴**:
```
1. view 04_SUCCESS_METRICS.json
2. primary_kpis에서 해당 지표 정의 확인
3. measurement_method 정확히 따름 (계산식, 임계값)
4. analytics_implementation.events_required_in_app 이벤트 송신 검증
```

### 베타 운영 / 사용자 케어 시

**필수 참조**:
- `05_TIMELINE.json` — 현재 주차에 해야 할 일
- `04_SUCCESS_METRICS.json` — qualitative_signals (red/green flags)
- `06_RISKS.json` — early_signals (위험 발현 신호)

---

## 의사결정 충돌 시

여러 모듈이 다른 방향을 가리키면 우선순위:

1. **`01_HYPOTHESES`** — 검증 목표가 깨지는 결정은 무효
2. **`02_CYCLE_OS`** — 운영체제를 깨면 모든 추천이 비일관
3. **`04_SUCCESS_METRICS`** — 측정 불가능한 변경은 무효
4. **`03_WORKOUT_MATRIX`** / **`05_TIMELINE`** / **`06_RISKS`** — 동등
5. **`docs/design/owner-mock*`** 기존 화면·룰 산출물 — 위와 충돌 시 `docs/planning/owner-femtech-mvp/`(본 기획) 우선

---

## 모듈 변경 시 영향 분석

각 모듈의 끝에 `depends_on` (의존하는 모듈)과 `depended_by` (의존 받는 모듈)이 명시되어 있습니다.

**변경 절차**:
1. 변경할 모듈 확인
2. 그 모듈의 `depended_by` 리스트 확인
3. 의존 받는 모듈들의 영향 범위 확인 → 함께 업데이트 필요한지 판단
4. 변경 시 `version` 번호 올림 + `00_OVERVIEW.md` 업데이트 일자 갱신

**예시**:
- `02_CYCLE_OS`의 phases 추가 시 → `03_WORKOUT_MATRIX`의 matrix도 업데이트 필요
- `01_HYPOTHESES`의 합격 기준 변경 시 → `04_SUCCESS_METRICS`의 pass_threshold도 함께

---

## 자주 일어나는 실수 방지

### 실수 1 — "캐릭터가 우선이니까…"
**잘못된 사고**: "모아가 귀엽게 나오면 됐어"
**올바른 사고**: "모아의 메시지가 02_CYCLE_OS의 사이클 인식을 표현하는가?"

캐릭터는 펨테크 가치 전달의 매개체입니다. 단독으로 평가되지 않습니다.

### 실수 2 — "5분이 너무 짧으니까 7분으로…"
**잘못된 사고**: "콘텐츠가 더 풍부하면 좋을 거야"
**올바른 사고**: "5분은 R04 리스크 대응에서 확정된 결정. 7분이면 시간 부족 페인포인트 정조준이 흔들림"

핵심 결정은 모듈에 명시되어 있습니다. 변경 시 영향 분석 필수.

### 실수 3 — "데이터를 서버에 다 저장하자"
**잘못된 사고**: "분석하기 편하잖아"
**올바른 사고**: "R03 critical 리스크. 02_CYCLE_OS의 ux_principles.consent + 04_SUCCESS_METRICS의 data_storage_principles 위반"

민감 데이터는 디바이스 우선. 서버는 익명화된 통계만.

### 실수 4 — "사용자가 추천 안 따라가니까 강제하자"
**잘못된 사고**: "리텐션 올려야 하니까"
**올바른 사고**: "02_CYCLE_OS의 ux_principles.flexibility 위반. 강요 X. 다른 옵션 제시."

H4 (자기 돌봄 향상)와 정면 충돌하는 결정은 자동 무효.

---

## 새 작업 시작 시 체크리스트

```markdown
- [ ] 작업의 목적이 H1~H4 중 어느 가설과 연결되는가?
- [ ] 02_CYCLE_OS의 어떤 단계/필드와 관련 있는가?
- [ ] 06_RISKS의 어떤 리스크와 관련 있는가?
- [ ] 측정 가능한가? (04_SUCCESS_METRICS의 어떤 KPI?)
- [ ] 05_TIMELINE의 현재 주차에 적합한 작업인가?
```

5개 모두 답할 수 있으면 진행. 답할 수 없으면 작업 보류 + 사람과 합의.

---

## 핵심 진실 한 줄

> **펨테크 + 건강 앱이 진짜로 작동해야 한다는 압박이 본질입니다. 캐릭터는 외피, 펨테크 가치 전달이 본질입니다.**

이 문장이 충돌 시 최종 판단 기준입니다.
