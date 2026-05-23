import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserBadge } from '../entities/user-badge.entity';
import { XpLog } from '../entities/xp-log.entity';
import { RewardsController } from './rewards.controller';
import { RewardsService } from './rewards.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([DailyStat, UserBadge, XpLog, DailyRitual]),
  ],
  controllers: [RewardsController],
  providers: [RewardsService],
  exports: [RewardsService],
})
export class RewardsModule {}
