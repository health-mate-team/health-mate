// eslint-disable-next-line @typescript-eslint/no-require-imports
const supertest = require('supertest') as typeof import('supertest');
import { INestApplication } from '@nestjs/common';
import {
  CaseDefinition,
  CaseResult,
  CatalogFile,
  ExecutionContext,
  SetupDef,
  StageResult,
} from './types';
import {
  getCachedContext,
  setCachedContext,
  freshContext,
  clearCache,
} from './case-ref-resolver';
import {
  loadCatalog,
  parseCaseRef,
  findCase,
  getCases,
  getSteps,
  isFlow,
  getCaseSetup,
} from './catalog-loader';
import { saveFixture, loadFixture } from './fixture-store';
import { parseCaseRef as _parseCaseRef } from './catalog-loader';
import { v4 as uuidv4 } from 'uuid';

// ─── 중첩 필드 추출 (dot-path) ───────────────────────────────
function getNestedValue(obj: unknown, path: string): unknown {
  const parts = path.split('.');
  let cur = obj;
  for (const part of parts) {
    if (cur === null || cur === undefined) return undefined;
    cur = (cur as Record<string, unknown>)[part];
  }
  return cur;
}

// ─── {{fresh_email}} + {{fixture:catalog#case.field}} 치환 ───
function substituteBody(
  body: Record<string, unknown> | undefined,
  ctx: ExecutionContext,
): Record<string, unknown> | undefined {
  if (!body) return body;
  const email = ctx.freshEmail ?? '';
  return JSON.parse(JSON.stringify(body, (_k, v) => {
    if (typeof v !== 'string') return v;
    if (v === '{{fresh_email}}') return email;
    if (v === '{{now}}') return new Date().toISOString();
    if (v === '{{today}}') return new Date().toISOString().slice(0, 10);
    const fixtureMatch = v.match(/^\{\{fixture:([^#]+)#([^.]+)\.(.+)\}\}$/);
    if (fixtureMatch) {
      const [, catalogId, caseId, fieldPath] = fixtureMatch;
      const fixture = loadFixture(catalogId, caseId);
      if (!fixture) return v;
      // data 래퍼 있으면 data 안에서 찾기
      const fromData = getNestedValue((fixture as Record<string, unknown>)['data'], fieldPath);
      if (fromData !== undefined) return fromData;
      return getNestedValue(fixture, fieldPath) ?? v;
    }
    return v;
  }));
}

function extractToken(body: unknown): string | null {
  if (!body || typeof body !== 'object') return null;
  const data = (body as Record<string, unknown>)['data'] as Record<string, unknown> | undefined;
  if (data?.['access_token'] && typeof data['access_token'] === 'string') {
    return data['access_token'] as string;
  }
  return null;
}

interface RequestResult {
  status: number;
  responseBody: unknown;
}

async function executeRequest(
  app: INestApplication,
  caseDef: CaseDefinition,
  ctx: ExecutionContext,
): Promise<RequestResult> {
  const { method, path, body, query, auth } = caseDef.request;
  const apiPath = `/api${path}`;
  const substitutedBody = substituteBody(body, ctx);

  let req = supertest(app.getHttpServer())[
    method.toLowerCase() as 'get' | 'post' | 'patch' | 'put' | 'delete'
  ](apiPath);

  if (auth === 'required' && ctx.token) {
    req = req.set('Authorization', `Bearer ${ctx.token}`);
  }
  if (query) req = req.query(query);
  if (substitutedBody && ['POST', 'PUT', 'PATCH'].includes(method)) {
    req = req.send(substitutedBody);
  }

  const res = await req;
  return { status: res.status, responseBody: res.body };
}

// ─── 사전조건 실행 ──────────────────────────────────────────
async function runPrecondition(
  app: INestApplication,
  caseRef: string,
  chainRootId: string,
  ctx: ExecutionContext,
): Promise<ExecutionContext> {
  const cached = getCachedContext(chainRootId, caseRef);
  if (cached) return { ...cached, freshEmail: ctx.freshEmail }; // freshEmail은 체인 전파

  const { catalogId, caseId } = parseCaseRef(caseRef);
  const catalog = loadCatalog(catalogId);
  const caseDef = findCase(catalog, caseId);

  const setup: SetupDef | undefined = getCaseSetup(caseDef) ?? catalog.setup;
  let localCtx = { ...ctx };

  // user: fresh → freshEmail 할당 (이미 있으면 유지)
  if (setup?.user === 'fresh' && !localCtx.freshEmail) {
    localCtx = { ...freshContext(), token: localCtx.token };
  } else if (setup?.user === 'none') {
    localCtx = { token: null, lastResponse: null };
  }

  // 사전조건의 사전조건 실행
  for (const precond of setup?.preconditions ?? []) {
    localCtx = await runPrecondition(app, precond.case_ref, chainRootId, localCtx);
  }

  // 실제 케이스 실행 ({{fresh_email}} 치환 포함)
  const result = await executeRequest(app, caseDef, localCtx);
  const newToken = extractToken(result.responseBody) ?? localCtx.token;
  const newCtx: ExecutionContext = {
    token: newToken,
    lastResponse: result.responseBody,
    freshEmail: localCtx.freshEmail,
  };

  // 사전조건도 capture_fixture 설정이 있으면 fixture 저장 ({{fixture:...}} 치환 지원)
  if (caseDef.capture_fixture !== false) {
    const maskPaths = caseDef.fixture_mask ?? [];
    saveFixture(catalogId, caseId, result.responseBody, maskPaths);
  }

  setCachedContext(chainRootId, caseRef, newCtx);
  return newCtx;
}

// ─── 케이스 단위 실행 ───────────────────────────────────────
async function runCase(
  app: INestApplication,
  catalog: CatalogFile,
  caseDef: CaseDefinition,
  parentCtx: ExecutionContext,
  chainRootId: string,
  targetId: string,
): Promise<CaseResult> {
  try {
    const setup: SetupDef | undefined = getCaseSetup(caseDef) ?? catalog.setup;
    let ctx = { ...parentCtx };

    // user: fresh → freshContext + 새 chainRootId로 캐시 격리 (이전 케이스 캐시 오염 방지)
    let effectiveChainRootId = chainRootId;
    if (setup?.user === 'fresh') {
      ctx = freshContext();
      effectiveChainRootId = uuidv4();
    } else if (setup?.user === 'none') {
      ctx = { token: null, lastResponse: null };
    }

    // 사전조건 순차 실행
    for (const precond of setup?.preconditions ?? []) {
      ctx = await runPrecondition(app, precond.case_ref, effectiveChainRootId, ctx);
    }

    // 실제 케이스 실행
    const { status, responseBody } = await executeRequest(app, caseDef, ctx);

    // 토큰 갱신 (auth/register, auth/login 응답에서 추출)
    const newToken = extractToken(responseBody) ?? ctx.token;

    // 상태 코드 검증
    const expectedStatus = caseDef.expect.status;
    const statusPass = status === expectedStatus;

    // fixture 저장
    let fixtureSavedPath: string | undefined;
    if (caseDef.capture_fixture !== false && statusPass) {
      const maskPaths = caseDef.fixture_mask ?? [];
      fixtureSavedPath = saveFixture(targetId, caseDef.id, responseBody, maskPaths);
    }

    return {
      caseId: caseDef.id,
      caseName: caseDef.name,
      pass: statusPass,
      status,
      expectedStatus,
      schemaErrors: statusPass
        ? []
        : [`상태 코드 불일치: 기대 ${expectedStatus}, 실제 ${status}`],
      fixture: fixtureSavedPath,
    };
  } catch (err) {
    return {
      caseId: caseDef.id,
      caseName: caseDef.name,
      pass: false,
      error: (err as Error).message,
    };
  }
}

// ─── UNIT Stage 진입점 ──────────────────────────────────────
export async function runUnitStage(
  app: INestApplication,
  catalog: CatalogFile,
  targetId: string,
): Promise<StageResult> {
  clearCache();
  const results: CaseResult[] = [];
  const chainRootId = uuidv4();

  if (isFlow(catalog)) {
    results.push(...(await runFlowSteps(app, catalog, chainRootId, targetId)));
  } else {
    for (const caseDef of getCases(catalog)) {
      const parentCtx: ExecutionContext = { token: null, lastResponse: null };
      const result = await runCase(app, catalog, caseDef, parentCtx, chainRootId, targetId);
      results.push(result);
    }
  }

  const pass = results.filter((r) => r.pass).length;
  return { total: results.length, pass, fail: results.length - pass, cases: results };
}

// ─── Flow 스텝 실행 ─────────────────────────────────────────
async function runFlowSteps(
  app: INestApplication,
  catalog: CatalogFile,
  chainRootId: string,
  targetId: string,
): Promise<CaseResult[]> {
  const results: CaseResult[] = [];
  // flow 전체 공유 컨텍스트 — freshEmail 포함
  let sharedCtx: ExecutionContext = freshContext();

  // setup preconditions (onboarding_complete#happy → auth_register#happy 포함)
  for (const precond of catalog.setup?.preconditions ?? []) {
    sharedCtx = await runPrecondition(app, precond.case_ref, chainRootId, sharedCtx);
  }

  for (const step of getSteps(catalog)) {
    if (step.case_ref) {
      sharedCtx = await runPrecondition(app, step.case_ref, chainRootId, sharedCtx);
      results.push({
        caseId: step.step,
        caseName: step.description ?? step.step,
        pass: true,
      });
    } else if (step.request && step.expect) {
      const syntheticCase: CaseDefinition = {
        id: step.step,
        name: step.description ?? step.step,
        request: step.request,
        expect: step.expect,
        capture_fixture: step.capture_fixture,
        fixture_mask: step.fixture_mask,
      };
      const result = await runCase(app, catalog, syntheticCase, sharedCtx, chainRootId, targetId);
      results.push(result);
    }
  }

  return results;
}
