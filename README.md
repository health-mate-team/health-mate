# Health Mate

> **Before → Now → After** — 신체 상태 기반 운동·식단 관리 + 리워드 시스템

국내 헬스케어 앱 시장의 구조적 공백을 해결하는 개인 헬스케어 관리 앱입니다.  
식단(밀리그램) + 운동(플랜핏) + 리워드(챌린저스)가 분산된 국내 시장에서, **세 가지를 하나로 통합**합니다.

---

## 개요

사용자의 **현재 신체 상태(Before)** 를 기반으로 목표를 설정하면, AI가 맞춤 식단과 운동 플랜을 추천하고,  
Daily 이행 체크 및 스트릭·배지·XP 리워드로 지속적인 동기부여를 제공합니다.

| 핵심 가치 | 설명 |
|---|---|
| **통합 관리** | 식단 + 운동 + 리워드를 하나의 앱에서 |
| **Before/After 시각화** | 체중·체지방·사진 비교로 변화를 눈으로 확인 |
| **오프라인 퍼스트** | 운동 중 인터넷 없이도 기록, 복구 시 자동 동기화 |
| **저비용 동기부여** | 스트릭·배지·XP — 금전 보상 없이도 높은 리텐션 |

---

## 기술 스택

### 모바일 (app/)

| 카테고리 | 기술 | 버전 |
|---|---|---|
| 프레임워크 | Flutter | 3.41 |
| 언어 | Dart | 3.10 |
| 상태 관리 | flutter_riverpod | ^2.6.1 |
| 로컬 DB | drift (SQLite ORM) | ^2.21.0 |
| 라우팅 | go_router | ^14.6.2 |
| 차트 | fl_chart | ^0.69.0 |
| 건강 데이터 | health (HealthKit + Health Connect) | ^13.3.1 |
| 인앱 결제 | purchases_flutter (RevenueCat) | ^9.16.0 |
| 푸시 알림 | firebase_messaging | ^15.1.4 |
| 백그라운드 동기화 | workmanager | ^0.5.2 |
| 카메라 | camera + image_picker | — |
| BLE | flutter_blue_plus | ^1.34.5 |
| 네트워킹 | dio + retrofit | — |

### 백엔드 (backend/)

| 카테고리 | 기술 | 버전 |
|---|---|---|
| 프레임워크 | NestJS | 11 |
| 언어 | TypeScript | 5 |
| ORM | TypeORM | — |
| DB | PostgreSQL | 16 |
| 캐시 | Redis | 7 |
| 인증 | JWT (@nestjs/jwt) | — |
| 유효성 검증 | class-validator | — |

### AI 서비스 (ai-service/)

| 카테고리 | 기술 | 비고 |
|---|---|---|
| 프레임워크 | FastAPI | 0.115.6 |
| 언어 | Python | 3.12 |
| 상태 | MVP 스텁 | Phase 2에서 ML 구현 |

### 인프라

| 항목 | 기술 |
|---|---|
| 컨테이너 | Docker Compose |
| 프로덕션 (예정) | AWS ECS Fargate |
| 파일 저장 (예정) | AWS S3 + CloudFront |

---

## 프로젝트 구조

```
health-mate/
├── app/                          # Flutter 앱
│   ├── lib/
│   │   ├── core/                 # 전역 설정
│   │   │   ├── di/               # 의존성 주입 (Riverpod Providers)
│   │   │   ├── router/           # GoRouter 라우팅
│   │   │   └── theme/            # Material 3 테마
│   │   ├── features/             # Feature-First 모듈
│   │   │   ├── auth/             # 로그인·회원가입·온보딩
│   │   │   ├── dashboard/        # 홈·스트릭·XP·배지
│   │   │   ├── workout/          # 운동 추천·이행 체크
│   │   │   ├── nutrition/        # 식단 추천·칼로리 기록
│   │   │   ├── body_record/      # 체중·측정·Before/After 사진
│   │   │   ├── wearable/         # HealthKit·Health Connect (Phase 2)
│   │   │   └── subscription/     # RevenueCat 인앱 결제
│   │   └── shared/               # 공통 위젯·유틸·상수
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── backend/                      # NestJS API (포트 3000)
│   └── src/
│       ├── auth/                 # JWT 인증
│       ├── users/                # 사용자 관리
│       ├── workout/              # 운동 데이터 API
│       ├── nutrition/            # 식단 데이터 API
│       ├── body-record/          # 신체 기록 API
│       └── common/               # Guards·Decorators·Filters
│
├── ai-service/                   # FastAPI AI 서비스 (포트 8000)
│   └── app/
│       ├── main.py               # MVP: /health 스텁
│       ├── routers/              # Phase 2: 추천 API
│       └── models/               # Phase 2: ML 모델
│
├── docker-compose.yml            # db + redis + backend + ai-service
├── .env.example                  # 환경변수 템플릿
├── CLAUDE.md                     # Claude Code 운영 규칙
└── verify.sh                     # 빌드·린트·구조 검증 스크립트
```

