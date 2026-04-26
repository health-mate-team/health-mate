# 오우너 펨테크 MVP 플랜 — 마스터 인덱스

> **8주 안에 펨테크 운동 앱이 진짜로 작동하는지 검증하는 MVP 마스터 플랜**

이 폴더는 오우너의 펨테크 정체성 전환에 따른 MVP 마스터 플랜입니다. **사람이 보는 시각 자료(`_VISUAL_OVERVIEW.pdf`)와 에이전트가 작업할 때 참조하는 구조화 명세(JSON 모듈들)가 같은 정보를 두 형태로 담고 있습니다.**

---

## 핵심 한 줄

오우너는 **호르몬 주기에 맞춰 운동하는 한국 첫 펨테크 운동 앱**입니다. MVP의 미션은 **"펨테크 앱이 진짜로 작동하는가"**를 측정 가능하게 검증하는 것입니다.

**합격 조건**: 4주 베타 후 사용자의 70%가 "내 사이클을 더 잘 이해하게 됐다"고 답하고, 40%가 주 3회 이상 추천 운동을 완료해야 합니다.

---

## 폴더 구조

```
docs/planning/owner-femtech-mvp/
├── _VISUAL_OVERVIEW.pdf       ← 사람용. 한 장에 큰 그림.
├── 00_OVERVIEW.md             ← 이 문서. 전체 인덱스.
├── AGENT_GUIDE.md             ← 에이전트가 이 문서들을 어떻게 활용하는지
│
├── 01_HYPOTHESES.json         ← 검증할 4개 가설 + 합격 기준
├── 02_CYCLE_OS.json           ← 28일 사이클 운영체제 데이터 모델
├── 03_WORKOUT_MATRIX.json     ← 4단계 × 5분 운동 매트릭스
├── 04_SUCCESS_METRICS.json    ← KPI 정의 + 측정 방법
├── 05_TIMELINE.json           ← 8주 주차별 마일스톤
└── 06_RISKS.json              ← 8개 리스크 + 대응 방안
```

---

## 모듈 가이드

### 01_HYPOTHESES.json — "무엇을 검증하는가"

MVP가 검증할 4개 가설. 각 가설마다 합격 기준이 정의되어 있습니다.

- **H1 (P0, 가장 위험)** — 사용자가 자기 사이클을 이해하게 된다 (목표 70%)
- **H2 (P0)** — 추천이 실제 행동으로 이어진다 (주 3회+ 40%)
- **H3 (P1)** — D7 30%+, D30 20%+ 리텐션
- **H4 (P1)** — 자기 돌봄 향상 60%+, NPS 50+

베타 종료 후 의사결정 매트릭스도 포함. **이 합격선을 못 넘으면 출시하지 않습니다.**

### 02_CYCLE_OS.json — "앱이 어떻게 작동하는가"

오우너의 운영체제. 28일 호르몬 주기 4단계와 각 단계의 운동·식사·휴식·메시지 톤을 데이터 모델로 정의.

- **데이터 모델**: user_cycle_input + computed_state
- **4단계**: menstrual / follicular / ovulatory / luteal (황체기는 sub_phases로 전반·후반 구분)
- **단계별 명세**: hormone_state, recommendation_profile, moa_messaging_tone, moa_visual_state
- **계산 로직**: phase_assignment_algorithm + recommendation_engine_priority
- **시각 인디케이터**: 어느 화면 어느 위치에 사이클 정보를 표시할지

이 모듈이 가장 중요. **모든 추천 로직의 SOURCE OF TRUTH**.

### 03_WORKOUT_MATRIX.json — "어떤 콘텐츠를 만드는가"

MVP에 필요한 운동 콘텐츠 명세. 4단계 × 5종류 = 20개 영상.

- **production_targets**: MVP v1.0 최소량 + v1.1 확장 계획
- **matrix**: 5종류 운동 × 4단계 매핑. 각 칸에 priority, duration, title, moves 정의
- **production_priority_order**: 4그룹으로 우선순위. 1순위 6개 영상부터 제작
- **production_pipeline**: 13일에 300-400만원 예상
- **fallback_for_no_video**: 영상 지연 시 일러스트 + 타이머만으로 시작 가능

### 04_SUCCESS_METRICS.json — "어떻게 측정하는가"

01_HYPOTHESES의 가설을 데이터로 평가하기 위한 측정 지표.

