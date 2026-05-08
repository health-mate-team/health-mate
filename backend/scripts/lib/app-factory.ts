// NestJS SQLite in-memory 테스트 앱 팩토리
// p1.integration.spec.ts 패턴 재사용, 모든 P0+P1 모듈 포함
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
import { JwtAuthGuard } from '../../src/common/guards/jwt-auth.guard';
import { CycleController } from '../../src/cycle/cycle.controller';
import { CycleService } from '../../src/cycle/cycle.service';
import { DailyRitual } from '../../src/entities/daily-ritual.entity';
import { DailyStat } from '../../src/entities/daily-stat.entity';
import { UserCycle } from '../../src/entities/user-cycle.entity';
import { User } from '../../src/entities/user.entity';
import { XpLog } from '../../src/entities/xp-log.entity';
import { OnboardingController } from '../../src/onboarding/onboarding.controller';
import { OnboardingService } from '../../src/onboarding/onboarding.service';
import { RitualsController } from '../../src/rituals/rituals.controller';
import { RitualsService } from '../../src/rituals/rituals.service';
import { StatsController } from '../../src/stats/stats.controller';
import { StatsService } from '../../src/stats/stats.service';
import { UsersController } from '../../src/users/users.controller';
import { UsersService } from '../../src/users/users.service';

let _app: INestApplication | null = null;

export async function createTestApp(): Promise<INestApplication> {
  if (_app) return _app;

  const moduleRef = await Test.createTestingModule({
    imports: [
      ConfigModule.forRoot({ isGlobal: true }),
      TypeOrmModule.forRoot({
        type: 'better-sqlite3',
        database: ':memory:',
        entities: [User, UserCycle, DailyStat, DailyRitual, XpLog],
        synchronize: true,
        dropSchema: false,
      }),
      TypeOrmModule.forFeature([User, UserCycle, DailyStat, DailyRitual, XpLog]),
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
    ],
    providers: [
      AuthService,
      UsersService,
      OnboardingService,
      CycleService,
      RitualsService,
      StatsService,
      JwtStrategy,
      JwtAuthGuard,
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
