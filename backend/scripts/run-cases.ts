#!/usr/bin/env ts-node
/**
 * run-cases.ts — 케이스 카탈로그 인터프리터 CLI
 *
 * 사용법:
 *   npx ts-node --project scripts/tsconfig.json scripts/run-cases.ts \
 *     --target auth_register \
 *     --stages unit,contract \
 *     [--ci]
 *
 * 종료 코드:
 *   0 — 전체 PASS
 *   1 — FAIL 케이스 존재
 *   2 — 설정 오류 (카탈로그 누락, 인자 오류)
 */
import * as path from 'path';
import * as fs from 'fs';
import { loadCatalog } from './lib/catalog-loader';
import { createTestApp, closeTestApp } from './lib/app-factory';
import { runUnitStage } from './lib/unit-executor';
import { runContractStage } from './lib/contract-validator';
import { runDynamicStage } from './lib/dynamic-executor';
import { RunReport, StageResult } from './lib/types';

const VERIFY_RESULTS_DIR = path.resolve(__dirname, '../../docs/verify-results');

type Stage = 'static' | 'unit' | 'contract' | 'dynamic';

function parseArgs(argv: string[]): { target: string; stages: Stage[]; ci: boolean } {
  let target = '';
  const stages: Stage[] = [];
  let ci = false;

  for (let i = 2; i < argv.length; i++) {
    if (argv[i] === '--target' && argv[i + 1]) {
      target = argv[++i];
    } else if (argv[i] === '--stages' && argv[i + 1]) {
      const raw = argv[++i].split(',').map((s) => s.trim() as Stage);
      stages.push(...raw);
    } else if (argv[i] === '--ci') {
      ci = true;
    }
  }

  if (!target) {
    console.error('[run-cases] --target 필수');
    process.exit(2);
  }
  if (!stages.length) {
    stages.push('unit', 'contract');
  }

  return { target, stages, ci };
}

function gitHead(): string {
  try {
    return require('child_process')
      .execSync('git rev-parse --short HEAD', { cwd: path.resolve(__dirname, '../..') })
      .toString()
      .trim();
  } catch {
    return 'unknown';
  }
}

function saveReport(report: RunReport, targetId: string): void {
  fs.mkdirSync(VERIFY_RESULTS_DIR, { recursive: true });
  const iso = new Date().toISOString().slice(0, 10);
  const safe = targetId.replace(/[^a-zA-Z0-9_-]/g, '_');
  const filePath = path.join(VERIFY_RESULTS_DIR, `${iso}_${safe}.json`);
  fs.writeFileSync(filePath, JSON.stringify(report, null, 2), 'utf-8');
  console.log(`\n📄 보고서: ${filePath}`);
}

function printStage(name: string, result: StageResult): void {
  const icon = result.fail === 0 ? '✅' : '❌';
  console.log(`\n▶ [${name.toUpperCase()}] ${icon} ${result.pass}/${result.total}`);
  for (const c of result.cases) {
    const ci = c.pass ? '  ✅' : '  ❌';
    console.log(`${ci} ${c.caseId}: ${c.caseName}`);
    if (!c.pass) {
      if (c.schemaErrors?.length) {
        c.schemaErrors.forEach((e) => console.log(`      • ${e}`));
      }
      if (c.error) console.log(`      error: ${c.error}`);
    }
  }
}

async function main(): Promise<void> {
  const { target, stages, ci } = parseArgs(process.argv);

  console.log(`\n════════════════════════════════`);
  console.log(`  run-cases — target: ${target}`);
  console.log(`  stages: ${stages.join(', ')}`);
  console.log(`════════════════════════════════`);

  let catalog;
  try {
    catalog = loadCatalog(target);
  } catch (e) {
    console.error((e as Error).message);
    process.exit(2);
  }

  const report: RunReport = {
    schema_version: 1,
    ran_at: new Date().toISOString(),
    target: catalog.target,
    git_head: gitHead(),
    stages: {},
  };

  let overallFail = 0;

  // ── STATIC ──────────────────────────────────────────────
  if (stages.includes('static')) {
    console.log('\n▶ [STATIC] verify.sh의 NestJS build/lint 를 위임합니다.');
    console.log('  run: cd backend && npm run build && npm run lint');
    report.stages.static = { backend: 'skipped (run manually)' };
  }

  // ── UNIT ────────────────────────────────────────────────
  if (stages.includes('unit')) {
    console.log('\n▶ [UNIT] NestJS SQLite in-memory 앱 부팅 중...');
    let app;
    try {
      app = await createTestApp();
    } catch (e) {
      console.error('[UNIT] 앱 부팅 실패:', (e as Error).message);
      await closeTestApp();
      process.exit(1);
    }

    const unitResult = await runUnitStage(app, catalog, target);
    report.stages.unit = unitResult;
    printStage('unit', unitResult);
    overallFail += unitResult.fail;

    await closeTestApp();
  }

  // ── CONTRACT ────────────────────────────────────────────
  if (stages.includes('contract')) {
    const contractResult = runContractStage(catalog, target);
    report.stages.contract = contractResult;
    printStage('contract', contractResult);
    overallFail += contractResult.fail;
  }

  // ── DYNAMIC ─────────────────────────────────────────────
  if (stages.includes('dynamic')) {
    const baseUrl = process.env.DYNAMIC_BASE_URL ?? 'http://localhost:3001';
    console.log(`\n▶ [DYNAMIC] ${baseUrl} 대상 실행 중...`);
    const dynResult = await runDynamicStage(catalog, target, baseUrl);
    report.stages.dynamic = dynResult;
    printStage('dynamic', dynResult);
    overallFail += dynResult.fail;
  }

  // ── 결과 ────────────────────────────────────────────────
  console.log('\n════════════════════════════════');
  console.log(overallFail === 0 ? '  ✅ ALL PASS' : `  ❌ FAIL: ${overallFail}건`);
  console.log('════════════════════════════════');

  saveReport(report, target);

  if (ci) {
    process.exit(overallFail > 0 ? 1 : 0);
  }
}

main().catch((e) => {
  console.error('[run-cases] 치명적 오류:', (e as Error).message);
  process.exit(1);
});
