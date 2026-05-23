import { Controller, Get, Query, Request, UseGuards } from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { StatsService } from './stats.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('stats')
@UseGuards(JwtAuthGuard)
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('today')
  async getToday(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.statsService.getToday(req.user));
  }

  @Get('history')
  async getHistory(@Request() req: AuthRequest, @Query('days') days?: string) {
    return ApiResponse.success(
      await this.statsService.getHistory(req.user, Number(days ?? 30)),
    );
  }
}
