import * as fs from 'fs';
import * as path from 'path';

const CACHE_DIR = path.resolve(__dirname, '../../../.verify-cache');

export function fixturePath(targetId: string, caseId: string): string {
  return path.join(CACHE_DIR, targetId, `${caseId}.json`);
}

export function maskedFixturePath(targetId: string, caseId: string): string {
  return path.join(CACHE_DIR, targetId, `${caseId}.masked.json`);
}

// fixture_mask: 점(.) 경로로 지정된 필드를 "<MASKED>"로 치환.
// 카탈로그에서 fixture_mask 경로는 data 내부 기준으로 지정한다.
// 응답이 {data: {...}} 래핑 구조인 경우 자동으로 data. prefix를 시도한다.
export function applyMask(data: unknown, maskPaths: string[]): unknown {
  if (!maskPaths.length) return data;
  const clone = JSON.parse(JSON.stringify(data));
  const hasDataWrapper =
    clone && typeof clone === 'object' && 'data' in (clone as object);
  for (const maskPath of maskPaths) {
    const parts = maskPath.split('.');
    // 이미 'data.' prefix가 있으면 그대로, 없고 data 래퍼가 있으면 data 안에서 시도
    if (hasDataWrapper && parts[0] !== 'data') {
      setNestedMask((clone as Record<string, unknown>)['data'] as Record<string, unknown>, parts);
    } else {
      setNestedMask(clone, parts);
    }
  }
  return clone;
}

function setNestedMask(obj: Record<string, unknown>, parts: string[]): void {
  if (!obj || typeof obj !== 'object') return;
  const [head, ...rest] = parts;
  if (rest.length === 0) {
    if (head in (obj as object)) {
      (obj as Record<string, unknown>)[head] = '<MASKED>';
    }
  } else {
    setNestedMask((obj as Record<string, unknown>)[head] as Record<string, unknown>, rest);
  }
}

export function saveFixture(
  targetId: string,
  caseId: string,
  rawBody: unknown,
  maskPaths: string[],
): string {
  const dir = path.join(CACHE_DIR, targetId);
  fs.mkdirSync(dir, { recursive: true });
  // 원본(마스킹 안 됨) → CONTRACT 검증용
  fs.writeFileSync(fixturePath(targetId, caseId), JSON.stringify(rawBody, null, 2), 'utf-8');
  // 마스킹 버전 → DYNAMIC 비교용
  if (maskPaths.length > 0) {
    const masked = applyMask(rawBody, maskPaths);
    fs.writeFileSync(maskedFixturePath(targetId, caseId), JSON.stringify(masked, null, 2), 'utf-8');
  }
  return fixturePath(targetId, caseId);
}

// CONTRACT 검증용: 원본 fixture
export function loadFixture(targetId: string, caseId: string): unknown {
  const filePath = fixturePath(targetId, caseId);
  if (!fs.existsSync(filePath)) return null;
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

// DYNAMIC 비교용: 마스킹된 fixture (없으면 원본 fallback)
export function loadMaskedFixture(targetId: string, caseId: string): unknown {
  const masked = maskedFixturePath(targetId, caseId);
  if (fs.existsSync(masked)) return JSON.parse(fs.readFileSync(masked, 'utf-8'));
  return loadFixture(targetId, caseId);
}
