import {
  Body,
  Controller,
  HttpCode,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { RegisterDto } from './dto/register.dto';

interface AuthRequest extends Request {
  user: User;
}

// 인증 엔드포인트는 브루트포스 방지를 위해 IP당 60초 5회로 제한(H-1).
const AUTH_THROTTLE = { default: { ttl: 60000, limit: 5 } };

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @Throttle(AUTH_THROTTLE)
  async register(@Body() dto: RegisterDto) {
    return ApiResponse.success(await this.authService.register(dto));
  }

  @Post('login')
  @HttpCode(200)
  @Throttle(AUTH_THROTTLE)
  async login(@Body() dto: LoginDto) {
    return ApiResponse.success(await this.authService.login(dto));
  }

  @Post('refresh')
  @HttpCode(200)
  @Throttle(AUTH_THROTTLE)
  async refresh(@Body() dto: RefreshDto) {
    return ApiResponse.success(
      await this.authService.refresh(dto.refresh_token),
    );
  }

  @Post('logout')
  @HttpCode(200)
  @UseGuards(JwtAuthGuard)
  async logout(@Request() req: AuthRequest) {
    await this.authService.logout(req.user.id);
    return ApiResponse.success({ message: 'logged out' });
  }
}
