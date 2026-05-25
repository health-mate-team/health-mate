import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommonModule } from '../common/common.module';
import { DailyStat } from '../entities/daily-stat.entity';
import { MealLogItem } from '../entities/meal-log-item.entity';
import { MealLog } from '../entities/meal-log.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { NutritionController } from './nutrition.controller';
import { NutritionService } from './nutrition.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([MealLog, MealLogItem, DailyStat, UserCycle]),
    CommonModule,
  ],
  controllers: [NutritionController],
  providers: [NutritionService],
})
export class NutritionModule {}
