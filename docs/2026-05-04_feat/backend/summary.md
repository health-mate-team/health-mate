# Feat Summary (백엔드) — `2026-05-04`

> 상대 문서: [../app/summary.md](../app/summary.md)

## 1. 한 줄 요약

없음 — 백엔드 변경 없음. 앱이 사이클 OS 확산 + audio_guide TTS + 추천 엔진 goal 가중치를 추가했고, **베타 D-7 이전에 마감해야 할 분석 이벤트 수집 API 스펙 합의 요청**이 §5 로 전달됨 (앱 §5.1 의 6개 이벤트 + 익명화 정책).

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

- **분석 이벤트 수집 API**(`POST /v1/analytics/events:batch`) — 앱 §5.1 의 6개 이벤트를 그대로 받기. 04_SUCCESS_METRICS.json `analytics_implementation` 이 SOURCE OF TRUTH.
- **사이클 데이터(생리일·증상)는 서버 저장 절대 금지** — 06_RISKS R03 critical. 스키마 설계 단계부터 컬럼 자체가 없어야 함. PR 리뷰어가 정책 차원에서 차단.
- **운동 콘텐츠 메타데이터 API**(`GET /v1/workouts`) — Phase 2 (영상 촬영 후 v1.1) 시작 시 합의 필요.
- **Goal 가중치 캘리브레이션 데이터 제공**(`GET /v1/internal/recommendation-stats`) — 베타 4주 후 사내 대시보드용.

---

## 4. 검증

- [ ] `npm run test` — 변경 없음.
- [ ] 수동 시나리오 — 변경 없음.

---

## 5. 상대(앱)에게 전달·요청

- 없음 — 백엔드 변경 없음.

### 5.1 공통 / 기타

- 앱 §5.1 의 분석 이벤트 수집 API 스펙은 다음 백엔드 작업 시작 시점에 다음 순서로 답변 예정:
  1. 엔드포인트 경로·요청/응답 DTO 확정 → 앱이 dio retrofit 클라이언트 스텁 생성.
  2. 익명화 정책 문서화 (`docs/policy/data_anonymization.md` 등).
  3. `cycle_inputs` 미저장 정책을 백엔드 PR 템플릿에 명시.
- 베타 D-7 이전 마감 필요. 마스터플랜 `05_TIMELINE.json` W3-W4 에 정렬.
- 앱이 보내는 `phase` enum 표기는 영문 단순 형태 (`menstrual / follicular / ovulatory / luteal`). 백엔드 enum 도 동일 표기로 통일.

---

## 6. 참고 링크 & 경로

| 유형 | 경로 |
|------|------|
| 분석 이벤트 명세 | `docs/planning/owner-femtech-mvp/04_SUCCESS_METRICS.json` |
| 데이터 저장 원칙 | 위 파일의 `data_storage_principles` 섹션 |
| 리스크 (R03) | `docs/planning/owner-femtech-mvp/06_RISKS.json` |
| 마스터 타임라인 | `docs/planning/owner-femtech-mvp/05_TIMELINE.json` |
| 직전 일자 백엔드 문서 | `docs/2026-05-03_feat/backend/summary.md` |

---

## 7. 다음 액션 (우선순위)

1. 분석 이벤트 수집 엔드포인트 (`POST /v1/analytics/events:batch`) DTO 초안 — `client_event_id` 기반 idempotency + `device_user_hash` 검증.
2. 사이클 데이터 미저장 정책을 백엔드 PR 템플릿·CI 검사 (스키마 grep) 로 강제.
3. 사용자 프로필·온보딩·무드·오늘의 약속·스트릭/XP·스탯 API 초안 (이전 일자부터 잔여 요청).
4. 운동 콘텐츠 메타데이터 API (`GET /v1/workouts`) — Phase 2 시작 시.
5. 사내 분석 대시보드 (`GET /v1/internal/recommendation-stats`) — 베타 후.

---

*템플릿: `feat_summary_template_backend.md` v1.0*
