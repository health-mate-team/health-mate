import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  calculateCyclePhase,
  CyclePhase,
  localDateString,
} from '../cycle/cycle.service';
import { calculateLevel } from '../common/utils/xp-level.util';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { XpLog } from '../entities/xp-log.entity';
import { EveningDto } from './dto/evening.dto';
import { MorningMoodDto } from './dto/morning-mood.dto';
import { MorningPromiseDto } from './dto/morning-promise.dto';

const PHASE_PROMISES: Record<CyclePhase, string[]> = {
  [CyclePhase.Menstrual]: [
    '오늘은 충분히 쉬기',
    '따뜻한 물 마시기',
    '가벼운 스트레칭하기',
  ],
  [CyclePhase.Follicular]: [
    '새로운 습관 시작하기',
    '30분 산책하기',
    '건강한 식사 계획 세우기',
  ],
  [CyclePhase.Ovulation]: [
    '사회적 활동 즐기기',
    '고강도 운동 도전하기',
    '친구에게 연락하기',
  ],
  [CyclePhase.Luteal]: [
    '충분한 수면 취하기',
    '마그네슘 섭취하기',
    '명상 10분 하기',
  ],
};

@Injectable()
export class RitualsService {
  constructor(
    @InjectRepository(DailyRitual)
    private readonly ritualRepo: Repository<DailyRitual>,
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
    @InjectRepository(XpLog)
    private readonly xpLogRepo: Repository<XpLog>,
  ) {}

  private today(): string {
    return localDateString();
  }

  private async getOrCreateRitual(userId: string): Promise<DailyRitual> {
    const today = this.today();
    let ritual = await this.ritualRepo.findOne({
      where: { userId, date: today },
    });
    if (!ritual) {
      ritual = this.ritualRepo.create({ userId, date: today });
      await this.ritualRepo.save(ritual);
    }
    return ritual;
  }

  private async getOrCreateStat(userId: string): Promise<DailyStat> {
    const today = this.today();
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

  private async addXp(
    userId: string,
    stat: DailyStat,
    amount: number,
    source: string,
    description: string,
  ): Promise<void> {
    stat.totalXp = Number(stat.totalXp) + amount;
    stat.level = calculateLevel(stat.totalXp);
    await this.statRepo.save(stat);

    const log = this.xpLogRepo.create({
      userId,
      date: this.today(),
      amount,
      source,
      description,
    });
    await this.xpLogRepo.save(log);
  }

  async morningMood(user: User, dto: MorningMoodDto) {
    const ritual = await this.getOrCreateRitual(user.id);
    if (ritual.morningMood !== null && ritual.morningMood !== undefined) {
      throw new BadRequestException('오늘 아침 기분은 이미 기록되었습니다.');
    }

    ritual.morningMood = dto.mood;
    ritual.morningMoodAt = new Date().toISOString();
    ritual.xpEarned = (ritual.xpEarned ?? 0) + 10;
    await this.ritualRepo.save(ritual);

    const stat = await this.getOrCreateStat(user.id);
    // mood 1~5 → score 20/35/50/65/80
    stat.moodScore = 20 + (dto.mood - 1) * 15;
    await this.statRepo.save(stat);
    await this.addXp(
      user.id,
      stat,
      10,
      'morning_mood',
      '아침 기분 체크 +10 XP',
    );

    const cycle = await this.cycleRepo.findOne({ where: { userId: user.id } });
    let recommended_promise = '오늘 하루도 건강하게 지내기';
    if (cycle) {
      const { phase } = calculateCyclePhase(
        cycle.lastPeriodStartDate,
        cycle.averagePeriodLength,
      );
      const promises = PHASE_PROMISES[phase];
      recommended_promise =
        promises[Math.floor(Math.random() * promises.length)];
    }

    return {
      mood: dto.mood,
      xp_earned: 10,
      recommended_promise,
      total_xp: stat.totalXp,
    };
  }

  async morningPromise(user: User, dto: MorningPromiseDto) {
    const ritual = await this.getOrCreateRitual(user.id);
    ritual.morningPromise = dto.promise;
    ritual.morningPromiseAt = new Date().toISOString();
    await this.ritualRepo.save(ritual);

    return {
      promise: dto.promise,
      saved_at: ritual.morningPromiseAt,
    };
  }

  async evening(user: User, dto: EveningDto) {
    const ritual = await this.getOrCreateRitual(user.id);
    if (ritual.eveningCompleted) {
      throw new BadRequestException('오늘 저녁 의식은 이미 완료되었습니다.');
    }

    ritual.eveningCompleted = true;
    ritual.eveningCompletedAt = new Date().toISOString();
    ritual.promiseKept = dto.promise_kept;

    const baseXp = 10;
    const bonusXp = dto.promise_kept ? 50 : 0;
    const totalXpEarned = baseXp + bonusXp;

    ritual.xpEarned = (ritual.xpEarned ?? 0) + totalXpEarned;
    await this.ritualRepo.save(ritual);

    const stat = await this.getOrCreateStat(user.id);
    await this.addXp(user.id, stat, baseXp, 'evening', '저녁 의식 완료 +10 XP');
    if (dto.promise_kept) {
      await this.addXp(
        user.id,
        stat,
        bonusXp,
        'promise_kept',
        '약속 지키기 보너스 +50 XP',
      );
    }

    // streak 업데이트: 전날 stat이 있으면 streak +1
    const yStr = localDateString(new Date(Date.now() - 86400000));
    const prevStat = await this.statRepo.findOne({
      where: { userId: user.id, date: yStr },
    });
    if (prevStat && prevStat.streak > 0) {
      stat.streak = prevStat.streak + 1;
    } else {
      stat.streak = stat.streak > 0 ? stat.streak : 1;
    }
    await this.statRepo.save(stat);

    return {
      promise_kept: dto.promise_kept,
      xp_earned: totalXpEarned,
      total_xp: stat.totalXp,
      streak: stat.streak,
      level: stat.level,
    };
  }

  async getToday(user: User) {
    const today = this.today();
    const ritual = await this.ritualRepo.findOne({
      where: { userId: user.id, date: today },
    });

    return {
      date: today,
      morning_mood: ritual?.morningMood ?? null,
      morning_promise: ritual?.morningPromise ?? null,
      evening_completed: ritual?.eveningCompleted ?? false,
      promise_kept: ritual?.promiseKept ?? false,
      xp_earned_today: ritual?.xpEarned ?? 0,
    };
  }
}
