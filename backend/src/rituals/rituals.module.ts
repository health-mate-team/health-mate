import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CycleModule } from '../cycle/cycle.module';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { XpLog } from '../entities/xp-log.entity';
import { RitualsController } from './rituals.controller';
import { RitualsService } from './rituals.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([DailyRitual, DailyStat, UserCycle, XpLog]),
    CycleModule,
  ],
  controllers: [RitualsController],
  providers: [RitualsService],
})
export class RitualsModule {}
