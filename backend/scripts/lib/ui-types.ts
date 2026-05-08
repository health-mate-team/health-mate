// UI 시나리오 관련 타입 — DYNAMIC stage ui_scenario 인터프리터

// ─── 셀렉터 ────────────────────────────────────────────────────
// Flutter Web에서 flt-semantics-identifier DOM 속성이 노출되지 않음 (3.41.9 확인).
// role+name 기반 ARIA 접근성 트리 셀렉터를 사용한다.
export interface RoleSelector {
  role: string;            // 'button' | 'checkbox' | 'img' | 'textbox' | ...
  name?: string;           // accessible name (aria-label 또는 innerText)
  index?: number;          // 같은 role이 여러 개일 때 0-based 인덱스
}

export interface TextSelector {
  text: string;            // 텍스트 콘텐츠 기반
  exact?: boolean;         // 기본 true
}

export type UiSelector = RoleSelector | TextSelector;

// ─── 7종 action 타입 ──────────────────────────────────────────
export interface NavigateAction {
  action: 'navigate';
  to: string;              // URL 경로 (베이스 URL 상대)
}

export interface SnapshotAction {
  action: 'snapshot';
  label: string;           // 스냅샷 레이블 (보고서 참조용)
}

export interface ClickAction {
  action: 'click';
  selector: UiSelector;
}

export interface TypeAction {
  action: 'type';
  selector: UiSelector;
  value: string;
}

export interface FillFormAction {
  action: 'fill_form';
  fields: Array<{ selector: UiSelector; value: string }>;
}

export interface WaitForAction {
  action: 'wait_for';
  condition: string;       // 'response:POST /rituals/evening' | 'visible:...' | 'navigation'
  timeout_ms?: number;     // 기본 10000
}

export interface AssertNetworkAction {
  action: 'assert_network';
  request: string;         // 'POST /rituals/evening' 형식
  expect_status?: number;
  expect_body?: Record<string, unknown>;
}

export interface AssertConsoleAction {
  action: 'assert_console';
  level: 'error' | 'warn' | 'info';
  count: number;           // 기대 횟수 (보통 0)
}

export type UiAction =
  | NavigateAction
  | SnapshotAction
  | ClickAction
  | TypeAction
  | FillFormAction
  | WaitForAction
  | AssertNetworkAction
  | AssertConsoleAction;

// ─── 시나리오 및 카탈로그 ──────────────────────────────────────
export interface UiScenario {
  actions: UiAction[];
}

export interface ScreenCatalog {
  schema_version: number;
  target: string;           // 'screen:evening_ritual_page'
  spec_section?: string;
  dynamic?: {
    ui_scenario?: UiAction[];
  };
  screen_targets?: Array<{ calls: string[] }>;
}

// ─── 실행 결과 ─────────────────────────────────────────────────
export type ActionStatus = 'pass' | 'fail' | 'skip';

export interface ActionResult {
  index: number;
  action: string;
  status: ActionStatus;
  detail?: string;
  error?: string;
  snapshot_path?: string;   // snapshot action 결과 경로
}

export interface UiStageResult {
  target: string;
  ran_at: string;
  base_url: string;
  total: number;
  pass: number;
  fail: number;
  skip: number;
  actions: ActionResult[];
}

// ─── 드라이런 출력 ─────────────────────────────────────────────
export interface DryRunStep {
  index: number;
  action: string;
  mcp_tool: string;         // 호출할 Playwright MCP 도구명
  mcp_params: Record<string, unknown>;  // MCP 호출 파라미터
  description: string;      // Claude Code가 읽는 실행 지시
}

export interface DryRunPlan {
  target: string;
  base_url: string;
  steps: DryRunStep[];
}
