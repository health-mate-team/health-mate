import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { RewardsService } from './rewards.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('rewards')
@UseGuards(JwtAuthGuard)
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get('summary')
  async getSummary(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.rewardsService.getSummary(req.user));
  }
}
