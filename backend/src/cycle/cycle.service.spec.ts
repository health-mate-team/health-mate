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
});
