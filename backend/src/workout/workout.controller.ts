import {
  Body,
  Controller,
  Get,
  HttpCode,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { WorkoutCompleteDto, WorkoutSkipDto } from './dto/workout.dto';
import { WorkoutService } from './workout.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('workout')
@UseGuards(JwtAuthGuard)
export class WorkoutController {
  constructor(private readonly workoutService: WorkoutService) {}

  @Get('recommend')
  async recommend(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.workoutService.recommend(req.user));
  }

  @Post('complete')
  @HttpCode(200)
  async complete(@Request() req: AuthRequest, @Body() dto: WorkoutCompleteDto) {
    return ApiResponse.success(
      await this.workoutService.complete(req.user, dto),
    );
  }

  @Post('skip')
  @HttpCode(200)
  async skip(@Request() req: AuthRequest, @Body() dto: WorkoutSkipDto) {
    return ApiResponse.success(await this.workoutService.skip(req.user, dto));
  }
}
