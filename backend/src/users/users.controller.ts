import {
  Body,
  Controller,
  Get,
  Patch,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import { UsersService } from './users.service';

interface AuthRequest extends Request {
  user: User;
}

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getMe(@Request() req: AuthRequest) {
    return ApiResponse.success(this.usersService.getMe(req.user));
  }

  @Patch('me')
  async updateMe(@Request() req: AuthRequest, @Body() dto: UpdateUserDto) {
    return ApiResponse.success(await this.usersService.updateMe(req.user, dto));
  }
}
