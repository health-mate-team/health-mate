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

function parseLocalDate(dateStr: string): Date {
  const [y, m, d] = dateStr.split('-').map(Number);
  return new Date(y, m - 1, d);
}

export function localDateString(d = new Date()): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

export function calculateCyclePhase(
  lastPeriodStart: string,
  periodLength: number,
): { phase: CyclePhase; dayOfCycle: number } {
  const start = parseLocalDate(lastPeriodStart);
  const today = parseLocalDate(localDateString());
  const dayOfCycle =
    Math.floor((today.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1;

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
    );

    const lastPeriodStart = parseLocalDate(cycle.lastPeriodStartDate);
    const nextPeriodDate = new Date(lastPeriodStart);
    nextPeriodDate.setDate(nextPeriodDate.getDate() + cycle.averageCycleLength);

    const today = parseLocalDate(localDateString());
    const daysUntilNextPeriod = Math.ceil(
      (nextPeriodDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
    );

    return {
      current_phase: phase,
      day_of_cycle: dayOfCycle,
      days_until_next_period: daysUntilNextPeriod,
      next_period_date: nextPeriodDate.toISOString().slice(0, 10),
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
      const start = parseLocalDate(cycle.lastPeriodStartDate);
      const current = parseLocalDate(dateStr);
      const dayOfCycle =
        Math.floor(
          (current.getTime() - start.getTime()) / (1000 * 60 * 60 * 24),
        ) + 1;

      let phase: CyclePhase;
      // Normalize dayOfCycle within the cycle length
      const normalizedDay = ((dayOfCycle - 1) % cycle.averageCycleLength) + 1;
      if (normalizedDay <= cycle.averagePeriodLength)
        phase = CyclePhase.Menstrual;
      else if (normalizedDay <= 13) phase = CyclePhase.Follicular;
      else if (normalizedDay <= 15) phase = CyclePhase.Ovulation;
      else phase = CyclePhase.Luteal;

      days.push({ date: dateStr, phase, day_of_cycle: normalizedDay });
    }

    return { year, month, days };
  }
}
