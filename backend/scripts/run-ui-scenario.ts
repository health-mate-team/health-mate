/**
 * run-ui-scenario.ts
 *
 * DYNAMIC stage UI 시나리오 어댑터.
 * 카탈로그 YAML의 dynamic.ui_scenario를 읽고 dry-run 플랜을 출력한다.
 * 실제 실행은 Claude Code가 Playwright MCP 도구로 수행한다.
 *
 * 사용법:
 *   npx ts-node --project scripts/tsconfig.json scripts/run-ui-scenario.ts \
 *     --target screen_evening_ritual \
 *     [--base-url http://localhost:3000] \
 *     [--dry-run]                  (기본값: dry-run 모드)
 *     [--report path/to/result.json]
 */
import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import {
  UiAction,
  UiSelector,
  RoleSelector,
  ScreenCatalog,
  DryRunStep,
  DryRunPlan,
  UiStageResult,
  ActionResult,
} from './lib/ui-types';

const VERIFY_CASES_DIR = path.resolve(__dirname, '../../docs/verify-cases');
const VERIFY_RESULTS_DIR = path.resolve(__dirname, '../../docs/verify-results');

// ─── CLI 파싱 ─────────────────────────────────────────────────
function parseArgs(): { target: string; baseUrl: string; dryRun: boolean; reportPath?: string } {
  const args = process.argv.slice(2);
  const get = (flag: string) => {
    const i = args.indexOf(flag);
    return i >= 0 ? args[i + 1] : undefined;
  };
  const target = get('--target');
  if (!target) {
    console.error('[run-ui-scenario] --target 필수: screen_evening_ritual 등');
    process.exit(2);
  }
  return {
    target,
    baseUrl: get('--base-url') ?? 'http://localhost:3000',
    dryRun: !args.includes('--no-dry-run'),
    reportPath: get('--report'),
  };
}

// ─── 카탈로그 로드 ────────────────────────────────────────────
function loadScreenCatalog(target: string): ScreenCatalog {
  const filePath = path.join(VERIFY_CASES_DIR, `${target}.yaml`);
  if (!fs.existsSync(filePath)) {
    console.error(`[run-ui-scenario] 카탈로그 없음: ${filePath}`);
    process.exit(2);
  }
  const raw = yaml.load(fs.readFileSync(filePath, 'utf-8')) as ScreenCatalog;
  if (!raw.dynamic?.ui_scenario || !Array.isArray(raw.dynamic.ui_scenario)) {
    console.error(`[run-ui-scenario] ${target}: dynamic.ui_scenario 없음 또는 배열 아님`);
    process.exit(2);
  }
  return raw;
}

// ─── 셀렉터 → MCP 파라미터 변환 ──────────────────────────────
function selectorToDescription(sel: UiSelector): string {
  if ('role' in sel) {
    const rs = sel as RoleSelector;
    const namePart = rs.name ? ` "${rs.name}"` : '';
    const idxPart = rs.index !== undefined ? ` [index=${rs.index}]` : '';
    return `${rs.role}${namePart}${idxPart}`;
  }
  return `text="${sel.text}"`;
}

function selectorToMcpElement(sel: UiSelector): string {
  if ('role' in sel) {
    const rs = sel as RoleSelector;
    return rs.name ? `${rs.role} "${rs.name}"` : rs.role;
  }
  return `text "${sel.text}"`;
}

