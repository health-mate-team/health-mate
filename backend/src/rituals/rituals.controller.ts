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
import { EveningDto } from './dto/evening.dto';
import { MorningMoodDto } from './dto/morning-mood.dto';
import { MorningPromiseDto } from './dto/morning-promise.dto';
import { RitualsService } from './rituals.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('rituals')
@UseGuards(JwtAuthGuard)
export class RitualsController {
  constructor(private readonly ritualsService: RitualsService) {}

  @Get('today')
  async getToday(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.ritualsService.getToday(req.user));
  }

  @Post('morning/mood')
  @HttpCode(200)
  async morningMood(@Request() req: AuthRequest, @Body() dto: MorningMoodDto) {
    return ApiResponse.success(
      await this.ritualsService.morningMood(req.user, dto),
    );
  }

  @Post('morning/promise')
  @HttpCode(200)
  async morningPromise(
    @Request() req: AuthRequest,
    @Body() dto: MorningPromiseDto,
  ) {
    return ApiResponse.success(
      await this.ritualsService.morningPromise(req.user, dto),
    );
  }

  @Post('evening')
  @HttpCode(200)
  async evening(@Request() req: AuthRequest, @Body() dto: EveningDto) {
    return ApiResponse.success(
      await this.ritualsService.evening(req.user, dto),
    );
  }
}
