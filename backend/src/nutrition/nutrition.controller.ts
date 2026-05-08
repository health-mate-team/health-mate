import {
  Body,
  Controller,
  Get,
  HttpCode,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { NutritionLogDto } from './dto/nutrition.dto';
import { NutritionService } from './nutrition.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('nutrition')
@UseGuards(JwtAuthGuard)
export class NutritionController {
  constructor(private readonly nutritionService: NutritionService) {}

  @Get('search')
  search(@Query('q') q: string, @Query('limit') limit?: string) {
    const limitNum = limit ? Math.min(parseInt(limit, 10), 20) : 10;
    return ApiResponse.success(this.nutritionService.search(q ?? '', limitNum));
  }

  @Post('logs')
  @HttpCode(200)
  async logMeal(@Request() req: AuthRequest, @Body() dto: NutritionLogDto) {
    return ApiResponse.success(
      await this.nutritionService.logMeal(req.user, dto),
    );
  }

  @Get('today')
  async getToday(@Request() req: AuthRequest) {
    return ApiResponse.success(await this.nutritionService.getToday(req.user));
  }
}
