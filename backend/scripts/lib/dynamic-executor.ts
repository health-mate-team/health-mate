import * as http from 'http';
import * as https from 'https';
import {
  CaseDefinition,
  CaseResult,
  CatalogFile,
  ExecutionContext,
  StageResult,
  SetupDef,
} from './types';
import { getCases, isFlow, getSteps, parseCaseRef, findCase, loadCatalog, getCaseSetup } from './catalog-loader';
import { loadMaskedFixture, applyMask } from './fixture-store';

const DEFAULT_BASE_URL = process.env.DYNAMIC_BASE_URL ?? 'http://localhost:3001';

async function httpRequest(
  method: string,
  url: string,
  body?: Record<string, unknown>,
  headers?: Record<string, string>,
): Promise<{ status: number; body: unknown }> {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const lib = parsed.protocol === 'https:' ? https : http;
    const payload = body ? JSON.stringify(body) : undefined;
    const reqHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      ...headers,
    };
    if (payload) reqHeaders['Content-Length'] = Buffer.byteLength(payload).toString();

    const req = lib.request(
      {
        hostname: parsed.hostname,
        port: parsed.port,
        path: parsed.pathname + parsed.search,
        method,
        headers: reqHeaders,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk: string) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode ?? 0, body: JSON.parse(data) });
          } catch {
            resolve({ status: res.statusCode ?? 0, body: data });
          }
        });
      },
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function freshDynamicEmail(): string {
  return `dyn_${Date.now()}_${Math.floor(Math.random() * 9999)}@run-cases.app`;
}

function substituteBody(
  body: Record<string, unknown> | undefined,
  freshEmail: string,
): Record<string, unknown> | undefined {
  if (!body) return body;
  return JSON.parse(JSON.stringify(body, (_k, v) =>
    v === '{{fresh_email}}' ? freshEmail : v,
  ));
}

function bodyHasFreshEmailTemplate(body: Record<string, unknown> | undefined): boolean {
  if (!body) return false;
  return JSON.stringify(body).includes('{{fresh_email}}');
}

async function registerFreshUser(baseUrl: string, freshEmail: string): Promise<string> {
  const res = await httpRequest('POST', `${baseUrl}/api/auth/register`, {
    email: freshEmail,
    password: 'Test1234!',
    name: '다이나믹테스터',
  });
  if (res.status !== 201) {
    throw new Error(`[dynamic] 사용자 등록 실패: ${res.status}`);
  }
  return ((res.body as Record<string, unknown>)['data'] as Record<string, unknown>)['access_token'] as string;
}

// precondition chain용: 케이스의 setup을 재귀적으로 처리한 뒤 케이스 실행
async function runDynamicCase(
  caseRef: string,
  baseUrl: string,
  token: string | null,
  freshEmail?: string,
): Promise<{ status: number; body: unknown; token: string | null }> {
  const { catalogId, caseId } = parseCaseRef(caseRef);
  const catalog = loadCatalog(catalogId);
  const caseDef = findCase(catalog, caseId);
  const caseSetup = getCaseSetup(caseDef) ?? catalog.setup;
  const email = freshEmail ?? freshDynamicEmail();
  let caseToken = token;

  // token이 없을 때만 setup 처리 (상위 호출이 이미 token을 전달한 경우 재사용)
  if (!caseToken) {
    const hasPreconditions = (caseSetup?.preconditions ?? []).length > 0;
    if (caseSetup?.user === 'fresh') {
      if (bodyHasFreshEmailTemplate(caseDef.request.body)) {
        // 케이스 자체가 가입 요청 — 사전 등록 X
      } else if (!hasPreconditions) {
        caseToken = await registerFreshUser(baseUrl, email);
      }
    }
    caseToken = await execPreconditions(caseSetup, baseUrl, caseToken, email);
  }

  const { method, path, body, auth } = caseDef.request;
  const substituted = substituteBody(body, email);
  const headers: Record<string, string> = {};
  if (auth === 'required' && caseToken) {
    headers['Authorization'] = `Bearer ${caseToken}`;
  }
  const res = await httpRequest(method, `${baseUrl}/api${path}`, substituted, headers);
  const newToken =
    ((res.body as Record<string, unknown>)?.['data'] as Record<string, unknown>)?.['access_token'] as string | undefined ??
    caseToken;
  return { status: res.status, body: res.body, token: newToken };
}

