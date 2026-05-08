import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { localDateString } from '../cycle/cycle.service';
import { CompleteOnboardingDto } from './dto/complete-onboarding.dto';

type CyclePhase = 'menstrual' | 'follicular' | 'ovulation' | 'luteal';

@Injectable()
export class OnboardingService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
  ) {}

  async complete(user: User, dto: CompleteOnboardingDto) {
    user.name = dto.name;
    user.isOnboardingCompleted = true;
    await this.userRepo.save(user);

    const cycle = this.cycleRepo.create({
      userId: user.id,
      lastPeriodStartDate: dto.last_period_start_date,
      averageCycleLength: dto.average_cycle_length,
      averagePeriodLength: dto.average_period_length,
      isIrregular: dto.is_irregular,
      goalType: dto.goal_type,
    });
    await this.cycleRepo.save(cycle);

    const today = localDateString();
    const stat = this.statRepo.create({
      userId: user.id,
      date: today,
      energyScore: 50,
      hydrationScore: 50,
      moodScore: 50,
      restScore: 50,
      waterCups: 0,
      totalXp: 0,
      level: 1,
      streak: 0,
    });
    await this.statRepo.save(stat);

    const current_phase = this.calculatePhase(
      dto.last_period_start_date,
      dto.average_period_length,
    );

    const initial_stats = {
      energy_score: Number(stat.energyScore),
      hydration_score: Number(stat.hydrationScore),
      mood_score: Number(stat.moodScore),
      rest_score: Number(stat.restScore),
      water_cups: stat.waterCups,
      total_xp: stat.totalXp,
      level: stat.level,
      streak: stat.streak,
    };

    return { initial_stats, current_phase };
  }

  private calculatePhase(
    lastPeriodStart: string,
    periodLength: number,
  ): CyclePhase {
    const start = new Date(lastPeriodStart);
    const today = new Date();
    const dayOfCycle =
      Math.floor((today.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) +
      1;

    if (dayOfCycle <= periodLength) return 'menstrual';
    if (dayOfCycle <= 13) return 'follicular';
    if (dayOfCycle <= 15) return 'ovulation';
    return 'luteal';
  }
}
