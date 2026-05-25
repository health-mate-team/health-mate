// 케이스 카탈로그 YAML 스키마 타입 정의

export interface RequestDef {
  method: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE';
  path: string;
  body?: Record<string, unknown>;
  query?: Record<string, string>;
  auth: 'required' | 'none';
}

export interface BodySchema {
  type?: string;
  required?: string[];
  properties?: Record<string, unknown>;
  additionalProperties?: boolean;
  [key: string]: unknown;
}

export interface ExpectDef {
  status: number;
  body_schema?: BodySchema;
}

export interface CaseRef {
  case_ref: string; // "catalog_id#case_id"
}

export interface SetupDef {
  user?: 'fresh' | 'shared' | 'none';
  preconditions?: CaseRef[];
}

export interface CaseDefinition {
  id: string;
  name: string;
  request: RequestDef;
  expect: ExpectDef;
  setup_override?: SetupDef;
  capture_fixture?: boolean;
  fixture_mask?: string[];
}

// flow 타입 — steps 기반
export interface FlowStep {
  step: string;
  description?: string;
  case_ref?: string;
  request?: RequestDef;
  expect?: ExpectDef;
  capture_fixture?: boolean;
  fixture_mask?: string[];
}

export interface CatalogFile {
  schema_version: number;
  target: string; // "endpoint:POST /foo" | "flow:name"
  spec_section?: string;
  phase?: string;
  feature?: string | string[];
  storyboard?: unknown;
  setup?: SetupDef;
  cases?: CaseDefinition[];
  steps?: FlowStep[]; // flow 타입
  dynamic?: unknown;
  screen_targets?: unknown[];
  meta?: unknown;
}

// 실행 컨텍스트 — case_ref 체인에서 토큰/응답 전달
export interface ExecutionContext {
  token: string | null;
  lastResponse: unknown;
  freshEmail?: string; // user: fresh 할당 이메일 ({{fresh_email}} 치환용)
  userId?: number;
}

// 케이스 실행 결과
export interface CaseResult {
  caseId: string;
  caseName: string;
  pass: boolean;
  status?: number;
  expectedStatus?: number;
  schemaErrors?: string[];
  fixture?: string; // 저장된 fixture 경로
  error?: string;
}

// 스테이지 결과
export interface StageResult {
  total: number;
  pass: number;
  fail: number;
  cases: CaseResult[];
}

// 전체 실행 보고서
export interface RunReport {
  schema_version: 1;
  ran_at: string;
  target: string;
  git_head?: string;
  stages: {
    static?: { backend?: string; flutter?: string };
    unit?: StageResult;
    contract?: StageResult;
    dynamic?: StageResult;
  };
}
