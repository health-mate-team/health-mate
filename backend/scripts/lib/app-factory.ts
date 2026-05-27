// NestJS SQLite in-memory 테스트 앱 팩토리
// P0+P1+P2+P3 모듈 포함
process.env.JWT_SECRET = 'test-secret';

import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { Test } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthController } from '../../src/auth/auth.controller';
import { AuthService } from '../../src/auth/auth.service';
import { JwtStrategy } from '../../src/auth/strategies/jwt.strategy';
import { ActionsController } from '../../src/actions/actions.controller';
import { ActionsService } from '../../src/actions/actions.service';
import { JwtAuthGuard } from '../../src/common/guards/jwt-auth.guard';
import { TokenBlacklistService } from '../../src/common/redis/token-blacklist.service';
import { XpService } from '../../src/common/services/xp.service';
import { CycleController } from '../../src/cycle/cycle.controller';
import { CycleService } from '../../src/cycle/cycle.service';
import { NutritionController } from '../../src/nutrition/nutrition.controller';
import { NutritionService } from '../../src/nutrition/nutrition.service';
import { OnboardingController } from '../../src/onboarding/onboarding.controller';
import { OnboardingService } from '../../src/onboarding/onboarding.service';
import { RewardsController } from '../../src/rewards/rewards.controller';
import { RewardsService } from '../../src/rewards/rewards.service';
import { RitualsController } from '../../src/rituals/rituals.controller';
import { RitualsService } from '../../src/rituals/rituals.service';
import { StatsController } from '../../src/stats/stats.controller';
import { StatsService } from '../../src/stats/stats.service';
import { UsersController } from '../../src/users/users.controller';
import { UsersService } from '../../src/users/users.service';
import { WorkoutController } from '../../src/workout/workout.controller';
import { WorkoutService } from '../../src/workout/workout.service';

// Entities
import { DailyRitual } from '../../src/entities/daily-ritual.entity';
import { DailyStat } from '../../src/entities/daily-stat.entity';
import { MealLogItem } from '../../src/entities/meal-log-item.entity';
import { MealLog } from '../../src/entities/meal-log.entity';
import { UserBadge } from '../../src/entities/user-badge.entity';
import { UserCycle } from '../../src/entities/user-cycle.entity';
import { User } from '../../src/entities/user.entity';
import { WalkSession } from '../../src/entities/walk-session.entity';
import { WorkoutLog } from '../../src/entities/workout-log.entity';
import { XpLog } from '../../src/entities/xp-log.entity';

let _app: INestApplication | null = null;

export async function createTestApp(): Promise<INestApplication> {
  if (_app) return _app;

  const allEntities = [
    User, UserCycle, DailyStat, DailyRitual, XpLog,
    WalkSession, UserBadge, WorkoutLog, MealLog, MealLogItem,
  ];

  const moduleRef = await Test.createTestingModule({
    imports: [
      ConfigModule.forRoot({ isGlobal: true }),
      TypeOrmModule.forRoot({
        type: 'better-sqlite3',
        database: ':memory:',
        entities: allEntities,
        synchronize: true,
        dropSchema: false,
      }),
      TypeOrmModule.forFeature(allEntities),
      PassportModule,
      JwtModule.register({
        secret: 'test-secret',
        signOptions: { expiresIn: '1h' },
      }),
    ],
    controllers: [
      AuthController,
      UsersController,
      OnboardingController,
      CycleController,
      RitualsController,
      StatsController,
      ActionsController,
      RewardsController,
      WorkoutController,
      NutritionController,
    ],
    providers: [
      AuthService,
      UsersService,
      OnboardingService,
      CycleService,
      RitualsService,
      StatsService,
      XpService,
      ActionsService,
      RewardsService,
      WorkoutService,
      NutritionService,
      JwtStrategy,
      JwtAuthGuard,
      // Redis 미연결 테스트 하네스용 stub — 무효화 없음으로 동작.
      {
        provide: TokenBlacklistService,
        useValue: {
          invalidateUser: async (): Promise<void> => undefined,
          isInvalidated: async (): Promise<boolean> => false,
        },
      },
    ],
  }).compile();

  _app = moduleRef.createNestApplication();
  _app.setGlobalPrefix('api');
  _app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }),
  );
  await _app.init();
  return _app;
}

export async function closeTestApp(): Promise<void> {
  if (_app) {
    await _app.close();
    _app = null;
  }
}
