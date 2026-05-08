#!/usr/bin/env ts-node
/**
 * diff-results.ts — 검증 보고서 회귀 비교기
 *
 * docs/verify-results/ 에서 동일 target의 최신 2개 보고서를 비교하여
 * PASS→FAIL 회귀, FAIL→PASS 개선, 신규/삭제 케이스를 출력한다.
 *
 * 사용법:
 *   npx ts-node --project scripts/tsconfig.json scripts/diff-results.ts
 *   npx ts-node --project scripts/tsconfig.json scripts/diff-results.ts \
 *     --target auth_register          (특정 target만 비교)
 *   npx ts-node --project scripts/tsconfig.json scripts/diff-results.ts \
 *     --ci                            (회귀 존재 시 exit 1)
 *
 * 종료 코드:
 *   0 — 회귀 없음
 *   1 — 회귀 감지 (--ci 모드에서만 비정상 종료)
 *   2 — 설정 오류 (결과 파일 없음 등)
 */
import * as fs from 'fs';
import * as path from 'path';
import { RunReport, StageResult, CaseResult } from './lib/types';

const VERIFY_RESULTS_DIR = path.resolve(__dirname, '../../docs/verify-results');

const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const GRAY = '\x1b[90m';
const BOLD = '\x1b[1m';
const NC = '\x1b[0m';

// ─── CLI 파싱 ─────────────────────────────────────────────────
function parseArgs(): { target?: string; ci: boolean } {
  const args = process.argv.slice(2);
  const get = (flag: string) => {
    const i = args.indexOf(flag);
    return i >= 0 ? args[i + 1] : undefined;
  };
  return {
    target: get('--target'),
    ci: args.includes('--ci'),
  };
}

// ─── 파일명에서 target 키 추출 ────────────────────────────────
// 파일명 형식: {YYYY-MM-DD}_{target_key}.json
function extractTargetKey(filename: string): string {
  const base = path.basename(filename, '.json');
  // 날짜 접두사(YYYY-MM-DD_) 제거
  return base.replace(/^\d{4}-\d{2}-\d{2}_/, '');
}

// ─── 보고서 파일 목록 로드 ────────────────────────────────────
interface ReportFile {
  filePath: string;
  filename: string;
  targetKey: string;
  date: string;         // YYYY-MM-DD
  ranAt: string;        // ISO timestamp (정렬용)
}

function loadReportFiles(filterTarget?: string): Map<string, ReportFile[]> {
  if (!fs.existsSync(VERIFY_RESULTS_DIR)) {
    console.error(`[diff-results] 결과 디렉토리 없음: ${VERIFY_RESULTS_DIR}`);
    process.exit(2);
  }

  const files = fs.readdirSync(VERIFY_RESULTS_DIR)
    .filter((f) => f.endsWith('.json'))
    .sort(); // 날짜 오름차순 (파일명이 날짜로 시작하므로)

  const map = new Map<string, ReportFile[]>();

  for (const filename of files) {
    const targetKey = extractTargetKey(filename);
    if (filterTarget && targetKey !== filterTarget) continue;

    const filePath = path.join(VERIFY_RESULTS_DIR, filename);
    let report: RunReport;
    try {
      report = JSON.parse(fs.readFileSync(filePath, 'utf-8')) as RunReport;
    } catch {
      console.warn(`${GRAY}[diff-results] JSON 파싱 실패 스킵: ${filename}${NC}`);
      continue;
    }

    const dateMatch = filename.match(/^(\d{4}-\d{2}-\d{2})_/);
    const date = dateMatch ? dateMatch[1] : '0000-00-00';

    const entry: ReportFile = { filePath, filename, targetKey, date, ranAt: report.ran_at };

    if (!map.has(targetKey)) map.set(targetKey, []);
    map.get(targetKey)!.push(entry);
  }

  // 각 target 내부를 ran_at 기준 오름차순 정렬
  for (const [, entries] of map) {
    entries.sort((a, b) => a.ranAt.localeCompare(b.ranAt));
  }

  return map;
}

// ─── 케이스 맵 생성 ({stage}:{caseId} → pass) ─────────────────
type CaseMap = Map<string, boolean>;

function buildCaseMap(report: RunReport): CaseMap {
  const map = new Map<string, boolean>();
  const stages: Array<keyof typeof report.stages> = ['unit', 'contract', 'dynamic'];
  for (const stage of stages) {
    const stageResult = report.stages[stage] as StageResult | undefined;
    if (!stageResult?.cases) continue;
    for (const c of stageResult.cases) {
      map.set(`${stage}:${c.caseId}`, c.pass);
    }
  }
  return map;
}

