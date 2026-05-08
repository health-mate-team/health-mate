import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './strategies/jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const exists = await this.userRepo.findOne({ where: { email: dto.email } });
    if (exists) throw new ConflictException('이미 등록된 이메일입니다');

    const hashed = await bcrypt.hash(dto.password, 12);
    const user = this.userRepo.create({
      email: dto.email,
      password: hashed,
      name: dto.name,
    });
    await this.userRepo.save(user);

    const access_token = this.issueAccessToken(user);
    return { access_token };
  }

  async login(dto: LoginDto) {
    const user = await this.userRepo.findOne({ where: { email: dto.email } });
    if (!user)
      throw new UnauthorizedException('이메일 또는 비밀번호가 틀렸습니다');

    const valid = await bcrypt.compare(dto.password, user.password);
    if (!valid)
      throw new UnauthorizedException('이메일 또는 비밀번호가 틀렸습니다');

    const access_token = this.issueAccessToken(user);
    return {
      access_token,
      is_onboarding_completed: user.isOnboardingCompleted,
    };
  }

  async refresh(refreshToken: string) {
    try {
      const payload = this.jwtService.verify<JwtPayload>(refreshToken);
      const user = await this.userRepo.findOneOrFail({
        where: { id: payload.sub },
      });
      const access_token = this.issueAccessToken(user);
      return { access_token };
    } catch {
      throw new UnauthorizedException('유효하지 않은 리프레시 토큰입니다');
    }
  }

  private issueAccessToken(user: User): string {
    const payload: JwtPayload = { sub: user.id, email: user.email };
    return this.jwtService.sign(payload);
  }
}
