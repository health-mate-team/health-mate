#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# [DEPRECATED] 2026-05-08 — run-cases.ts로 완전 대체됨
#
# 대체 방법:
#   npx ts-node --project scripts/tsconfig.json \
#     scripts/run-cases.ts --target <id> --stages unit,contract --ci
#
# 폐기 이유:
#   - Docker + 실서버 의존 → CI 재현 불가
#   - bash + curl → 환경 의존성(jq, 포트) 및 수동 토큰 관리
#   - run-cases.ts: SQLite in-memory, TypeScript, --ci 모드 지원
#
# 이 파일은 참조용으로 보존됩니다. 실행하지 마세요.
# ═══════════════════════════════════════════════════════════════

# Backend Phase API 연동 테스트 스크립트 (구버전 — 사용 금지)
# 사용법: bash backend/scripts/test-phase.sh <p0|p1|p2|p3>
# 전제:   Docker Compose(db + redis + backend)가 실행 중이어야 함

set -euo pipefail

PHASE="${1:-}"
BASE="http://localhost:3001/api"
PASS=0
FAIL=0
SKIP=0

# 색상
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ -z "$PHASE" ]]; then
  echo "사용법: bash backend/scripts/test-phase.sh <p0|p1|p2|p3>"
  exit 1
fi

