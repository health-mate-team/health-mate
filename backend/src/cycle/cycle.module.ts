import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserCycle } from '../entities/user-cycle.entity';
import { CycleController } from './cycle.controller';
import { CycleService } from './cycle.service';

@Module({
  imports: [TypeOrmModule.forFeature([UserCycle])],
  controllers: [CycleController],
  providers: [CycleService],
  exports: [CycleService],
})
export class CycleModule {}