// 사전조건 체인 실행 (DYNAMIC: Docker 서버 대상)
async function execPreconditions(
  setup: SetupDef | undefined,
  baseUrl: string,
  token: string | null,
  freshEmail?: string,
): Promise<string | null> {
  let currentToken = token;
  for (const precond of setup?.preconditions ?? []) {
    const res = await runDynamicCase(precond.case_ref, baseUrl, currentToken, freshEmail);
    currentToken = res.token;
  }
  return currentToken;
}

export async function runDynamicStage(
  catalog: CatalogFile,
  targetId: string,
  baseUrl = DEFAULT_BASE_URL,
): Promise<StageResult> {
  const results: CaseResult[] = [];

  if (isFlow(catalog)) {
    const flowEmail = freshDynamicEmail();
    let token: string | null = await registerFreshUser(baseUrl, flowEmail);
    for (const step of getSteps(catalog)) {
      if (step.case_ref) {
        const res = await runDynamicCase(step.case_ref, baseUrl, token, flowEmail);
        token = res.token;
        results.push({ caseId: step.step, caseName: step.description ?? step.step, pass: true });
      } else if (step.request && step.expect) {
        const syntheticCase: CaseDefinition = {
          id: step.step, name: step.description ?? step.step,
          request: step.request, expect: step.expect,
        };
        const r = await runOneCaseDynamic(syntheticCase, baseUrl, token, targetId, flowEmail);
        results.push(r.result);
        if (r.token) token = r.token;
      }
    }
  } else {
    for (const caseDef of getCases(catalog)) {
      let token: string | null = null;
      const setup = getCaseSetup(caseDef) ?? catalog.setup;
      const freshEmail = freshDynamicEmail();

      if (setup?.user === 'fresh') {
        const hasPreconditions = (setup.preconditions ?? []).length > 0;
        if (bodyHasFreshEmailTemplate(caseDef.request.body)) {
          // 케이스 자체가 가입 요청 — body에 이메일 치환만, 사전 등록 X
        } else if (!hasPreconditions) {
          // preconditions가 없는 경우만 registerFreshUser (preconditions에서 token 획득 예정이면 skip)
          token = await registerFreshUser(baseUrl, freshEmail);
        }
      }
      token = await execPreconditions(setup, baseUrl, token, freshEmail);

      const r = await runOneCaseDynamic(caseDef, baseUrl, token, targetId, freshEmail);
      results.push(r.result);
    }
  }

  const pass = results.filter((r) => r.pass).length;
  return { total: results.length, pass, fail: results.length - pass, cases: results };
}

async function runOneCaseDynamic(
  caseDef: CaseDefinition,
  baseUrl: string,
  token: string | null,
  targetId: string,
  freshEmail?: string,
): Promise<{ result: CaseResult; token: string | null }> {
  try {
    const { method, path, body, auth } = caseDef.request;
    const email = freshEmail ?? freshDynamicEmail();
    const substituted = substituteBody(body, email);
    const headers: Record<string, string> = {};
    if (auth === 'required' && token) headers['Authorization'] = `Bearer ${token}`;

    const res = await httpRequest(method, `${baseUrl}/api${path}`, substituted, headers);
    const statusPass = res.status === caseDef.expect.status;

    // UNIT fixture와 비교하여 drift 검출 (마스킹 버전 사용)
    const unitFixture = loadMaskedFixture(targetId, caseDef.id);
    let driftErrors: string[] = [];
    if (unitFixture && statusPass) {
      const masked = applyMask(res.body, caseDef.fixture_mask ?? []);
      const unitStr = JSON.stringify(unitFixture);
      const dynStr = JSON.stringify(masked);
      if (unitStr !== dynStr) {
        driftErrors = ['DYNAMIC vs UNIT fixture drift 감지 — 상세 비교 필요'];
      }
    }

    const newToken =
      ((res.body as Record<string, unknown>)?.['data'] as Record<string, unknown>)?.['access_token'] as string | undefined ??
      token;

    return {
      result: {
        caseId: caseDef.id,
        caseName: caseDef.name,
        pass: statusPass && driftErrors.length === 0,
        status: res.status,
        expectedStatus: caseDef.expect.status,
        schemaErrors: driftErrors,
      },
      token: newToken,
    };
  } catch (err) {
    return {
      result: {
        caseId: caseDef.id,
        caseName: caseDef.name,
        pass: false,
        error: (err as Error).message,
      },
      token,
    };
  }
}
