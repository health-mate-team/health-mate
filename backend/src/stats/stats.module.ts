import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CycleModule } from '../cycle/cycle.module';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { StatsController } from './stats.controller';
import { StatsService } from './stats.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([DailyStat, UserCycle, DailyRitual]),
    CycleModule,
  ],
  controllers: [StatsController],
  providers: [StatsService],
})
export class StatsModule {}