- **5개 Primary KPI** (KPI_01 ~ KPI_05): 합격 게이트
- **4개 Secondary Observations**: 추세 관찰용
- **정성 신호**: red flags + green flags
- **분석 이벤트 명세**: 6개 이벤트의 필드 정의 (Flutter 구현 시 참조)
- **데이터 저장 원칙**: 민감 데이터는 로컬 우선, 익명화 필수
- **합격/미달 의사결정 프로토콜**

### 05_TIMELINE.json — "언제 무엇을 하는가"

8주 마일스톤 + 베타 4주.

- **W1-2**: 사이클 OS + 추천 엔진 구현
- **W3-4**: 13개 화면 UI 구현
- **W5**: 운동 영상 일괄 촬영 (병렬 작업)
- **W6**: QA + 5명 알파 테스트
- **W7-8**: 50명 베타 시작 + 데이터 수집
- **W9-12**: 베타 4주 완주 + 분석 + 출시 결정

리스크 버퍼와 비디오 지연 시 fallback 명시.

### 06_RISKS.json — "무엇이 잘못될 수 있는가"

8개 리스크를 likelihood × impact로 점수화.

- **Critical (즉시 행동)**: R02 불규칙 사용자, R03 데이터 보안
- **Manage (적극 대응)**: R01 의료법, R04 5분 부담, R07 캐릭터 메시지, R08 팀 합의, R05 베타 모집, R06 영상 지연

각 리스크마다 early_signals(미리 알아챌 신호)와 mitigations(예방·대응 액션)이 정의됨.

---

## 의존성 그래프

```
01_HYPOTHESES (검증 목표)
    ↓
02_CYCLE_OS (코어 운영체제)
    ↓
03_WORKOUT_MATRIX (콘텐츠) ─→ 04_SUCCESS_METRICS (측정)
    ↓                              ↓
05_TIMELINE (실행) ←─────────────→ 06_RISKS (대응)
```

**작업 순서**: 02 → 03 → 04 → 05 → 06 순으로 검토하면 자연스럽게 흐름이 맞춰집니다.

---

## 기존 산출물과의 연결

이 MVP 플랜은 기존 작업물 위에 얹는 한 축입니다. **버려지는 것은 없고, 통합됩니다**:

- **`docs/design/owner-mock-develop/`**, **`docs/design/owner-mock/`** — 화면 JSON·디자인 룰. CYCLE_OS 데이터를 바인딩만 추가. 화면 13(`13_cycle_calendar.json`)은 신규 추가.
- **`docs/design/owner-mock-develop/01_DESIGN_RULES.md`** — 5원칙 그대로. 모아 메시지 톤은 02_CYCLE_OS의 phases.moa_messaging_tone에 의해 단계별 분기.
- **`app/lib/core/theme/owner/`** — Flutter 토큰 v1.1 구현. 사이클 단계별 색상은 토큰에서 차용.
- **게이미피케이션·피벗 메모(docx 등)** — 저장소에 없으면 팀 문서함 기준; 필요 시 `docs/`로 편입.

---

## 의사결정 우선순위

여러 자료가 충돌하면 다음 순서로 우선합니다:

1. **01_HYPOTHESES** — 검증 목표가 모든 결정의 근거
2. **02_CYCLE_OS** — 모든 사용자 행동의 코어 로직
3. **04_SUCCESS_METRICS** — 측정 가능성을 깰 수 없음
4. **03_WORKOUT_MATRIX**, **05_TIMELINE**, **06_RISKS** — 동등 우선순위
5. **기존 목업·토큰 산출물** (`docs/design/owner-mock*`, `app/lib/core/theme/owner/`) — 위와 충돌하면 **`docs/planning/owner-femtech-mvp/`**(본 기획) 우선

---

## 다음 액션 (W1 시작 시)

1. 팀 전체에 `_VISUAL_OVERVIEW.pdf` 공유 + 30분 회의로 합의 확인
2. `02_CYCLE_OS.json`의 데이터 모델을 Flutter 코드로 구현 시작
3. `06_RISKS.json`의 critical 리스크 (R02, R03)에 대한 W1 mitigation 즉시 착수
4. 매주 금요일 30분 weekly_checkpoint (05_TIMELINE 기반)

---

*최종 수정: 2026.04.25 — 문서 변경 시 버전 업 + 변경 사유 기록 권장*
