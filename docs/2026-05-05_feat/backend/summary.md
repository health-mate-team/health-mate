# Feat Summary (백엔드) — `2026-05-05`

> 상대 문서: [../app/summary.md](../app/summary.md)

## 1. 한 줄 요약

없음 — 백엔드 변경 없음. 다만 **앱이 오늘부터 `survey_response` 이벤트를 실제로 송신하기 시작**(D0/D14/D28 자동 트리거). 베타 시작 D-7 이전에 분석 이벤트 수집 API가 살아있어야 KPI_01/04/05 집계가 가능. 앱 §5 에 4건의 명시 응답 요청 전달됨.

---

## 2. 범위 & 산출물

| 구분 | 내용 |
|------|------|
| **관련 브랜치/이슈** | 없음 |
| **변경 영역** | `backend` — 변경 없음 |
| **주요 파일·경로** | 없음 |

---

## 3. 상세 작업 내용

### 3.1 구현

없음.

### 3.2 의사결정 & 추론

없음.

### 3.3 설계·확장 포인트

- **분석 이벤트 수집 API** (이전 일자부터 누적, 오늘 §5 에서 추가 4건 명시 응답 요청):
  1. `survey_response.response_value` 타입 — string 통일 + `kind` 메타 동반 권장.
  2. freeText 응답의 PII 검출 필터 — 서버 단 vs 클라이언트 단 책임 결정.
  3. `survey_id` enum 표기 통일 (`baseline_d0/pulse_d14/final_d28`).
  4. 이벤트 schema 에 `kind` 필드 추가 여부.
- **베타 코호트 윈도우 처리** — D28+ 응답을 KPI 집계 제외하는 ETL 정책. `is_within_window` 플래그.
- **`cycle_inputs` 미저장 정책의 CI 자동 검사** — 키워드 grep PR fail.

---

## 4. 검증

- [ ] `npm run test` — 변경 없음.
- [ ] 수동 시나리오 — 변경 없음.

---

## 5. 상대(앱)에게 전달·요청

- 없음 — 백엔드 변경 없음.

### 5.1 공통 / 기타

- 앱 §5.1 의 4건 명시 응답은 다음 백엔드 작업 시작 시점에 다음 형태로 답변 예정:
  1. **`response_value` 타입**: `string` 통일 권장 — 클라이언트가 `kind` 와 함께 보내면 ETL 에서 안전하게 캐스팅.
  2. **PII 필터**: 1차 클라이언트 단 안내(제출 전 다이얼로그) + 2차 서버 단 정규식 필터(휴대폰·이메일·주민등록 패턴) 이중. 자유 응답은 별도 sensitive 컬럼에 분리 저장.
  3. **`survey_id` enum**: 동일 표기 채택.
  4. **`kind` 필드**: 추가 채택 — 백엔드가 추론하는 비용 < 클라이언트가 한 필드 더 보내는 비용.
- 베타 코호트 윈도우(§5.2) 정책: `is_within_window` 플래그 ETL 단계에서 계산 (서버 timestamp 기준). 클라이언트는 트리거 차단 + 서버는 저장만.
- `cycle_inputs` CI 검사(§5.3): GitHub Actions `schema-policy-check` job 추가 예정.
- 베타 D-7 이전 마감 필요. 일정 지연 시 즉시 회신.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 분석 이벤트 명세 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` |
| 데이터 저장 원칙 | 위 파일의 `data_storage_principles` 섹션 |
| 리스크 (R03) | `docs/planning/owner-femtech-mvp/06_RISKS.json` |
| 측정 윈도우 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` `measurement_window` |
| 직전 일자 백엔드 문서 | `docs/2026-05-04_feat/backend/summary.md` |

---

## 7. 다음 액션 (우선순위)

1. **분석 이벤트 수집 엔드포인트** (`POST /v1/analytics/events:batch`) DTO 초안 — 앱 §5.1 의 4건 결정 사항 반영(string + kind + survey_id enum + PII 분리).
2. **`is_within_window` ETL 플래그** — 베타 코호트 D28 컷오프 자동 처리.
3. **`cycle_inputs` 미저장 CI 검사** — schema-policy-check job + PR 템플릿 체크박스.
4. 사용자 프로필·온보딩·무드·오늘의 약속·스트릭/XP·스탯 API 초안 (이전 일자부터 잔여).
5. 운동 콘텐츠 메타데이터 API (`GET /v1/workouts`) — Phase 2.
6. 사내 분석 대시보드 (`GET /v1/internal/recommendation-stats`) — 베타 후.

---

*템플릿: `feat_summary_template_backend.md` v1.0*
