# Claude Code 운영 규칙: health-mate

> 전역 공통 규칙은 `~/.claude/CLAUDE.md`를 따른다.
> 이 파일은 프로젝트 고유 내용만 기술한다.

---

## 🛠️ 기술 스택 (고정값 — 변경 금지)

| 영역 | 스택 |
|---|---|
| 모바일 | Flutter 3.41 + Dart 3.10 |
| 상태 관리 | Riverpod 3.0 (flutter_riverpod) |
| 로컬 DB | Drift (SQLite ORM) |
| 차트 | fl_chart |
| 건강 데이터 | health v13 (iOS+Android 통합) |
| 인앱 결제 | purchases_flutter (RevenueCat) |
| 메인 API | NestJS + TypeScript |
| AI 서비스 | FastAPI + Python (MVP: 스텁) |
| DB | PostgreSQL 16 |
| 캐시 | Redis 7 |
| 컨테이너 | Docker Compose |

---

## 📁 프로젝트 핵심 구조

```
health-mate/
├── app/                    # Flutter 앱
│   └── lib/
│       ├── core/           # DI, Router, Theme (전역)
│       ├── features/       # Feature-First 모듈
│       │   ├── auth/
│       │   ├── dashboard/
│       │   ├── workout/
│       │   ├── nutrition/
│       │   ├── body_record/
│       │   ├── wearable/   # Phase 2
│       │   └── subscription/
│       └── shared/         # 공통 위젯/유틸/상수
├── backend/                # NestJS API (포트 3000)
│   └── src/
├── ai-service/             # FastAPI (포트 8000, MVP: 스텁)
│   └── app/
└── docker-compose.yml
```

---

## 📐 핵심 구현 원칙

### Flutter
- **Feature-First**: 모든 코드는 `features/{feature}/` 하위에 `data/`, `domain/`, `presentation/` 3계층으로 분리
- **Riverpod 패턴**: `@riverpod` 어노테이션 사용, `AsyncNotifier`로 비동기 상태 관리
- **오프라인 퍼스트**: 모든 사용자 입력은 Drift 로컬 DB에 먼저 저장 (`isSynced: false`), `workmanager`로 백그라운드 동기화
- **코드 생성**: `*.g.dart`, `*.freezed.dart`는 `flutter pub run build_runner build`로 생성 — 직접 편집 금지

### NestJS
- **모듈 단위 개발**: 각 기능은 독립 모듈 (`auth/`, `users/`, `workout/` 등)
- **DTO + class-validator**: 모든 요청 바디는 DTO 클래스로 검증
- **TypeORM Entity**: DB 테이블은 Entity 클래스로 정의, `synchronize: true`는 개발 환경만

---

## 🔷 Dart/TypeScript 규칙

- Dart: `analysis_options.yaml` strict 모드 준수, `dynamic` 타입 사용 금지
- TypeScript: `strict: true`, `any` 타입 사용 금지
- 생성된 파일(`*.g.dart`, `*.freezed.dart`, `dist/`)은 수정 금지

---

## 📦 디렉토리 규칙

| 디렉토리 | 역할 | 주의 |
|---|---|---|
| `app/lib/core/` | 전역 설정 (Router, Theme, DI) | Feature 의존성 금지 |
| `app/lib/features/{name}/data/` | Repository, DTO, 데이터소스 | domain 계층만 의존 |
| `app/lib/features/{name}/domain/` | Entity, UseCase, Repository 인터페이스 | 외부 의존성 금지 |
| `app/lib/features/{name}/presentation/` | Page, Widget, Notifier | data 직접 참조 금지 |
| `app/lib/shared/` | 공통 재사용 컴포넌트 | Feature 비즈니스 로직 포함 금지 |
| `backend/src/{module}/` | NestJS Feature 모듈 | 타 모듈 Service 직접 import 금지 (DI 사용) |
| `ai-service/app/` | FastAPI 앱 | MVP는 stub 유지, Phase 2에서 ML 구현 |

---

## 🚫 프로젝트 추가 금지 사항

- `dynamic` (Dart) / `any` (TypeScript) 타입 사용
- `*.g.dart`, `*.freezed.dart` 직접 편집
- `app/lib/core/`에서 특정 Feature를 직접 import
- `.env` 파일에 실제 API 키/비밀번호 커밋
- `synchronize: true`를 production 환경에서 사용
- AI 서비스를 MVP 단계에서 실 ML 모델로 구현 (스텁 유지)
