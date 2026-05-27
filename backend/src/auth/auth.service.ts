import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { TokenBlacklistService } from '../common/redis/token-blacklist.service';
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
    private readonly blacklist: TokenBlacklistService,
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
      if (payload.type !== 'refresh') {
        throw new UnauthorizedException('리프레시 토큰이 아닙니다');
      }
      if (await this.blacklist.isInvalidated(payload.sub, payload.iat)) {
        throw new UnauthorizedException('로그아웃된 세션입니다');
      }
      const user = await this.userRepo.findOne({ where: { id: payload.sub } });
      if (!user) throw new UnauthorizedException('사용자를 찾을 수 없습니다');
      const access_token = this.issueAccessToken(user);
      return { access_token };
    } catch {
      throw new UnauthorizedException('유효하지 않은 리프레시 토큰입니다');
    }
  }

  // 로그아웃: 현재 시점 이전 발급된 모든 토큰(access·refresh) 무효화(H-3).
  async logout(userId: string): Promise<void> {
    await this.blacklist.invalidateUser(userId);
  }

  private issueAccessToken(user: User): string {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      type: 'access',
    };
    return this.jwtService.sign(payload, { expiresIn: '7d' });
  }
}
