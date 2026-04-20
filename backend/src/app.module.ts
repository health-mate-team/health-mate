import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
// TODO: 각 Feature 모듈 import 추가 (구현 시)
// import { AuthModule } from './auth/auth.module';
// import { UsersModule } from './users/users.module';
// import { WorkoutModule } from './workout/workout.module';
// import { NutritionModule } from './nutrition/nutrition.module';

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
    // AuthModule,
    // UsersModule,
    // WorkoutModule,
    // NutritionModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