// ─── action → DryRunStep 변환 ─────────────────────────────────
function actionToDryRunStep(action: UiAction, index: number, baseUrl: string): DryRunStep {
  switch (action.action) {
    case 'navigate':
      return {
        index,
        action: 'navigate',
        mcp_tool: 'mcp__playwright__browser_navigate',
        mcp_params: { url: `${baseUrl}/#${action.to}` },
        description: `페이지 이동: ${baseUrl}/#${action.to}`,
      };

    case 'snapshot':
      return {
        index,
        action: 'snapshot',
        mcp_tool: 'mcp__playwright__browser_snapshot',
        mcp_params: { filename: `.playwright-mcp/${action.label}.yml` },
        description: `접근성 스냅샷 캡처 (label=${action.label})`,
      };

    case 'click': {
      const desc = selectorToDescription(action.selector);
      return {
        index,
        action: 'click',
        mcp_tool: 'mcp__playwright__browser_click',
        mcp_params: { element: selectorToMcpElement(action.selector) },
        description: `클릭: ${desc}`,
      };
    }

    case 'type': {
      const desc = selectorToDescription(action.selector);
      return {
        index,
        action: 'type',
        mcp_tool: 'mcp__playwright__browser_type',
        mcp_params: {
          element: selectorToMcpElement(action.selector),
          text: action.value,
        },
        description: `텍스트 입력: ${desc} ← "${action.value}"`,
      };
    }

    case 'fill_form':
      return {
        index,
        action: 'fill_form',
        mcp_tool: 'mcp__playwright__browser_fill_form',
        mcp_params: {
          fields: action.fields.map((f) => ({
            element: selectorToMcpElement(f.selector),
            value: f.value,
          })),
        },
        description: `폼 채우기: ${action.fields.length}개 필드`,
      };

    case 'wait_for': {
      // 'response:POST /rituals/evening' 형식 파싱
      if (action.condition.startsWith('response:')) {
        const endpoint = action.condition.slice('response:'.length).trim();
        return {
          index,
          action: 'wait_for',
          mcp_tool: 'mcp__playwright__browser_wait_for',
          mcp_params: { text: endpoint, timeout: action.timeout_ms ?? 10000 },
          description: `응답 대기: ${endpoint} (timeout=${action.timeout_ms ?? 10000}ms)`,
        };
      }
      return {
        index,
        action: 'wait_for',
        mcp_tool: 'mcp__playwright__browser_wait_for',
        mcp_params: { text: action.condition, timeout: action.timeout_ms ?? 10000 },
        description: `대기: ${action.condition}`,
      };
    }

    case 'assert_network':
      return {
        index,
        action: 'assert_network',
        mcp_tool: 'mcp__playwright__browser_network_requests',
        mcp_params: { url: action.request },
        description: [
          `네트워크 검증: ${action.request}`,
          action.expect_status !== undefined ? ` status=${action.expect_status}` : '',
          action.expect_body ? ` body=${JSON.stringify(action.expect_body)}` : '',
        ].join(''),
      };

    case 'assert_console':
      return {
        index,
        action: 'assert_console',
        mcp_tool: 'mcp__playwright__browser_console_messages',
        mcp_params: { type: action.level },
        description: `콘솔 검증: ${action.level} level count=${action.count}건`,
      };

    default: {
      const unknownAction = action as { action: string };
      return {
        index,
        action: unknownAction.action,
        mcp_tool: 'unknown',
        mcp_params: {},
        description: `알 수 없는 action: ${unknownAction.action}`,
      };
    }
  }
}

// ─── Dry-run 플랜 생성 ────────────────────────────────────────
function buildDryRunPlan(catalog: ScreenCatalog, baseUrl: string): DryRunPlan {
  const actions = catalog.dynamic!.ui_scenario!;
  const steps = actions.map((a, i) => actionToDryRunStep(a, i, baseUrl));
  return {
    target: catalog.target,
    base_url: baseUrl,
    steps,
  };
}

// ─── Dry-run 출력 ─────────────────────────────────────────────
function printDryRunPlan(plan: DryRunPlan): void {
  console.log('');
  console.log('════════════════════════════════════════════════════');
  console.log(`  UI Scenario Dry-Run: ${plan.target}`);
  console.log(`  base_url: ${plan.base_url}`);
  console.log('════════════════════════════════════════════════════');
  for (const step of plan.steps) {
    console.log('');
    console.log(`  [${step.index}] ${step.action.toUpperCase()}`);
    console.log(`       설명: ${step.description}`);
    console.log(`       MCP:  ${step.mcp_tool}`);
    console.log(`       파라미터: ${JSON.stringify(step.mcp_params)}`);
  }
  console.log('');
  console.log(`  총 ${plan.steps.length}개 step`);
  console.log('════════════════════════════════════════════════════');
  console.log('');
  console.log('[DRY-RUN 완료]');
  console.log('실행하려면 Claude Code가 위 MCP 도구를 순서대로 호출합니다.');
  console.log('');
  // JSON 출력 (파싱용)
  console.log('---JSON---');
  console.log(JSON.stringify(plan, null, 2));
}

// ─── 빈 보고서 생성 (실행 후 채워짐) ─────────────────────────
function writeEmptyReport(target: string, baseUrl: string, reportPath?: string): void {
  const result: UiStageResult = {
    target,
    ran_at: new Date().toISOString(),
    base_url: baseUrl,
    total: 0,
    pass: 0,
    fail: 0,
    skip: 0,
    actions: [],
  };
  const outPath = reportPath ?? path.join(
    VERIFY_RESULTS_DIR,
    `${new Date().toISOString().split('T')[0]}_${target}_ui.json`,
  );
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2), 'utf-8');
  console.log(`[run-ui-scenario] 보고서 초기화: ${outPath}`);
}

// ─── 메인 ────────────────────────────────────────────────────
function main(): void {
  const { target, baseUrl, dryRun, reportPath } = parseArgs();

  const catalog = loadScreenCatalog(target);
  const plan = buildDryRunPlan(catalog, baseUrl);

  if (dryRun) {
    printDryRunPlan(plan);
  } else {
    // --no-dry-run: 빈 보고서만 생성 (실제 실행은 Claude Code가 MCP로 수행)
    writeEmptyReport(target, baseUrl, reportPath);
    console.log('[run-ui-scenario] 보고서 초기화 완료. Claude Code가 MCP로 각 step을 실행합니다.');
  }
}

main();
