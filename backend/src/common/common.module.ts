import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DailyStat } from '../entities/daily-stat.entity';
import { XpLog } from '../entities/xp-log.entity';
import { XpService } from './services/xp.service';

@Module({
  imports: [TypeOrmModule.forFeature([DailyStat, XpLog])],
  providers: [XpService],
  exports: [XpService],
})
export class CommonModule {}
