import {
  Body,
  Controller,
  Get,
  Patch,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { CycleService } from './cycle.service';
import { UpdateCycleSettingsDto } from './dto/update-cycle-settings.dto';

interface AuthRequest extends Request {
  user: User;
}

@Controller('cycle')
@UseGuards(JwtAuthGuard)
export class CycleController {
  constructor(private readonly cycleService: CycleService) {}

  @Get('current')
  async getCurrent(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.cycleService.getCurrent(req.user));
  }

  @Patch('settings')
  async updateSettings(
    @Request() req: AuthRequest,
    @Body() dto: UpdateCycleSettingsDto,
  ) {
    return ApiResponse.success(
      await this.cycleService.updateSettings(req.user, dto),
    );
  }

  @Get('calendar')
  async getCalendar(
    @Request() req: AuthRequest,
    @Query('year') year: string,
    @Query('month') month: string,
  ) {
    const y = parseInt(year, 10) || new Date().getFullYear();
    const m = parseInt(month, 10) || new Date().getMonth() + 1;
    return ApiResponse.success(
      await this.cycleService.getCalendar(req.user, y, m),
    );
  }
}
