import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { TypeOrmModule } from '@nestjs/typeorm';
import * as Joi from 'joi';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ActionsModule } from './actions/actions.module';
import { AuthModule } from './auth/auth.module';
import { CodesModule } from './codes/codes.module';
import { CommonModule } from './common/common.module';
import { RedisModule } from './common/redis/redis.module';
import { CycleModule } from './cycle/cycle.module';
import { NutritionModule } from './nutrition/nutrition.module';
import { OnboardingModule } from './onboarding/onboarding.module';
import { RewardsModule } from './rewards/rewards.module';
import { RitualsModule } from './rituals/rituals.module';
import { StatsModule } from './stats/stats.module';
import { UsersModule } from './users/users.module';
import { WorkoutModule } from './workout/workout.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        JWT_SECRET: Joi.string().min(16).required(),
        DB_PASSWORD: Joi.string().required(),
        NODE_ENV: Joi.string()
          .valid('development', 'production', 'test')
          .default('production'),
      }),
      validationOptions: { allowUnknown: true },
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USER', 'healthmate'),
        password: config.get<string>('DB_PASSWORD'),
        database: config.get('DB_NAME', 'health_mate'),
        autoLoadEntities: true,
        synchronize: config.get('NODE_ENV') !== 'production',
        // 운영(synchronize OFF)에서는 부팅 시 마이그레이션을 자동 실행해 스키마를 반영.
        // dev/test는 synchronize가 담당하므로 비활성(테스트 하니스 회귀 방지).
        migrations: [join(__dirname, 'migrations', '*.{ts,js}')],
        migrationsRun: config.get('NODE_ENV') === 'production',
      }),
      inject: [ConfigService],
    }),
    // 전역 기본 레이트리밋(IP당 60초 200회). 인증 엔드포인트는 @Throttle로 5회로 강화(H-1).
    ThrottlerModule.forRoot([{ name: 'default', ttl: 60000, limit: 200 }]),
    RedisModule,
    CommonModule,
    AuthModule,
    CodesModule,
    UsersModule,
    OnboardingModule,
    CycleModule,
    RitualsModule,
    StatsModule,
    ActionsModule,
    RewardsModule,
    WorkoutModule,
    NutritionModule,
  ],
  controllers: [AppController],
  providers: [AppService, { provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
