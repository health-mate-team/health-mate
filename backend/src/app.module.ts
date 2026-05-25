import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ActionsModule } from './actions/actions.module';
import { AuthModule } from './auth/auth.module';
import { CodesModule } from './codes/codes.module';
import { CommonModule } from './common/common.module';
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
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USER', 'healthmate'),
        password: config.get('DB_PASSWORD', 'healthmate123'),
        database: config.get('DB_NAME', 'health_mate'),
        autoLoadEntities: true,
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
      inject: [ConfigService],
    }),
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
  providers: [AppService],
})
export class AppModule {}
