import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { XpService } from '../common/services/xp.service';
import { calculateCyclePhase, localDateString } from '../cycle/cycle.service';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { WorkoutLog } from '../entities/workout-log.entity';
import { User } from '../entities/user.entity';
import { WorkoutCompleteDto, WorkoutSkipDto } from './dto/workout.dto';

export interface WorkoutItem {
  workout_id: string;
  title: string;
  type: string;
  intensity: string;
  duration_minutes: number;
  phase_fit: string;
  thumbnail_url: string | null;
  video_url: null;
  is_video_ready: boolean;
  fallback_type: string;
}

const WORKOUT_CATALOG: Record<string, WorkoutItem[]> = {
  menstrual: [
    {
      workout_id: 'menstrual_stretching_01',
      title: '월경기 따뜻한 5분 요가',
      type: 'stretching',
      intensity: 'low',
      duration_minutes: 5,
      phase_fit: 'menstrual',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
    {
      workout_id: 'menstrual_breathing_01',
      title: '월경기 통증 완화 호흡 3분',
      type: 'breathing_meditation',
      intensity: 'low',
      duration_minutes: 3,
      phase_fit: 'menstrual',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
  ],
  follicular: [
    {
      workout_id: 'follicular_strength_01',
      title: '난포기 5분 근력 빌드업',
      type: 'strength_training',
      intensity: 'moderate',
      duration_minutes: 5,
      phase_fit: 'follicular',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
    {
      workout_id: 'follicular_cardio_01',
      title: '난포기 빠르게 걷기 5분',
      type: 'light_cardio',
      intensity: 'low',
      duration_minutes: 5,
      phase_fit: 'follicular',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
  ],
  ovulation: [
    {
      workout_id: 'ovulation_hiit_01',
      title: '배란기 풀 HIIT 5분',
      type: 'hiit',
      intensity: 'high',
      duration_minutes: 5,
      phase_fit: 'ovulation',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
    {
      workout_id: 'ovulation_strength_01',
      title: '배란기 강한 근력 5분',
      type: 'strength_training',
      intensity: 'high',
      duration_minutes: 5,
      phase_fit: 'ovulation',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
  ],
  luteal: [
    {
      workout_id: 'luteal_yoga_01',
      title: '황체기 차분한 5분 요가',
      type: 'yoga',
      intensity: 'low',
      duration_minutes: 5,
      phase_fit: 'luteal',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
    {
      workout_id: 'luteal_breathing_01',
      title: '황체기 PMS 진정 호흡 3분',
      type: 'breathing_meditation',
      intensity: 'low',
      duration_minutes: 3,
      phase_fit: 'luteal',
      thumbnail_url: null,
      video_url: null,
      is_video_ready: false,
      fallback_type: 'svg_animation',
    },
  ],
};

@Injectable()
export class WorkoutService {
  constructor(
    @InjectRepository(WorkoutLog)
    private readonly workoutLogRepo: Repository<WorkoutLog>,
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
    private readonly xpService: XpService,
  ) {}

  private async getCurrentPhase(userId: string): Promise<string> {
    const cycle = await this.cycleRepo.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
    if (!cycle) return 'follicular';
    const { phase } = calculateCyclePhase(
      cycle.lastPeriodStartDate,
      cycle.averagePeriodLength,
    );
    return phase;
  }

  private async getOrCreateStat(
    userId: string,
    date?: string,
  ): Promise<DailyStat> {
    const today = date ?? localDateString();
    let stat = await this.statRepo.findOne({ where: { userId, date: today } });
    if (!stat) {
      stat = this.statRepo.create({
        userId,
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
    }
    return stat;
  }

  async recommend(user: User) {
    const phase = await this.getCurrentPhase(user.id);
    const cycle = await this.cycleRepo.findOne({
      where: { userId: user.id },
      order: { createdAt: 'DESC' },
    });
    const goalType = cycle?.goalType ?? 'energy';

    const workouts = WORKOUT_CATALOG[phase] ?? WORKOUT_CATALOG['follicular'];
    const [recommendation, alternative] = workouts;

    return {
      recommendation,
      based_on: {
        phase,
        mood: 'okay',
        goal: goalType,
      },
      alternative: alternative ?? null,
    };
  }

  async complete(user: User, dto: WorkoutCompleteDto) {
    const date = dto.date ?? localDateString();

    const log = this.workoutLogRepo.create({
      userId: user.id,
      workoutId: dto.workout_id,
      date,
      workoutType: this.inferWorkoutType(dto.workout_id),
      durationActualMinutes: dto.duration_actual_minutes ?? null,
      completionRate: dto.completion_rate ?? 1.0,
      isSkipped: false,
    });
    await this.workoutLogRepo.save(log);

    const stat = await this.getOrCreateStat(user.id, date);
    const energyDelta = 10;
    stat.energyScore = Math.min(100, Number(stat.energyScore) + energyDelta);
    await this.statRepo.save(stat);

    await this.xpService.addXp(
      user.id,
      stat,
      30,
      'workout_completed',
      `운동 완료 +30 XP`,
    );

    return {
      xp_earned: 30,
      energy_stat_delta: energyDelta,
      streak_updated: { current_streak: stat.streak ?? 0 },
      level_up: null,
    };
  }

  async skip(user: User, dto: WorkoutSkipDto) {
    const date = dto.date ?? localDateString();

    const log = this.workoutLogRepo.create({
      userId: user.id,
      workoutId: dto.workout_id,
      date,
      workoutType: this.inferWorkoutType(dto.workout_id),
      isSkipped: true,
      skipReason: dto.skip_reason ?? null,
    });
    await this.workoutLogRepo.save(log);

    return {
      skipped: true,
      workout_id: dto.workout_id,
    };
  }

  private inferWorkoutType(workoutId: string): string {
    if (workoutId.includes('strength')) return 'strength_training';
    if (workoutId.includes('cardio')) return 'light_cardio';
    if (workoutId.includes('yoga')) return 'yoga';
    if (workoutId.includes('hiit')) return 'hiit';
    if (workoutId.includes('stretching')) return 'stretching';
    if (workoutId.includes('breathing')) return 'breathing_meditation';
    return 'light_cardio';
  }
}
