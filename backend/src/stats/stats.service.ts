import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { calculateCyclePhase, localDateString } from '../cycle/cycle.service';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';

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
