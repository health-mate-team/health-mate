import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Code } from '../entities/code.entity';
import { CodesController } from './codes.controller';
import { CodesService } from './codes.service';

@Module({
  imports: [TypeOrmModule.forFeature([Code])],
  controllers: [CodesController],
  providers: [CodesService],
  exports: [CodesService],
})
export class CodesModule {}