# ──────────────────────────────────────────────
# 헬퍼 함수
# ──────────────────────────────────────────────
log_test() { echo -e "${CYAN}[TEST]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS=$((PASS+1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$((FAIL+1)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; SKIP=$((SKIP+1)); }

# HTTP 요청 후 응답 코드 확인
assert_status() {
  local label="$1" method="$2" url="$3" expected="$4"
  shift 4
  local response
  response=$(curl -s -o /tmp/hm_response.json -w "%{http_code}" -X "$method" "$url" "$@" 2>/dev/null)
  if [[ "$response" == "$expected" ]]; then
    log_pass "$label (HTTP $response)"
    return 0
  else
    log_fail "$label (기대: $expected, 실제: $response) — $(cat /tmp/hm_response.json 2>/dev/null | head -c 200)"
    return 1
  fi
}

# 응답 JSON에서 필드 존재 여부 확인
assert_field() {
  local label="$1" field="$2"
  if command -v jq &>/dev/null; then
    local val
    val=$(jq -r "${field}" /tmp/hm_response.json 2>/dev/null)
    if [[ $? -eq 0 && "$val" != "null" ]]; then
      log_pass "$label (필드: $field)"
    else
      log_fail "$label (필드 없음: $field) — $(head -c 300 /tmp/hm_response.json 2>/dev/null)"
    fi
  else
    log_skip "$label (jq 없음 — 필드 검증 스킵)"
  fi
}

# 응답 JSON에서 필드 값 확인
assert_value() {
  local label="$1" field="$2" expected="$3"
  if command -v jq &>/dev/null; then
    local actual
    actual=$(jq -r "$field" /tmp/hm_response.json 2>/dev/null)
    if [[ "$actual" == "$expected" ]]; then
      log_pass "$label ($field = $expected)"
    else
      log_fail "$label ($field 기대: $expected, 실제: $actual)"
    fi
  else
    log_skip "$label (jq 없음)"
  fi
}

# 서버 헬스 체크
wait_for_server() {
  echo -e "\n${CYAN}▶ 서버 응답 대기 중...${NC}"
  for i in {1..15}; do
    if curl -s "$BASE" &>/dev/null; then
      echo -e "${GREEN}서버 응답 확인${NC}"
      return 0
    fi
    sleep 2
  done
  echo -e "${RED}서버 미응답 — Docker Compose 실행 여부 확인: docker compose up -d db redis backend${NC}"
  exit 1
}

# ──────────────────────────────────────────────
# Phase 테스트
# ──────────────────────────────────────────────

run_p0() {
  echo -e "\n${CYAN}════════════════════════════════════════${NC}"
  echo -e "${CYAN} Phase P0 — Auth + Users + Onboarding  ${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}\n"

  local TEST_EMAIL="test_$(date +%s)@owner.app"
  local TEST_PW="Test1234!"
  local TEST_NAME="테스터"

  # 1. 회원가입
  log_test "POST /auth/register — 회원가입"
  assert_status "register" POST "$BASE/auth/register" 201 \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PW\",\"name\":\"$TEST_NAME\"}"
  assert_field "access_token 존재" ".data.access_token"
  local ACCESS_TOKEN
  ACCESS_TOKEN=$(jq -r '.data.access_token' /tmp/hm_response.json 2>/dev/null)

  # 2. 중복 이메일 가입 시도
  log_test "POST /auth/register — 중복 이메일 409"
  assert_status "register duplicate" POST "$BASE/auth/register" 409 \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PW\",\"name\":\"$TEST_NAME\"}"

  # 3. 로그인
  log_test "POST /auth/login — 로그인"
  assert_status "login" POST "$BASE/auth/login" 200 \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PW\"}"
  assert_field "is_onboarding_completed 필드" ".data.is_onboarding_completed"
  local LOGIN_TOKEN
  LOGIN_TOKEN=$(jq -r '.data.access_token' /tmp/hm_response.json 2>/dev/null)

  # 4. 토큰 없이 GET /users/me → 401
  log_test "GET /users/me — 토큰 없음 → 401"
  assert_status "me unauthorized" GET "$BASE/users/me" 401

  # 5. 토큰으로 GET /users/me → 200
  log_test "GET /users/me — 토큰 포함 → 200"
  assert_status "me authorized" GET "$BASE/users/me" 200 \
    -H "Authorization: Bearer $LOGIN_TOKEN"
  assert_value "이름 일치" ".data.name" "$TEST_NAME"

  # 6. 온보딩 완료
  log_test "POST /onboarding/complete — 온보딩 완료"
  assert_status "onboarding" POST "$BASE/onboarding/complete" 200 \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $LOGIN_TOKEN" \
    -d "{\"name\":\"$TEST_NAME\",\"goal_type\":\"energy\",\"last_period_start_date\":\"2026-04-28\",\"average_cycle_length\":28,\"average_period_length\":5,\"is_irregular\":false}"
  assert_field "initial_stats 존재" ".data.initial_stats"
  assert_field "current_phase 존재" ".data.current_phase"

  # 7. 온보딩 후 /users/me → is_onboarding_completed: true
  log_test "GET /users/me — 온보딩 완료 후 is_onboarding_completed=true"
  assert_status "me after onboarding" GET "$BASE/users/me" 200 \
    -H "Authorization: Bearer $LOGIN_TOKEN"
  assert_value "온보딩 완료 플래그" ".data.is_onboarding_completed" "true"

  # 환경변수 저장 (후속 Phase에서 재사용)
  echo "TEST_EMAIL=$TEST_EMAIL" > /tmp/hm_test_env
  echo "TEST_PW=$TEST_PW" >> /tmp/hm_test_env
  echo "ACCESS_TOKEN=$LOGIN_TOKEN" >> /tmp/hm_test_env
}

run_p1() {
  echo -e "\n${CYAN}════════════════════════════════════════${NC}"
  echo -e "${CYAN} Phase P1 — Cycle + Rituals + Stats     ${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}\n"

  # P0 토큰 로드 또는 신규 로그인
  local TOKEN=""
  if [[ -f /tmp/hm_test_env ]]; then
    source /tmp/hm_test_env
    TOKEN="$ACCESS_TOKEN"
  else
    log_test "P0 토큰 없음 — 임시 계정 생성"
    local TMP_EMAIL="p1_$(date +%s)@owner.app"
    curl -s -o /tmp/hm_response.json -X POST "$BASE/auth/register" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$TMP_EMAIL\",\"password\":\"Test1234!\",\"name\":\"P1테스터\"}" &>/dev/null
    # 온보딩 완료
    TOKEN=$(jq -r '.data.access_token' /tmp/hm_response.json 2>/dev/null)
    curl -s -o /dev/null -X POST "$BASE/onboarding/complete" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{"name":"P1테스터","goal_type":"energy","last_period_start_date":"2026-04-28","average_cycle_length":28,"average_period_length":5,"is_irregular":false}'
    echo "ACCESS_TOKEN=$TOKEN" > /tmp/hm_test_env
  fi

  local TODAY
  TODAY=$(date +%Y-%m-%d)
  local AUTH_H="Authorization: Bearer $TOKEN"

  # 1. 사이클 현재 상태
  log_test "GET /cycle/current — 사이클 단계 조회"
  assert_status "cycle current" GET "$BASE/cycle/current" 200 -H "$AUTH_H"
  assert_field "current_phase 존재" ".data.current_phase"
  assert_field "day_of_cycle 존재" ".data.day_of_cycle"

  # 2. 오늘 의식 상태 (초기: 모두 null/false)
  log_test "GET /rituals/today — 의식 상태 초기값"
  assert_status "rituals today" GET "$BASE/rituals/today" 200 -H "$AUTH_H"
  assert_value "morning_mood 초기값 null" ".data.morning_mood" "null"
  assert_value "evening_completed 초기값 false" ".data.evening_completed" "false"

  # 3. 아침 기분 기록 (mood: 1~5 정수)
  log_test "POST /rituals/morning/mood — 기분 기록"
  assert_status "morning mood" POST "$BASE/rituals/morning/mood" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d '{"mood":4}'
  assert_field "recommended_promise 존재" ".data.recommended_promise"
  assert_field "xp_earned 존재" ".data.xp_earned"

  # 4. 오늘의 약속 확정
  log_test "POST /rituals/morning/promise — 약속 확정"
  assert_status "morning promise" POST "$BASE/rituals/morning/promise" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d '{"promise":"10분 산책"}'
  assert_field "promise 존재" ".data.promise"

  # 5. 저녁 의식 (약속 완료)
  log_test "POST /rituals/evening — 저녁 의식 (약속 완료)"
  assert_status "evening ritual" POST "$BASE/rituals/evening" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d '{"promise_kept":true}'
  assert_field "xp_earned 존재" ".data.xp_earned"
  assert_field "streak 존재" ".data.streak"

  # xp_earned >= 60 (저녁 의식 +10 + 약속 완료 +50)
  if command -v jq &>/dev/null; then
    local xp
    xp=$(jq -r '.data.xp_earned' /tmp/hm_response.json 2>/dev/null)
    if [[ "$xp" -ge 60 ]]; then
      log_pass "XP 합계 정확 (≥60, 실제: $xp)"
    else
      log_fail "XP 합계 오류 (기대: ≥60, 실제: $xp)"
    fi
  fi

  # 6. 홈 화면 단일 쿼리
  log_test "GET /stats/today — 홈 화면 전체 데이터"
  assert_status "stats today" GET "$BASE/stats/today" 200 -H "$AUTH_H"
  assert_field "user 필드" ".data.user"
  assert_field "stats 필드" ".data.stats"
  assert_field "cycle 필드" ".data.cycle"
  assert_field "today_ritual 필드" ".data.today_ritual"
  assert_value "today_ritual.evening_completed" ".data.today_ritual.evening_completed" "true"
}

run_p2() {
  echo -e "\n${CYAN}════════════════════════════════════════${NC}"
  echo -e "${CYAN} Phase P2 — Actions + Rewards           ${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}\n"

  local TOKEN=""
  if [[ -f /tmp/hm_test_env ]]; then
    source /tmp/hm_test_env
    TOKEN="$ACCESS_TOKEN"
  else
    log_fail "P0/P1 테스트 환경 없음 — p0 먼저 실행하세요"
    exit 1
  fi

  local TODAY
  TODAY=$(date +%Y-%m-%d)
  local AUTH_H="Authorization: Bearer $TOKEN"

  # 1. 오늘 물 섭취량 초기값
  log_test "GET /actions/water/today — 오늘 물 섭취 초기값"
  assert_status "water today" GET "$BASE/actions/water/today" 200 -H "$AUTH_H"
  assert_field "cups_total 존재" ".data.cups_total"

  # 2. 물 마시기 기록
  log_test "POST /actions/water — 물 마시기 +1잔"
  assert_status "water add" POST "$BASE/actions/water" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"date\":\"$TODAY\",\"cups_added\":1}"
  assert_field "today_cups_total 존재" ".data.today_cups_total"
  assert_field "hydration_stat 존재" ".data.hydration_stat"

  # 3. 물 추가 후 cups_total 증가 확인
  log_test "GET /actions/water/today — cups_total 증가 확인"
  assert_status "water today after" GET "$BASE/actions/water/today" 200 -H "$AUTH_H"
  if command -v jq &>/dev/null; then
    local cups
    cups=$(jq -r '.data.cups_total' /tmp/hm_response.json 2>/dev/null)
    if [[ "$cups" -ge 1 ]]; then
      log_pass "cups_total 증가 확인 (실제: $cups)"
    else
      log_fail "cups_total 미증가 (실제: $cups)"
    fi
  fi

  # 4. 산책 시작
  log_test "POST /actions/walk/start — 산책 시작"
  local STARTED_AT
  STARTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  assert_status "walk start" POST "$BASE/actions/walk/start" 201 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"started_at\":\"$STARTED_AT\"}"
  assert_field "walk_session_id 존재" ".data.walk_session_id"
  local SESSION_ID
  SESSION_ID=$(jq -r '.data.walk_session_id' /tmp/hm_response.json 2>/dev/null)

  # 5. 산책 완료
  log_test "POST /actions/walk/complete — 산책 완료"
  local ENDED_AT
  ENDED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  assert_status "walk complete" POST "$BASE/actions/walk/complete" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"walk_session_id\":\"$SESSION_ID\",\"ended_at\":\"$ENDED_AT\",\"duration_minutes\":15,\"steps_count\":1800,\"distance_km\":1.26}"
  assert_field "xp_earned 존재" ".data.xp_earned"

  # 6. 리워드 요약
  log_test "GET /rewards/summary — 레벨 & XP & 배지"
  assert_status "rewards summary" GET "$BASE/rewards/summary" 200 -H "$AUTH_H"
  assert_field "level 존재" ".data.level"
  assert_field "current_xp 존재" ".data.current_xp"
  assert_field "evolution_stage 존재" ".data.evolution_stage"
  assert_field "badges 배열" ".data.badges"

  # 7. 스탯 히스토리
  log_test "GET /stats/history?days=7 — 히스토리"
  assert_status "stats history" GET "$BASE/stats/history?days=7" 200 -H "$AUTH_H"
  assert_field "daily_records 배열" ".data.daily_records"
}

run_p3() {
  echo -e "\n${CYAN}════════════════════════════════════════${NC}"
  echo -e "${CYAN} Phase P3 — Workout + Nutrition         ${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}\n"

  local TOKEN=""
  if [[ -f /tmp/hm_test_env ]]; then
    source /tmp/hm_test_env
    TOKEN="$ACCESS_TOKEN"
  else
    log_fail "P0 테스트 환경 없음 — p0 먼저 실행하세요"
    exit 1
  fi

  local TODAY
  TODAY=$(date +%Y-%m-%d)
  local AUTH_H="Authorization: Bearer $TOKEN"

  # 1. 운동 추천
  log_test "GET /workout/recommend — 오늘의 운동 추천"
  assert_status "workout recommend" GET "$BASE/workout/recommend?date=$TODAY" 200 -H "$AUTH_H"
  assert_field "recommendation 존재" ".data.recommendation"
  assert_field "based_on 존재" ".data.based_on"
  local WORKOUT_ID
  WORKOUT_ID=$(jq -r '.data.recommendation.workout_id' /tmp/hm_response.json 2>/dev/null)

  # 2. 운동 완료
  log_test "POST /workout/complete — 운동 완료"
  assert_status "workout complete" POST "$BASE/workout/complete" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"workout_id\":\"$WORKOUT_ID\",\"date\":\"$TODAY\",\"duration_actual_minutes\":18,\"completion_rate\":0.9}"
  assert_field "xp_earned 존재" ".data.xp_earned"

  # 3. 운동 건너뜀
  log_test "POST /workout/skip — 운동 건너뜀"
  assert_status "workout skip" POST "$BASE/workout/skip" 200 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"workout_id\":\"alt_workout\",\"date\":\"$TODAY\",\"skip_reason\":\"tired\"}"

  # 4. 식단 검색
  log_test "GET /nutrition/search?q=닭가슴살 — 음식 검색"
  assert_status "nutrition search" GET "$BASE/nutrition/search?q=%EB%8B%AD%EA%B0%80%EC%8A%B4%EC%82%B4&limit=5" 200 -H "$AUTH_H"
  assert_field "results 배열" ".data.results"

  # 5. 식단 검색 캐시 히트 (2회 연속 요청)
  log_test "GET /nutrition/search — 캐시 히트 확인 (2회)"
  assert_status "nutrition search cached" GET "$BASE/nutrition/search?q=%EB%8B%AD%EA%B0%80%EC%8A%B4%EC%82%B4&limit=5" 200 -H "$AUTH_H"

  # 6. 식사 기록
  log_test "POST /nutrition/logs — 점심 식사 기록"
  assert_status "nutrition log" POST "$BASE/nutrition/logs" 201 \
    -H "Content-Type: application/json" -H "$AUTH_H" \
    -d "{\"date\":\"$TODAY\",\"meal_type\":\"lunch\",\"foods\":[{\"food_id\":\"mfds_001\",\"amount_g\":150}]}"
  assert_field "total_calories 존재" ".data.total_calories"

  # 7. 오늘 식단 요약
  log_test "GET /nutrition/today — 오늘 식단 요약"
  assert_status "nutrition today" GET "$BASE/nutrition/today" 200 -H "$AUTH_H"
  assert_field "total_calories 존재" ".data.total_calories"
  assert_field "phase_recommendation 존재" ".data.phase_recommendation"
}

# ──────────────────────────────────────────────
# 결과 출력
# ──────────────────────────────────────────────
print_result() {
  echo -e "\n${CYAN}════════════════════════════════════════${NC}"
  echo -e "${CYAN} 테스트 결과 요약 — Phase ${PHASE^^}           ${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}"
  echo -e "  ${GREEN}PASS: $PASS${NC}"
  echo -e "  ${RED}FAIL: $FAIL${NC}"
  echo -e "  ${YELLOW}SKIP: $SKIP${NC}"
  echo ""
  if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✅ Phase ${PHASE^^} 전체 통과 — 메모리 진행현황 업데이트 대상${NC}"
  else
    echo -e "${RED}❌ Phase ${PHASE^^} 실패 항목 $FAIL개 — 수정 후 재실행 필요${NC}"
    exit 1
  fi
}

# ──────────────────────────────────────────────
# 메인 실행
# ──────────────────────────────────────────────
wait_for_server

case "$PHASE" in
  p0) run_p0 ;;
  p1) run_p1 ;;
  p2) run_p2 ;;
  p3) run_p3 ;;
  *)
    echo "알 수 없는 Phase: $PHASE (사용 가능: p0 p1 p2 p3)"
    exit 1
    ;;
esac

print_result
