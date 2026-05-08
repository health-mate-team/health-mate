import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommonModule } from '../common/common.module';
import { DailyStat } from '../entities/daily-stat.entity';
import { WalkSession } from '../entities/walk-session.entity';
import { ActionsController } from './actions.controller';
import { ActionsService } from './actions.service';

@Module({
  imports: [TypeOrmModule.forFeature([DailyStat, WalkSession]), CommonModule],
  controllers: [ActionsController],
  providers: [ActionsService],
})
export class ActionsModule {}
