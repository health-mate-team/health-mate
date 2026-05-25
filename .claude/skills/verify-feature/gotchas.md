# verify-feature 함정 기록 (자동 누적)

> Stop hook (`gotchas-collector.js`)이 검증 중 발견된 실패·재발 패턴을 자동으로 기록한다.
> 상한: 10건. 초과 시 승격(SKILL.md 본문 이동) 또는 폐기.

---

## 1. test-phase.sh `((COUNTER++))` set -e 즉시 종료
**증상:** PASS 메시지 1건 후 스크립트 즉시 종료 (exit 1)
**원인:** bash `set -e` 환경에서 `((PASS++))` 가 PASS=0일 때 0(falsy)을 반환 → 종료 트리거
**해결:** `PASS=$((PASS+1))` 또는 `((++PASS))` (pre-increment) 사용

## 2. jq `-e` 플래그가 false 값을 missing으로 판정
**증상:** 응답에 필드가 있는데도 "필드 없음" FAIL
**원인:** `jq -e '.data.is_onboarding_completed'` 가 값이 `false` 일 때 exit 1 반환
**해결:** `jq -r "$field"` 후 결과를 "null" 문자열과 비교

## 3. jq `//` 대체 연산자가 false 를 falsy로 처리
**증상:** `false` 값 필드에 "__MISSING__" 반환
**원인:** jq의 `//` 연산자는 `false`/`null` 모두 falsy로 처리
**해결:** `//` 사용하지 않고 `jq -r` 직접 비교

## 4. WSL 환경에서 Docker 호스트 포트 충돌
**증상:** `port is already allocated` (3000, 5432, 6379)
**원인:** 다른 프로젝트의 Docker 컨테이너가 이미 점유
**해결:** docker-compose.yml에서 호스트 포트만 변경 (3001, 5433, 6380) — 컨테이너 내부 포트는 유지

## 5. Windows 포트 예약 (3000)
**증상:** `/forwards/expose returned unexpected status: 500`
**원인:** Windows 측에서 3000 포트 예약 (점유 프로세스는 없음)
**해결:** 다른 포트로 변경 (예: 3001) — `ss -tlnp` 로는 보이지 않음

## 7. test-phase.sh 폐기 — curl 기반 수동 테스트의 한계 (Phase F, 2026-05-08)
**증상:** Docker + 실서버 의존, 실행 환경마다 다른 결과, 응답 구조 변경 시 수동 수정 필요
**원인:** curl + bash 기반이라 환경 의존성(jq, Docker, 포트) + 수동 토큰 관리 → CI에서 재현 불가
**해결:** `run-cases.ts` (SQLite in-memory, TypeScript, --ci 모드)로 완전 대체.
  - `test-phase.sh`는 `[DEPRECATED]` 마커 추가 후 보존 (참조용)
  - 새 검증은 `npx ts-node scripts/run-cases.ts --target <id> --ci` 사용
**교훈:** bash + curl 검증 스크립트는 빠른 PoC에서만 쓰고, TypeScript 인터프리터로 조기 이전

## 6. Docker backend dist 미동기화 (src 변경 후 `--build` 누락)
**증상:** src의 DTO `@IsIn(...)` enum을 수정해도 PATCH 요청에서 옛 enum 메시지가 반환됨 (예: "must be one of: energy, weight, mood, fitness")
**원인:** `backend/Dockerfile`은 builder stage에서 `npm run build` → dist 생성 후 runtime에서 `dist/main`을 실행. `docker-compose.yml`이 `./backend/src:/app/src`를 mount해도 runtime은 dist만 사용 → src 변경 미반영
**해결:** src 변경 후 반드시 `docker compose up -d --build backend`로 이미지 재빌드. Jest(ts-jest, src 직접) PASS 상태에서도 Docker 환경(dist) FAIL 가능 — Stage 1-A PASS만 보고 Stage 1-B 스킵 금지.
