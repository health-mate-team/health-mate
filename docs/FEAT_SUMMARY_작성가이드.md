# Feat Summary 작성 가이드 (앱 · 백엔드 분리)

앱·백엔드가 **각자 자기 문서만 수정**하고, 마감 전에 **상대 문서를 읽는** 방식으로 충돌을 줄입니다.  
Cursor 에이전트는 `.cursor/rules/docs-feat-summary.mdc`를 따릅니다.

---

## 1. 왜 쓰는가

- 같은 저장소에서 **동시에 한 `summary.md`를 고치면** Git 충돌·누락이 나기 쉽다.
- **역할별 파일**로 나누면 작성은 독립적이고, **§5(상대에게 전달)**로 협업 포인트만 오간다.

---

## 2. 폴더 구조 (고정)

```
docs/
├── YYYY-MM-DD_feat/
│   ├── README.md          ← 선택: app/backend 링크 (권장)
│   ├── app/
│   │   └── summary.md     ← Flutter 담당만 수정
│   └── backend/
│       └── summary.md     ← NestJS 담당만 수정
└── _templates/
    ├── feat_summary_template_app.md
    └── feat_summary_template_backend.md
```

| 항목 | 규칙 |
|------|------|
| **날짜** | 문서 **마감일** 로컬 `YYYY-MM-DD` |
| **템플릿** | 앱 → `feat_summary_template_app.md`, 백엔드 → `feat_summary_template_backend.md` |
| **상대 확인** | 마감 전 **반드시** 상대 폴더의 `summary.md`를 읽고, 필요하면 **자기 §5**에 회신·요청 추가 |

---

## 3. 작성 순서 (체크리스트)

1. `docs/YYYY-MM-DD_feat/app/` 및 `backend/` 디렉터리 생성
2. (권장) `README.md`에 두 파일 링크
3. 해당 역할 템플릿을 복사해 `summary.md`로 저장
4. 제목의 날짜 치환 후 섹션 순서대로 작성
5. **상대 `summary.md` 읽기** → 건너뛸 요청이 있으면 **내 §5에** 반영

---

## 4. 섹션별 요령 (공통)

### 4.1 한 줄 요약 · 4.2 범위

- **자기 역할 관점**만 적는다 (앱 문서에 백엔드 구현 상세를 길게 쓰지 않아도 됨 — 요청은 §5로).

### 4.3 상세 (3.1~3.3)

- 구현 / 의사결정 / 확장 — 기존과 동일.

### 4.4 검증

- 앱: `flutter analyze` 등 / 백엔드: `npm test` 등.

### 4.5 §5 — **이 문서의 협업 허브**

| 파일 | §5 제목 | 적는 내용 |
|------|---------|-----------|
| `app/summary.md` | **상대(백엔드)에게 전달·요청** | 필요한 API, 필드, 에러 코드, 정책 질문 |
| `backend/summary.md` | **상대(앱)에게 전달·요청** | 확정된 경로·DTO, breaking change, 마이그레이션 안내 |

- **없으면** `없음 — (이유)` 한 줄.
- **공통** 이슈(기획·보안)는 각자 §5.1 또는 한쪽에만 적고 상대 README에서 링크해도 됨.

### 4.6 참고 · 4.7 다음 액션

- 기존과 동일.

---

## 5. 백엔드 개발자

- API·DB 변경은 **자기 `backend/summary.md`**의 §3에, 앱이 알아야 할 계약은 **§5**에.
- 앱이 §5에 질문을 남겼으면, **회신은 백엔드 §5 또는 다음 날 문서**에 명시.

---

## 6. 앱 개발자

- 화면·명세 경로는 **자기 `app/summary.md`**에.
- 백엔드에 필요한 것은 **§5에만** 구체적으로 (한 파일에 앱·백 요청이 섞이지 않음).

---

## 7. 품질 기준 (자가 점검)

- [ ] 오늘자 **`app/summary.md`와 `backend/summary.md` 둘 다** 존재하는가 (한쪽만 작업한 날은 “없음”이라도 파일 생성 권장)
- [ ] 마감 전 **상대 문서를 읽었는가**
- [ ] 자기 §5가 비어 있지 않은가 (없음 사유라도)
- [ ] 민감 정보 없음

---

## 8. 관련 파일

| 파일 | 역할 |
|------|------|
| `docs/_templates/feat_summary_template_app.md` | 앱용 |
| `docs/_templates/feat_summary_template_backend.md` | 백엔드용 |
| `docs/_templates/feat_summary_template.md` | 템플릿 인덱스(분기 안내) |
| `.cursor/rules/docs-feat-summary.mdc` | Cursor 규칙 |

---

## 9. 권장 Git·문서 리듬

| 할 일 | 권장 |
|--------|------|
| **커밋** | 논리 단위마다, 퇴근 전 push |
| **Feat Summary** | 하루 1회 또는 PR 직전 — **자기 역할 파일** 갱신 |
| **PR** | 본문에 `docs/YYYY-MM-DD_feat/app/summary.md` · `…/backend/summary.md` 링크 |

---

*가이드 버전: 2.0 — 앱/백엔드 문서 분리*
