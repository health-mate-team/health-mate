import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { localDateString } from '../cycle/cycle.service';
import { XpService } from '../common/services/xp.service';
import { DailyStat } from '../entities/daily-stat.entity';
import { WalkSession } from '../entities/walk-session.entity';
import { User } from '../entities/user.entity';
import { WaterActionDto } from './dto/water-action.dto';
import { WalkCompleteDto, WalkStartDto } from './dto/walk-action.dto';

const MOA_WATER_REACTIONS = [
  '물 마셨군요! 수분이 채워지고 있어요 💧',
  '한 잔씩 채워가는 중! 모아도 기뻐요 🐾',
  '몸이 촉촉해지고 있어요 ✨',
  '오늘 목표에 가까워지고 있어요! 💙',
];

const MOA_WALK_REACTIONS = [
  '걸었어요! 모아가 기뻐해요 🐾',
  '산책 완료! 에너지가 충전됐어요 ⚡',
  '발걸음마다 건강해지고 있어요 🌿',
];

@Injectable()
export class ActionsService {
  constructor(
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(WalkSession)
    private readonly walkRepo: Repository<WalkSession>,
    private readonly xpService: XpService,
  ) {}

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

  async addWater(user: User, dto: WaterActionDto) {
    const date = dto.date ?? localDateString();
    const stat = await this.getOrCreateStat(user.id, date);

    stat.waterCups = (stat.waterCups ?? 0) + dto.cups_added;
    // hydration score: 1잔=12.5점씩 증가, max 100
    const hydrationDelta = dto.cups_added * 12.5;
    stat.hydrationScore = Math.min(
      100,
      Number(stat.hydrationScore) + hydrationDelta,
    );
    await this.statRepo.save(stat);

    await this.xpService.addXp(
      user.id,
      stat,
      5,
      'water_added',
      `물 ${dto.cups_added}잔 마시기 +5 XP`,
    );

    const reaction =
      MOA_WATER_REACTIONS[
        Math.floor(Math.random() * MOA_WATER_REACTIONS.length)
      ];

    return {
      today_cups_total: stat.waterCups,
      daily_target_cups: 8,
      hydration_stat: Math.round(Number(stat.hydrationScore)),
      xp_earned: 5,
      moa_reaction: reaction,
    };
  }

  async getWaterToday(user: User) {
    const today = localDateString();
    const stat = await this.statRepo.findOne({
      where: { userId: user.id, date: today },
    });
    return {
      date: today,
      cups_total: stat?.waterCups ?? 0,
      daily_target_cups: 8,
    };
  }

  async startWalk(user: User, dto: WalkStartDto) {
    const session = this.walkRepo.create({
      userId: user.id,
      startedAt: new Date(dto.started_at),
    });
    await this.walkRepo.save(session);

    return {
      walk_session_id: session.id,
      started_at: session.startedAt.toISOString(),
    };
  }

  async completeWalk(user: User, dto: WalkCompleteDto) {
    const session = await this.walkRepo.findOne({
      where: { id: dto.walk_session_id, userId: user.id },
    });
    if (!session) throw new NotFoundException('산책 세션을 찾을 수 없습니다.');
    if (session.endedAt)
      throw new BadRequestException('이미 완료된 산책 세션입니다.');

    session.endedAt = new Date(dto.ended_at);
    session.durationMinutes = dto.duration_minutes;
    session.stepsCount = dto.steps_count ?? 0;
    session.distanceKm = dto.distance_km ?? 0;
    await this.walkRepo.save(session);

    // energy stat 증가: 분당 0.5점, max 20
    const energyDelta = Math.min(20, Math.round(dto.duration_minutes * 0.5));
    const stat = await this.getOrCreateStat(user.id);
    stat.energyScore = Math.min(100, Number(stat.energyScore) + energyDelta);
    await this.statRepo.save(stat);

    await this.xpService.addXp(
      user.id,
      stat,
      30,
      'walk_completed',
      `산책 완료 +30 XP`,
    );

    const reaction =
      MOA_WALK_REACTIONS[Math.floor(Math.random() * MOA_WALK_REACTIONS.length)];

    return {
      duration_minutes: dto.duration_minutes,
      distance_km: dto.distance_km ?? 0,
      energy_stat_delta: energyDelta,
      xp_earned: 30,
      moa_reaction: `${dto.duration_minutes}분 ${reaction}`,
    };
  }
}
