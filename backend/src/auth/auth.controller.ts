import { Body, Controller, HttpCode, Post } from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { RegisterDto } from './dto/register.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() dto: RegisterDto) {
    return ApiResponse.success(await this.authService.register(dto));
  }

  @Post('login')
  @HttpCode(200)
  async login(@Body() dto: LoginDto) {
    return ApiResponse.success(await this.authService.login(dto));
  }

  @Post('refresh')
  @HttpCode(200)
  async refresh(@Body() dto: RefreshDto) {
    return ApiResponse.success(
      await this.authService.refresh(dto.refresh_token),
    );
  }

  @Post('logout')
  @HttpCode(200)
  logout() {
    return ApiResponse.success({ message: 'logged out' });
  }
}
