import { loadCatalog, parseCaseRef, findCase } from './catalog-loader';
import { CaseDefinition, CatalogFile, ExecutionContext, SetupDef } from './types';

const MAX_DEPTH = 5;

export interface ResolvedCase {
  catalogId: string;
  caseId: string;
  catalog: CatalogFile;
  caseDef: CaseDefinition;
  preconditions: ResolvedCase[];
}

// 의존성 그래프 빌드 + 사이클/깊이 검출
export function resolveCase(
  caseRef: string,
  visitStack: string[] = [],
  depth = 0,
): ResolvedCase {
  if (depth > MAX_DEPTH) {
    throw new Error(
      `[run-cases] case_ref 최대 깊이 초과 (${MAX_DEPTH}): ${caseRef} — 체인: ${visitStack.join(' → ')}`,
    );
  }
  if (visitStack.includes(caseRef)) {
    throw new Error(
      `[run-cases] 사이클 감지 (DAG 위반): ${caseRef} — 체인: ${visitStack.join(' → ')}`,
    );
  }

  const { catalogId, caseId } = parseCaseRef(caseRef);
  const catalog = loadCatalog(catalogId);
  const caseDef = findCase(catalog, caseId);

  const setup = caseDef.setup_override ?? catalog.setup;
  const preconditionRefs = getSetupPreconditions(setup);

  const nextStack = [...visitStack, caseRef];
  const preconditions = preconditionRefs.map((ref) =>
    resolveCase(ref, nextStack, depth + 1),
  );

  return { catalogId, caseId, catalog, caseDef, preconditions };
}

function getSetupPreconditions(setup?: SetupDef): string[] {
  if (!setup?.preconditions) return [];
  return setup.preconditions.map((p) => p.case_ref);
}

// ─── ExecutionContext 캐시 ──────────────────────────────
// 캐시 키: `${chainRootId}::${catalogId}#${caseId}`
// 동일 최상위 체인 내에서 동일 case_ref는 한 번만 실행
const contextCache = new Map<string, ExecutionContext>();

export function makeCacheKey(chainRootId: string, caseRef: string): string {
  return `${chainRootId}::${caseRef}`;
}

export function getCachedContext(
  chainRootId: string,
  caseRef: string,
): ExecutionContext | undefined {
  return contextCache.get(makeCacheKey(chainRootId, caseRef));
}

export function setCachedContext(
  chainRootId: string,
  caseRef: string,
  ctx: ExecutionContext,
): void {
  contextCache.set(makeCacheKey(chainRootId, caseRef), ctx);
}

export function clearCache(): void {
  contextCache.clear();
}

// 새 사용자 컨텍스트 (fresh user) — 이메일 할당, 토큰은 auth_register 케이스 실행 후 획득
export function freshContext(): ExecutionContext {
  const ts = Date.now();
  const rand = Math.floor(Math.random() * 9999);
  return { token: null, lastResponse: null, freshEmail: `test_${ts}_${rand}@run-cases.app` };
}
