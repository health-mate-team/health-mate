import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserBadge } from '../entities/user-badge.entity';
import { XpLog } from '../entities/xp-log.entity';
import { User } from '../entities/user.entity';
import { evolutionStage, xpToNextLevel } from '../common/utils/xp-level.util';
import { BadgeCode, BADGE_META } from './enums/badge-code.enum';
import { DailyRitual } from '../entities/daily-ritual.entity';

@Injectable()
export class RewardsService {
  constructor(
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(UserBadge)
    private readonly badgeRepo: Repository<UserBadge>,
    @InjectRepository(XpLog)
    private readonly xpLogRepo: Repository<XpLog>,
    @InjectRepository(DailyRitual)
    private readonly ritualRepo: Repository<DailyRitual>,
  ) {}

  async checkAndAwardBadges(user: User, stat: DailyStat): Promise<void> {
    const existing = await this.badgeRepo.find({ where: { userId: user.id } });
    const earned = new Set(existing.map((b) => b.badgeCode));

    const toAward: BadgeCode[] = [];

    if (!earned.has(BadgeCode.FirstRitual)) {
      const hasRitual = await this.ritualRepo.findOne({
        where: { userId: user.id },
      });
      if (hasRitual?.morningMood != null) toAward.push(BadgeCode.FirstRitual);
    }

    if (!earned.has(BadgeCode.SevenDayStreak) && stat.streak >= 7) {
      toAward.push(BadgeCode.SevenDayStreak);
    }

    if (!earned.has(BadgeCode.ThirtyDayStreak) && stat.streak >= 30) {
      toAward.push(BadgeCode.ThirtyDayStreak);
    }

    if (!earned.has(BadgeCode.WalkComplete)) {
      const hasWalkXp = await this.xpLogRepo.findOne({
        where: { userId: user.id, source: 'walk_completed' },
      });
      if (hasWalkXp) toAward.push(BadgeCode.WalkComplete);
    }

    if (!earned.has(BadgeCode.WaterGoal)) {
      const hasWaterGoal = await this.statRepo.findOne({
        where: { userId: user.id },
      });
      if (hasWaterGoal && hasWaterGoal.waterCups >= 8) {
        toAward.push(BadgeCode.WaterGoal);
      }
    }

    for (const code of toAward) {
      await this.badgeRepo.save(
        this.badgeRepo.create({ userId: user.id, badgeCode: code }),
      );
    }
  }

  async getSummary(user: User) {
    const stats = await this.statRepo.find({
      where: { userId: user.id },
      order: { date: 'DESC' },
    });

    const latestStat = stats[0];
    const totalXp = latestStat ? Number(latestStat.totalXp) : 0;
    const level = latestStat ? latestStat.level : 1;
    const streak = latestStat ? latestStat.streak : 0;
    const longestStreak = stats.reduce((max, s) => Math.max(max, s.streak), 0);

    const stage = evolutionStage(level);
    const nextXp = xpToNextLevel(totalXp);

    const badges = await this.badgeRepo.find({
      where: { userId: user.id },
      order: { earnedAt: 'DESC' },
    });

    const xpLogs = await this.xpLogRepo.find({
      where: { userId: user.id },
      order: { createdAt: 'DESC' },
      take: 10,
    });

    return {
      level,
      current_xp: totalXp,
      xp_to_next_level: nextXp,
      total_xp_earned: totalXp,
      streak: {
        current: streak,
        longest: longestStreak,
      },
      evolution_stage: {
        stage: stage.stage,
        name: stage.name,
        color_token: stage.colorToken,
        next_stage_xp_threshold: stage.xpThreshold,
        xp_to_next: nextXp,
      },
      badges: badges.map((b) => ({
        code: b.badgeCode,
        name: BADGE_META[b.badgeCode as BadgeCode]?.name ?? b.badgeCode,
        description: BADGE_META[b.badgeCode as BadgeCode]?.description ?? '',
        earned_at: b.earnedAt.toISOString(),
      })),
      xp_log: xpLogs.map((l) => ({
        delta: l.amount,
        reason: l.source,
        label: l.description ?? '',
        created_at: l.createdAt.toISOString(),
      })),
    };
  }
}
