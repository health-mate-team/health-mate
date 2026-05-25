# Health Mate — 개발 환경 세팅 가이드

> 백엔드(NestJS + PostgreSQL + Redis)는 AWS EC2 서울 리전에서 운영 중입니다.
> 협업 개발자는 **Flutter 앱만 로컬에서 실행**하면 됩니다.

---

## 사전 준비

| 도구 | 버전 | 설치 |
|---|---|---|
| Flutter | 3.41+ | https://flutter.dev/docs/get-started/install |
| Dart | 3.10+ | Flutter 설치 시 포함 |
| Android Studio / Xcode | 최신 | 에뮬레이터 실행용 |
| Git | - | https://git-scm.com |

---

## 1. 레포 클론

```bash
git clone https://github.com/health-mate-team/health-mate.git
cd health-mate
```

---

## 2. Flutter 앱 실행

```bash
cd app

# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 에뮬레이터 또는 실기기에서 실행
flutter run
```

> API 서버 주소는 자동으로 `http://43.201.67.1:3001/api` (AWS 서울)로 연결됩니다.
> 별도 백엔드 설정 없이 바로 사용 가능합니다.

---

## 3. 개발 브랜치 규칙

```
main         ← 프로덕션 배포 (머지 시 AWS 자동 배포)
develop      ← 통합 브랜치
feature/*    ← 기능 개발 브랜치
hotfix/*     ← 긴급 버그 수정
```

### PR 흐름

```
feature/내기능 → develop → main
```

`main`에 머지되면 GitHub Actions가 AWS EC2에 자동 배포합니다.

---

## 4. 서버 정보 (참고용)

| 항목 | 값 |
|---|---|
| 서버 | AWS EC2 t3.micro (서울 ap-northeast-2) |
| API | http://43.201.67.1:3001/api |
| Backend 포트 | 3001 |
| DB | PostgreSQL 16 (서버 내부, 외부 미노출) |
| 캐시 | Redis 7 (서버 내부, 외부 미노출) |

---

## 5. CI/CD

`main` 브랜치에 PR 머지 시 GitHub Actions가 자동으로:
1. EC2 서버에 SSH 접속
2. `git pull origin main`
3. `docker-compose up -d --build`

별도 배포 작업 불필요합니다.

---

## 6. 서버 직접 접속 (관리자용)

서버 SSH 접속이 필요한 경우 `.pem` 키 파일을 별도 전달받아야 합니다.

```bash
ssh -i ~/.ssh/healthmate-key.pem ec2-user@43.201.67.1
```

---

## 문의

이슈는 GitHub Issues에 등록해주세요.