---

## 시작하기

### 사전 준비

- Docker Desktop
- Node.js 20+
- Flutter 3.41+ (모바일 앱 개발 시)

### 백엔드 + DB 실행

```bash
# 환경변수 설정
cp .env.example .env
# .env에서 JWT_SECRET 등 필수값 변경

# 서비스 시작 (PostgreSQL + Redis + NestJS + FastAPI)
docker compose up -d

# 백엔드 API 확인
curl http://localhost:3000/api
```

### 모바일 앱 실행

```bash
cd app

# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, Drift, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 실행 (에뮬레이터 또는 실기기)
flutter run
```

### 검증 스크립트

```bash
bash verify.sh
```

---

## TODO

### Phase 1 — MVP (진행 예정)

> 핵심 행동 루프: 온보딩 → 운동 추천 → Daily 체크 → 스트릭

- [ ] 온보딩 / 회원가입 / 소셜 로그인
- [ ] 신체 정보 입력 (키·몸무게·체지방·목표 설정)
- [ ] Rule-based 운동 루틴 추천 (MET 테이블 기반)
- [ ] 식단 칼로리 가이드 (식약처 공공 API 연동)
- [ ] Daily 운동·식단 체크 + 오프라인 Drift 저장
- [ ] 리워드 시스템 — 연속 스트릭·배지·XP/레벨업
- [ ] 체중·측정 기록 + 변화 추이 차트 (fl_chart)
- [ ] Before/After 사진 업로드 비교 슬라이더
- [ ] 푸시 알림 (운동 리마인더)
- [ ] RevenueCat 기본 구독 결제 구조
- [ ] workmanager 백그라운드 동기화 (오프라인 → 온라인)

### Phase 2 — AI + 커뮤니티 + 웨어러블

- [ ] AI 맞춤 운동·식단 추천 (Collaborative Filtering)
- [ ] 음식 사진 → 칼로리 인식 (YOLOv8)
- [ ] 커뮤니티 (포스팅·챌린지·좋아요)
- [ ] HealthKit / Google Health Connect 웨어러블 연동
- [ ] 캐릭터·아바타 시각화 (Ready Player Me)
- [ ] InBody LookinBody API 연동 (헬스장 파트너십)
- [ ] 월간 심층 분석 리포트 (유료 전용)

### Phase 3 — AI 시각화 + B2B

- [ ] AI Before/After 실사 체형 시뮬레이션 (3DLOOK API, 유료)
- [ ] LLM 기반 자연어 식단 입력 + AI 코칭 채팅 (Claude API)
- [ ] B2B 기업 복지 패키지
- [ ] Terra API (다종 웨어러블 통합)
- [ ] 글로벌 다국어 확장

---

## 참고 자료

- [리서치 보고서](docs/research/RESEARCH-healthcare-app-2026-04-06.md) — 시장 분석·API·기술 스택 비교 전체
- [식약처 식품영양성분 DB API](https://www.data.go.kr/data/15127578/openapi.do)
- [2024 Adult Compendium of Physical Activities (MET)](https://pacompendium.com/)
- [health package v13 — pub.dev](https://pub.dev/packages/health)
- [purchases_flutter (RevenueCat) — pub.dev](https://pub.dev/packages/purchases_flutter)