// ─── 결과 분류 ────────────────────────────────────────────────
interface DiffResult {
  regressions: string[];   // PASS → FAIL
  improvements: string[];  // FAIL → PASS
  newCases: string[];      // 이전 보고서에 없는 신규
  droppedCases: string[];  // 현재 보고서에서 사라진
}

function diffReports(prev: RunReport, curr: RunReport): DiffResult {
  const prevMap = buildCaseMap(prev);
  const currMap = buildCaseMap(curr);

  const regressions: string[] = [];
  const improvements: string[] = [];
  const newCases: string[] = [];
  const droppedCases: string[] = [];

  for (const [key, currPass] of currMap) {
    if (!prevMap.has(key)) {
      newCases.push(key);
    } else {
      const prevPass = prevMap.get(key)!;
      if (prevPass && !currPass) regressions.push(key);
      else if (!prevPass && currPass) improvements.push(key);
    }
  }

  for (const key of prevMap.keys()) {
    if (!currMap.has(key)) droppedCases.push(key);
  }

  return { regressions, improvements, newCases, droppedCases };
}

// ─── 출력 ─────────────────────────────────────────────────────
function printTargetDiff(
  targetKey: string,
  prev: ReportFile,
  curr: ReportFile,
  diff: DiffResult,
): void {
  const hasChanges =
    diff.regressions.length + diff.improvements.length +
    diff.newCases.length + diff.droppedCases.length > 0;

  console.log(`\n${BOLD}${CYAN}▶ ${targetKey}${NC}`);
  console.log(`  이전: ${GRAY}${prev.filename}${NC}`);
  console.log(`  현재: ${GRAY}${curr.filename}${NC}`);

  if (!hasChanges) {
    console.log(`  ${GREEN}변화 없음 (회귀 없음)${NC}`);
    return;
  }

  for (const key of diff.regressions) {
    console.log(`  ${RED}[REGRESSION]${NC} ${key}  PASS → FAIL`);
  }
  for (const key of diff.improvements) {
    console.log(`  ${GREEN}[IMPROVED]${NC}   ${key}  FAIL → PASS`);
  }
  for (const key of diff.newCases) {
    console.log(`  ${CYAN}[NEW]${NC}        ${key}`);
  }
  for (const key of diff.droppedCases) {
    console.log(`  ${YELLOW}[DROPPED]${NC}    ${key}`);
  }
}

// ─── 메인 ─────────────────────────────────────────────────────
function main(): void {
  const { target: filterTarget, ci } = parseArgs();

  const reportMap = loadReportFiles(filterTarget);

  if (reportMap.size === 0) {
    console.log('[diff-results] 비교할 보고서 없음.');
    if (filterTarget) {
      console.log(`  --target '${filterTarget}'에 해당하는 파일이 없습니다.`);
    } else {
      console.log(`  ${VERIFY_RESULTS_DIR} 에 JSON 파일이 없습니다.`);
    }
    process.exit(2);
  }

  // 비교 쌍이 없는 target 체크
  const skipped: string[] = [];
  const compared: string[] = [];

  console.log('\n════════════════════════════════════════════════════');
  console.log(`  ${BOLD}검증 보고서 회귀 비교 (diff-results)${NC}`);
  console.log('════════════════════════════════════════════════════');

  let totalRegressions = 0;

  for (const [targetKey, entries] of reportMap) {
    if (entries.length < 2) {
      skipped.push(targetKey);
      continue;
    }

    compared.push(targetKey);
    const prev = entries[entries.length - 2];
    const curr = entries[entries.length - 1];

    const prevReport = JSON.parse(fs.readFileSync(prev.filePath, 'utf-8')) as RunReport;
    const currReport = JSON.parse(fs.readFileSync(curr.filePath, 'utf-8')) as RunReport;

    const diff = diffReports(prevReport, currReport);
    printTargetDiff(targetKey, prev, curr, diff);
    totalRegressions += diff.regressions.length;
  }

  // 비교 불가 target 안내
  if (skipped.length > 0) {
    console.log(`\n${GRAY}[SKIP] 보고서 1개뿐이라 비교 불가: ${skipped.join(', ')}${NC}`);
  }

  // 요약
  console.log('\n════════════════════════════════════════════════════');
  if (totalRegressions === 0) {
    console.log(`  ${GREEN}${BOLD}✅ 회귀 없음${NC}  (비교 target: ${compared.length}개)`);
  } else {
    console.log(`  ${RED}${BOLD}❌ 회귀 감지: ${totalRegressions}건${NC}  (비교 target: ${compared.length}개)`);
  }
  console.log('════════════════════════════════════════════════════\n');

  if (ci && totalRegressions > 0) {
    process.exit(1);
  }
}

main();
