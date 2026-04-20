#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0
ERRORS=()

ok()   { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); ERRORS+=("$1"); }

echo ""
echo "════════════════════════════════════════"
echo "  health-mate verify.sh"
echo "════════════════════════════════════════"

# ─── 1. 필수 파일 존재 확인 ─────────────────────────
echo ""
echo "▶ [1] 필수 파일 체크"

check_file() {
  [ -f "$1" ] && ok "$1" || fail "Missing: $1"
}

check_file "app/pubspec.yaml"
check_file "app/lib/main.dart"
check_file "app/lib/app.dart"
check_file "app/lib/core/router/app_router.dart"
check_file "app/lib/core/theme/app_theme.dart"
check_file "backend/src/main.ts"
check_file "backend/src/app.module.ts"
check_file "backend/package.json"
check_file "ai-service/app/main.py"
check_file "ai-service/requirements.txt"
check_file "docker-compose.yml"
check_file ".env.example"
check_file ".gitignore"
check_file "CLAUDE.md"

# ─── 2. .env 민감정보 커밋 방지 ────────────────────
echo ""
echo "▶ [2] 보안 체크"

if [ -f ".env" ]; then
  fail ".env 파일이 존재합니다 — .gitignore에 포함되어 있는지 확인하세요"
else
  ok ".env 파일 없음 (정상)"
fi

if grep -q "\.env$" .gitignore 2>/dev/null; then
  ok ".gitignore에 .env 포함됨"
else
  fail ".gitignore에 .env 누락"
fi

# ─── 3. NestJS 빌드 ──────────────────────────────────
echo ""
echo "▶ [3] NestJS TypeScript 컴파일"

if command -v node &>/dev/null && [ -f "backend/package.json" ]; then
  (cd backend && npm run build 2>&1) && ok "NestJS build 성공" || fail "NestJS build 실패"
else
  fail "Node.js 미설치 또는 backend/package.json 없음"
fi

# ─── 4. NestJS Lint ──────────────────────────────────
echo ""
echo "▶ [4] NestJS ESLint"

if [ -f "backend/eslint.config.mjs" ]; then
  (cd backend && npm run lint 2>&1) && ok "NestJS lint 통과" || fail "NestJS lint 실패"
else
  fail "backend/eslint.config.mjs 없음"
fi

# ─── 5. Flutter pubspec 패키지 키 확인 ──────────────
echo ""
echo "▶ [5] Flutter pubspec 패키지 키 확인"

REQUIRED_PACKAGES=(
  "flutter_riverpod"
  "drift"
  "go_router"
  "fl_chart"
  "health"
  "purchases_flutter"
  "firebase_messaging"
  "workmanager"
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  grep -q "$pkg" app/pubspec.yaml && ok "pubspec: $pkg" || fail "pubspec에 $pkg 없음"
done

# ─── 6. 디렉토리 구조 확인 ────────────────────────────
echo ""
echo "▶ [6] Feature 디렉토리 구조"

REQUIRED_DIRS=(
  "app/lib/core/di"
  "app/lib/core/router"
  "app/lib/core/theme"
  "app/lib/features/auth"
  "app/lib/features/dashboard"
  "app/lib/features/workout"
  "app/lib/features/nutrition"
  "app/lib/features/body_record"
  "app/lib/features/subscription"
  "app/lib/shared/widgets"
  "backend/src/auth"
  "backend/src/users"
  "backend/src/workout"
  "backend/src/nutrition"
  "ai-service/app/routers"
)

for dir in "${REQUIRED_DIRS[@]}"; do
  [ -d "$dir" ] && ok "dir: $dir" || fail "Missing dir: $dir"
done

# ─── 결과 ───────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "  결과: PASS $PASS / FAIL $FAIL"
echo "════════════════════════════════════════"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "실패 항목:"
  for err in "${ERRORS[@]}"; do
    echo "  • $err"
  done
  echo ""
  exit 1
fi

echo ""
echo "✅ 모든 검증 통과"
echo ""
