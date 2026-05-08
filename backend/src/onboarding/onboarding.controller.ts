import {
  Body,
  Controller,
  HttpCode,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { CompleteOnboardingDto } from './dto/complete-onboarding.dto';
import { OnboardingService } from './onboarding.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('onboarding')
export class OnboardingController {
  constructor(private readonly onboardingService: OnboardingService) {}

  @Post('complete')
  @HttpCode(200)
  @UseGuards(JwtAuthGuard)
  async complete(
    @Request() req: AuthRequest,
    @Body() dto: CompleteOnboardingDto,
  ) {
    return ApiResponse.success(
      await this.onboardingService.complete(req.user, dto),
    );
  }
}
