import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  calculateCyclePhase,
  localDateString,
  parseLocalDate,
} from '../cycle/cycle.service';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { Between } from 'typeorm';

@Injectable()
export class StatsService {
  constructor(
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
    @InjectRepository(DailyRitual)
    private readonly ritualRepo: Repository<DailyRitual>,
  ) {}

  async getHistory(user: User, days: number) {
    // 비숫자 days(?days=abc) → NaN 전파로 인한 잘못된 SQL 날짜/500 방지(P0-4).
    const safeDays = Number.isNaN(days) ? 30 : days;
    const clampedDays = Math.min(Math.max(safeDays, 1), 90);
    const endDate = localDateString();
    const startDate = localDateString(
      new Date(Date.now() - (clampedDays - 1) * 86400000),
    );

    const [stats, rituals, cycle] = await Promise.all([
      this.statRepo.find({
        where: { userId: user.id, date: Between(startDate, endDate) },
        order: { date: 'ASC' },
      }),
      this.ritualRepo.find({
        where: { userId: user.id, date: Between(startDate, endDate) },
      }),
      this.cycleRepo.findOne({ where: { userId: user.id } }),
    ]);

    const ritualMap = new Map(rituals.map((r) => [r.date, r]));

    const daily_records = stats.map((s) => {
      const ritual = ritualMap.get(s.date);
      let phase: string | null = null;
      if (cycle) {
        // 각 레코드의 날짜 기준으로 phase 계산 (오늘 기준 고정 버그 P1-1 수정).
        const { phase: p } = calculateCyclePhase(
          cycle.lastPeriodStartDate,
          cycle.averagePeriodLength,
          cycle.averageCycleLength,
          parseLocalDate(s.date),
        );
        phase = p;
      }
      return {
        date: s.date,
        energy: Math.round(Number(s.energyScore)),
        hydration: Math.round(Number(s.hydrationScore)),
        rest: Math.round(Number(s.restScore)),
        morning_completed: ritual?.morningMood != null,
        evening_completed: ritual?.eveningCompleted ?? false,
        phase,
      };
    });

    return {
      period_days: clampedDays,
      daily_records,
    };
  }

  async getToday(user: User) {
    const today = localDateString();

    const [stat, cycle, ritual] = await Promise.all([
      this.statRepo.findOne({ where: { userId: user.id, date: today } }),
      this.cycleRepo.findOne({ where: { userId: user.id } }),
      this.ritualRepo.findOne({ where: { userId: user.id, date: today } }),
    ]);

    const cycleInfo = cycle
      ? (() => {
          const { phase, dayOfCycle } = calculateCyclePhase(
            cycle.lastPeriodStartDate,
            cycle.averagePeriodLength,
            cycle.averageCycleLength,
          );
          return {
            current_phase: phase,
            day_of_cycle: dayOfCycle,
            goal_type: cycle.goalType,
          };
        })()
      : null;

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      stats: stat
        ? {
            energy_score: Number(stat.energyScore),
            hydration_score: Number(stat.hydrationScore),
            mood_score: Number(stat.moodScore),
            rest_score: Number(stat.restScore),
            water_cups: stat.waterCups,
            total_xp: stat.totalXp,
            level: stat.level,
            streak: stat.streak,
          }
        : null,
      cycle: cycleInfo,
      today_ritual: ritual
        ? {
            morning_mood: ritual.morningMood ?? null,
            morning_promise: ritual.morningPromise ?? null,
            evening_completed: ritual.eveningCompleted,
            promise_kept: ritual.promiseKept,
            xp_earned_today: ritual.xpEarned,
          }
        : null,
    };
  }
}
