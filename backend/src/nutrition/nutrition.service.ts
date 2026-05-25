import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { XpService } from '../common/services/xp.service';
import { calculateCyclePhase, localDateString } from '../cycle/cycle.service';
import { DailyStat } from '../entities/daily-stat.entity';
import { MealLogItem } from '../entities/meal-log-item.entity';
import { MealLog } from '../entities/meal-log.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { NutritionLogDto } from './dto/nutrition.dto';

export interface FoodData {
  food_id: string;
  name: string;
  calories_per_100g: number;
  protein_g: number;
  carbs_g: number;
  fat_g: number;
  source: string;
}

const FOOD_STUB_DB: FoodData[] = [
  {
    food_id: 'mfds_001234',
    name: '닭가슴살 (삶은 것)',
    calories_per_100g: 109,
    protein_g: 23.1,
    carbs_g: 0,
    fat_g: 1.2,
    source: '식약처',
  },
  {
    food_id: 'mfds_001235',
    name: '닭가슴살 (구운 것)',
    calories_per_100g: 165,
    protein_g: 31.0,
    carbs_g: 0,
    fat_g: 3.6,
    source: '식약처',
  },
  {
    food_id: 'mfds_002001',
    name: '현미밥',
    calories_per_100g: 156,
    protein_g: 2.6,
    carbs_g: 34.2,
    fat_g: 0.9,
    source: '식약처',
  },
  {
    food_id: 'mfds_002002',
    name: '흰쌀밥',
    calories_per_100g: 168,
    protein_g: 2.8,
    carbs_g: 37.0,
    fat_g: 0.3,
    source: '식약처',
  },
  {
    food_id: 'mfds_003001',
    name: '삶은 달걀',
    calories_per_100g: 155,
    protein_g: 13.0,
    carbs_g: 1.1,
    fat_g: 10.6,
    source: '식약처',
  },
  {
    food_id: 'mfds_004001',
    name: '두부 (부침용)',
    calories_per_100g: 84,
    protein_g: 8.7,
    carbs_g: 2.7,
    fat_g: 4.5,
    source: '식약처',
  },
  {
    food_id: 'mfds_005001',
    name: '바나나',
    calories_per_100g: 89,
    protein_g: 1.1,
    carbs_g: 22.8,
    fat_g: 0.3,
    source: '식약처',
  },
  {
    food_id: 'mfds_006001',
    name: '그릭요거트 (무지방)',
    calories_per_100g: 59,
    protein_g: 10.2,
    carbs_g: 3.6,
    fat_g: 0.4,
    source: '식약처',
  },
  {
    food_id: 'mfds_007001',
    name: '연어 (구운 것)',
    calories_per_100g: 206,
    protein_g: 20.4,
    carbs_g: 0,
    fat_g: 13.4,
    source: '식약처',
  },
  {
    food_id: 'mfds_008001',
    name: '시금치 (나물)',
    calories_per_100g: 28,
    protein_g: 2.9,
    carbs_g: 2.8,
    fat_g: 0.6,
    source: '식약처',
  },
];

const PHASE_RECOMMENDATION: Record<
  string,
  { focus_nutrients: string[]; message: string }
> = {
  menstrual: {
    focus_nutrients: ['철분', '마그네슘'],
    message: '월경기에는 철분과 마그네슘을 충분히 보충해요',
  },
  follicular: {
    focus_nutrients: ['단백질', '복합 탄수화물'],
    message: '난포기에는 단백질 섭취를 늘려 근육 회복을 도와요',
  },
  ovulation: {
    focus_nutrients: ['항산화 영양소', '비타민 C'],
    message: '배란기에는 항산화 영양소로 에너지를 유지해요',
  },
  luteal: {
    focus_nutrients: ['칼슘', '비타민 B6'],
    message: '황체기에는 칼슘과 비타민 B6로 PMS를 완화해요',
  },
};

