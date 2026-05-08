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
import { ActionsService } from './actions.service';
import { WaterActionDto } from './dto/water-action.dto';
import { WalkCompleteDto, WalkStartDto } from './dto/walk-action.dto';

interface AuthRequest extends Request {
  user: User;
}

@Controller('actions')
@UseGuards(JwtAuthGuard)
export class ActionsController {
  constructor(private readonly actionsService: ActionsService) {}

  @Post('water')
  @HttpCode(200)
  async addWater(@Request() req: AuthRequest, @Body() dto: WaterActionDto) {
    return ApiResponse.success(
      await this.actionsService.addWater(req.user, dto),
    );
  }

  @Get('water/today')
  async getWaterToday(@Request() req: AuthRequest) {
    return ApiResponse.success(
      await this.actionsService.getWaterToday(req.user),
    );
  }

  @Post('walk/start')
  async startWalk(@Request() req: AuthRequest, @Body() dto: WalkStartDto) {
    return ApiResponse.success(
      await this.actionsService.startWalk(req.user, dto),
    );
  }

  @Post('walk/complete')
  @HttpCode(200)
  async completeWalk(
    @Request() req: AuthRequest,
    @Body() dto: WalkCompleteDto,
  ) {
    return ApiResponse.success(
      await this.actionsService.completeWalk(req.user, dto),
    );
  }
}
