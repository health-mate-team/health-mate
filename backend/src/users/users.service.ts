import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  getMe(user: User) {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      is_onboarding_completed: user.isOnboardingCompleted,
      created_at: user.createdAt,
    };
  }

  async updateMe(user: User, dto: UpdateUserDto) {
    if (dto.name) user.name = dto.name;
    await this.userRepo.save(user);
    return this.getMe(user);
  }
}
