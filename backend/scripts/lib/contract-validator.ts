import Ajv from 'ajv';
import { CaseDefinition, CaseResult, CatalogFile, StageResult } from './types';
import { getCases, isFlow, getSteps } from './catalog-loader';
import { loadFixture } from './fixture-store';

const ajv = new Ajv({ allErrors: true });

// 2xx → body.data 검증, 4xx/5xx → body 그대로 검증
function getValidationTarget(status: number, body: unknown): unknown {
  if (status >= 200 && status < 300) {
    return (body as Record<string, unknown>)?.['data'] ?? body;
  }
  return body;
}

function validateSchema(
  caseId: string,
  caseDef: CaseDefinition,
  targetId: string,
): CaseResult {
  const schema = caseDef.expect.body_schema;
  if (!schema) {
    return { caseId, caseName: caseDef.name, pass: true };
  }

  const fixture = loadFixture(targetId, caseId);
  if (!fixture) {
    return {
      caseId,
      caseName: caseDef.name,
      pass: false,
      schemaErrors: [`fixture 없음: .verify-cache/${targetId}/${caseId}.json`],
    };
  }

  const expectedStatus = caseDef.expect.status;
  const validateTarget = getValidationTarget(expectedStatus, fixture);
  const validate = ajv.compile(schema);
  const valid = validate(validateTarget);

  if (valid) {
    return { caseId, caseName: caseDef.name, pass: true };
  }

  const errors = (validate.errors ?? []).map(
    (e) => `${e.dataPath || '(root)'}: ${e.message}`,
  );
  return {
    caseId,
    caseName: caseDef.name,
    pass: false,
    schemaErrors: errors,
  };
}

export function runContractStage(
  catalog: CatalogFile,
  targetId: string,
): StageResult {
  const results: CaseResult[] = [];

  if (isFlow(catalog)) {
    // flow 타입: 인라인 request가 있는 스텝만 검증
    for (const step of getSteps(catalog)) {
      if (step.request && step.expect?.body_schema) {
        const syntheticCase: CaseDefinition = {
          id: step.step,
          name: step.description ?? step.step,
          request: step.request,
          expect: step.expect,
        };
        results.push(validateSchema(step.step, syntheticCase, targetId));
      }
    }
  } else {
    for (const caseDef of getCases(catalog)) {
      // capture_fixture: false인 케이스는 CONTRACT 검증 제외
      if (caseDef.capture_fixture === false) continue;
      // body_schema 없으면 PASS
      if (!caseDef.expect.body_schema) continue;
      results.push(validateSchema(caseDef.id, caseDef, targetId));
    }
  }

  const pass = results.filter((r) => r.pass).length;
  return { total: results.length, pass, fail: results.length - pass, cases: results };
}
