import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { UpdateCycleSettingsDto } from './dto/update-cycle-settings.dto';

export enum CyclePhase {
  Menstrual = 'menstrual',
  Follicular = 'follicular',
  Ovulation = 'ovulation',
  Luteal = 'luteal',
}

export function parseLocalDate(dateStr: string): Date {
  const [y, m, d] = dateStr.split('-').map(Number);
  return new Date(y, m - 1, d);
}

export function localDateString(d = new Date()): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

const MS_PER_DAY = 1000 * 60 * 60 * 24;

// JS %는 피연산자 부호를 보존하므로 음수 입력 시 음수 나머지가 나온다.
// 항상 [0, m) 범위를 보장하는 안전 모듈로.
function safeMod(n: number, m: number): number {
  return ((n % m) + m) % m;
}

const DEFAULT_CYCLE_LENGTH = 28;

/**
 * 기준일(referenceDate, 기본=오늘) 시점의 사이클 내 위치를 계산한다.
 * dayOfCycle은 averageCycleLength로 롤오버되어 항상 1..cycleLength 범위를 보장한다
 * (한 주기 이상 경과·기준일이 시작일 이전인 경우에도 음수/범위초과 없음).
 */
export function calculateCyclePhase(
  lastPeriodStart: string,
  periodLength: number,
  cycleLength: number = DEFAULT_CYCLE_LENGTH,
  referenceDate: Date = parseLocalDate(localDateString()),
): { phase: CyclePhase; dayOfCycle: number } {
  const start = parseLocalDate(lastPeriodStart);
  const rawDay =
    Math.floor((referenceDate.getTime() - start.getTime()) / MS_PER_DAY) + 1;
  const dayOfCycle = safeMod(rawDay - 1, cycleLength) + 1;

  let phase: CyclePhase;
  if (dayOfCycle <= periodLength) phase = CyclePhase.Menstrual;
  else if (dayOfCycle <= 13) phase = CyclePhase.Follicular;
  else if (dayOfCycle <= 15) phase = CyclePhase.Ovulation;
  else phase = CyclePhase.Luteal;

  return { phase, dayOfCycle };
}

@Injectable()
export class CycleService {
  constructor(
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
  ) {}

  private async findCycle(userId: string): Promise<UserCycle> {
    const cycle = await this.cycleRepo.findOne({ where: { userId } });
    if (!cycle)
      throw new NotFoundException(
        '사이클 정보가 없습니다. 온보딩을 먼저 완료해주세요.',
      );
    return cycle;
  }

  async getCurrent(user: User) {
    const cycle = await this.findCycle(user.id);
    const { phase, dayOfCycle } = calculateCyclePhase(
      cycle.lastPeriodStartDate,
      cycle.averagePeriodLength,
      cycle.averageCycleLength,
    );

    // 경과 일수를 주기 길이로 롤오버 → 다음 예정일은 항상 미래(1..cycleLength일).
    const start = parseLocalDate(cycle.lastPeriodStartDate);
    const today = parseLocalDate(localDateString());
    const daysSince = Math.floor(
      (today.getTime() - start.getTime()) / MS_PER_DAY,
    );
    const daysUntilNextPeriod =
      cycle.averageCycleLength - safeMod(daysSince, cycle.averageCycleLength);
    const nextPeriodDate = new Date(today);
    nextPeriodDate.setDate(nextPeriodDate.getDate() + daysUntilNextPeriod);

    return {
      current_phase: phase,
      day_of_cycle: dayOfCycle,
      days_until_next_period: daysUntilNextPeriod,
      next_period_date: localDateString(nextPeriodDate),
      average_cycle_length: cycle.averageCycleLength,
      average_period_length: cycle.averagePeriodLength,
      is_irregular: cycle.isIrregular,
      goal_type: cycle.goalType,
    };
  }

  async updateSettings(user: User, dto: UpdateCycleSettingsDto) {
    const cycle = await this.findCycle(user.id);
    if (dto.last_period_start_date)
      cycle.lastPeriodStartDate = dto.last_period_start_date;
    if (dto.average_cycle_length !== undefined)
      cycle.averageCycleLength = dto.average_cycle_length;
    if (dto.average_period_length !== undefined)
      cycle.averagePeriodLength = dto.average_period_length;
    if (dto.is_irregular !== undefined) cycle.isIrregular = dto.is_irregular;
    if (dto.goal_type) cycle.goalType = dto.goal_type;
    await this.cycleRepo.save(cycle);
    return this.getCurrent(user);
  }

  async getCalendar(user: User, year: number, month: number) {
    const cycle = await this.findCycle(user.id);
    const daysInMonth = new Date(year, month, 0).getDate();
    const days: Array<{
      date: string;
      phase: CyclePhase;
      day_of_cycle: number;
    }> = [];

    for (let d = 1; d <= daysInMonth; d++) {
      const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const { phase, dayOfCycle } = calculateCyclePhase(
        cycle.lastPeriodStartDate,
        cycle.averagePeriodLength,
        cycle.averageCycleLength,
        parseLocalDate(dateStr),
      );
      days.push({ date: dateStr, phase, day_of_cycle: dayOfCycle });
    }

    return { year, month, days };
  }
}
