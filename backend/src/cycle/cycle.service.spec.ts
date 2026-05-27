import { calculateCyclePhase } from './cycle.service';

describe('calculateCyclePhase', () => {
  function daysAgo(n: number): string {
    const d = new Date();
    d.setDate(d.getDate() - n);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }

  it('[경계] day 1 → menstrual', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(0), 5);
    expect(phase).toBe('menstrual');
    expect(dayOfCycle).toBe(1);
  });

  it('[경계] day 5 (periodLength=5) → menstrual 마지막 날', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(4), 5);
    expect(phase).toBe('menstrual');
    expect(dayOfCycle).toBe(5);
  });

  it('[경계] day 6 (periodLength=5) → follicular 시작', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(5), 5);
    expect(phase).toBe('follicular');
    expect(dayOfCycle).toBe(6);
  });

  it('[경계] day 13 → follicular 마지막 날', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(12), 5);
    expect(phase).toBe('follicular');
    expect(dayOfCycle).toBe(13);
  });

  it('[경계] day 14 → ovulation 시작', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(13), 5);
    expect(phase).toBe('ovulation');
    expect(dayOfCycle).toBe(14);
  });

  it('[경계] day 15 → ovulation 마지막 날', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(14), 5);
    expect(phase).toBe('ovulation');
    expect(dayOfCycle).toBe(15);
  });

  it('[경계] day 16 → luteal 시작', () => {
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(15), 5);
    expect(phase).toBe('luteal');
    expect(dayOfCycle).toBe(16);
  });

  it('[Happy] 기간 7일인 경우 day 7 → menstrual', () => {
    const { phase } = calculateCyclePhase(daysAgo(6), 7);
    expect(phase).toBe('menstrual');
  });

  // ── 회귀 방지: 경과/범위초과 안전 처리 (P0-1·P0-2) ──
  it('[회귀] 한 주기(28일) 경과 → dayOfCycle 롤오버(음수/초과 없음)', () => {
    // 30일 전 시작 → rawDay 31 → 28로 롤오버 → 3일차
    const { phase, dayOfCycle } = calculateCyclePhase(daysAgo(30), 5, 28);
    expect(dayOfCycle).toBe(3);
    expect(phase).toBe('menstrual');
  });

  it('[회귀] 두 주기 이상 경과해도 dayOfCycle은 항상 1..cycleLength', () => {
    const { dayOfCycle } = calculateCyclePhase(daysAgo(60), 5, 28);
    expect(dayOfCycle).toBeGreaterThanOrEqual(1);
    expect(dayOfCycle).toBeLessThanOrEqual(28);
  });

  it('[회귀] 기준일이 시작일 이전(이전 월 캘린더) → 음수 아닌 양수 dayOfCycle', () => {
    // 오늘 시작, 기준일 5일 전 → rawDay -4 → 안전 모듈로로 양수
    const start = daysAgo(0);
    const ref = new Date();
    ref.setDate(ref.getDate() - 5);
    const { dayOfCycle } = calculateCyclePhase(start, 5, 28, ref);
    expect(dayOfCycle).toBeGreaterThanOrEqual(1);
    expect(dayOfCycle).toBeLessThanOrEqual(28);
  });
});