@Injectable()
export class NutritionService {
  constructor(
    @InjectRepository(MealLog)
    private readonly mealLogRepo: Repository<MealLog>,
    @InjectRepository(MealLogItem)
    private readonly mealLogItemRepo: Repository<MealLogItem>,
    @InjectRepository(DailyStat)
    private readonly statRepo: Repository<DailyStat>,
    @InjectRepository(UserCycle)
    private readonly cycleRepo: Repository<UserCycle>,
    private readonly xpService: XpService,
  ) {}

  search(q: string, limit = 10) {
    const query = (q ?? '').toLowerCase();
    const results = FOOD_STUB_DB.filter((f) =>
      f.name.toLowerCase().includes(query),
    ).slice(0, Math.min(limit, 20));
    return { query: q, results };
  }

  async logMeal(user: User, dto: NutritionLogDto) {
    const date = dto.date ?? localDateString();

    // Calculate totals from stub db
    let totalCalories = 0;
    let totalProtein = 0;
    const items: MealLogItem[] = [];

    for (const foodItem of dto.foods) {
      const food = FOOD_STUB_DB.find((f) => f.food_id === foodItem.food_id);
      const calories = food
        ? Math.round((food.calories_per_100g * foodItem.amount_g) / 100)
        : 0;
      const protein = food
        ? Math.round(((food.protein_g * foodItem.amount_g) / 100) * 10) / 10
        : 0;
      totalCalories += calories;
      totalProtein += protein;

      const item = this.mealLogItemRepo.create({
        foodId: foodItem.food_id,
        foodName: food?.name ?? foodItem.food_id,
        amountG: foodItem.amount_g,
        calories,
        proteinG: protein,
      });
      items.push(item);
    }

    const log = this.mealLogRepo.create({
      userId: user.id,
      date,
      mealType: dto.meal_type,
      totalCalories,
      totalProteinG: totalProtein,
    });
    await this.mealLogRepo.save(log);

    for (const item of items) {
      item.mealLogId = log.id;
    }
    if (items.length > 0) {
      await this.mealLogItemRepo.save(items);
    }

    const stat = await this.getOrCreateStat(user.id, date);
    await this.xpService.addXp(
      user.id,
      stat,
      10,
      'meal_logged',
      `식사 기록 +10 XP`,
    );

    return {
      meal_log_id: log.id,
      total_calories: totalCalories,
      xp_earned: 10,
    };
  }

  async getToday(user: User) {
    const today = localDateString();
    const logs = await this.mealLogRepo.find({
      where: { userId: user.id, date: today },
    });

    const totalCalories = logs.reduce(
      (sum, l) => sum + (l.totalCalories ?? 0),
      0,
    );

    const meals = logs.map((l) => ({
      meal_type: l.mealType,
      calories: l.totalCalories,
      foods_count: 0,
    }));

    // Count foods per meal
    if (logs.length > 0) {
      const logIds = logs.map((l) => l.id);
      const allItems = await this.mealLogItemRepo
        .createQueryBuilder('i')
        .where('i.mealLogId IN (:...logIds)', { logIds })
        .getMany();

      const countMap = new Map<string, number>();
      for (const item of allItems) {
        countMap.set(item.mealLogId, (countMap.get(item.mealLogId) ?? 0) + 1);
      }
      for (const meal of meals) {
        const matchLog = logs.find((l) => l.mealType === meal.meal_type);
        if (matchLog) {
          meal.foods_count = countMap.get(matchLog.id) ?? 0;
        }
      }
    }

    const cycle = await this.cycleRepo.findOne({
      where: { userId: user.id },
      order: { createdAt: 'DESC' },
    });
    const phase = cycle
      ? calculateCyclePhase(
          cycle.lastPeriodStartDate,
          cycle.averagePeriodLength,
        ).phase
      : 'follicular';
    const phaseRec =
      PHASE_RECOMMENDATION[phase] ?? PHASE_RECOMMENDATION['follicular'];

    return {
      date: today,
      total_calories: totalCalories,
      daily_target_calories: 1800,
      phase_recommendation: {
        phase,
        focus_nutrients: phaseRec.focus_nutrients,
        message: phaseRec.message,
      },
      meals,
    };
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
}
