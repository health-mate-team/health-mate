import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import { CatalogFile, CaseDefinition, FlowStep, SetupDef } from './types';

const VERIFY_CASES_DIR = path.resolve(__dirname, '../../../docs/verify-cases');

export function catalogPath(catalogId: string): string {
  return path.join(VERIFY_CASES_DIR, `${catalogId}.yaml`);
}

export function loadCatalog(catalogId: string): CatalogFile {
  const filePath = catalogPath(catalogId);
  if (!fs.existsSync(filePath)) {
    throw new Error(`[run-cases] 카탈로그 없음: ${filePath} (exit code 2)`);
  }
  const raw = yaml.load(fs.readFileSync(filePath, 'utf-8')) as CatalogFile;
  validateCatalog(raw, catalogId);
  return raw;
}

function validateCatalog(catalog: CatalogFile, catalogId: string): void {
  if (!catalog.schema_version) {
    throw new Error(`[run-cases] ${catalogId}: schema_version 누락`);
  }
  if (!catalog.target) {
    throw new Error(`[run-cases] ${catalogId}: target 누락`);
  }
  const isFlow = catalog.target.startsWith('flow:');
  if (isFlow) {
    if (!catalog.steps || !Array.isArray(catalog.steps)) {
      throw new Error(`[run-cases] ${catalogId}: flow 카탈로그에 steps 배열 없음`);
    }
  } else {
    if (!catalog.cases || !Array.isArray(catalog.cases)) {
      throw new Error(`[run-cases] ${catalogId}: endpoint 카탈로그에 cases 배열 없음`);
    }
  }
}

export function isFlow(catalog: CatalogFile): boolean {
  return catalog.target.startsWith('flow:');
}

export function getCases(catalog: CatalogFile): CaseDefinition[] {
  if (!catalog.cases) return [];
  return catalog.cases;
}

export function getSteps(catalog: CatalogFile): FlowStep[] {
  if (!catalog.steps) return [];
  return catalog.steps;
}

// case_ref 형식: "catalog_id#case_id"
export function parseCaseRef(caseRef: string): { catalogId: string; caseId: string } {
  const sep = caseRef.lastIndexOf('#');
  if (sep < 0) throw new Error(`[run-cases] case_ref 형식 오류: '${caseRef}' (예: auth_register#happy)`);
  return {
    catalogId: caseRef.slice(0, sep),
    caseId: caseRef.slice(sep + 1),
  };
}

// 케이스 단위 setup: case.setup_override 또는 case.setup(레거시) 필드 통합 인식
export function getCaseSetup(caseDef: CaseDefinition): SetupDef | undefined {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const raw = caseDef as any;
  return caseDef.setup_override ?? raw['setup'] as SetupDef | undefined;
}

export function findCase(catalog: CatalogFile, caseId: string): CaseDefinition {
  const found = (catalog.cases ?? []).find((c) => c.id === caseId);
  if (!found) {
    throw new Error(`[run-cases] case '${caseId}'를 카탈로그 '${catalog.target}'에서 찾을 수 없음`);
  }
  return found;
}
