import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { AuthService } from './auth.service';

const mockUser = (): User =>
  ({
    id: 'uuid-1',
    email: 'test@owner.app',
    password: '$2b$12$hashedpw',
    name: '테스터',
    isOnboardingCompleted: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  }) as User;

describe('AuthService', () => {
  let service: AuthService;
  let userRepo: jest.Mocked<Repository<User>>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
            findOneOrFail: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn().mockReturnValue('mock_jwt_token'),
            verify: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(AuthService);
    userRepo = module.get(getRepositoryToken(User));
  });

  describe('register', () => {
    it('[Happy] 신규 이메일로 회원가입 → access_token 반환', async () => {
      userRepo.findOne.mockResolvedValue(null);
      userRepo.create.mockReturnValue(mockUser());
      userRepo.save.mockResolvedValue(mockUser());

      const result = await service.register({
        email: 'new@owner.app',
        password: 'Test1234!',
        name: '신규',
      });

      expect(result).toHaveProperty('access_token', 'mock_jwt_token');
      // eslint-disable-next-line @typescript-eslint/unbound-method
      expect(userRepo.save).toHaveBeenCalledTimes(1);
    });

    it('[Happy] 저장된 비밀번호는 bcrypt 해시값 (평문 불일치)', async () => {
      userRepo.findOne.mockResolvedValue(null);
      let savedUser: Partial<User> = {};
      userRepo.create.mockImplementation((dto) => ({ ...dto }) as User);
      userRepo.save.mockImplementation((u: User) => {
        savedUser = u;
        return Promise.resolve(u);
      });

      await service.register({
        email: 'hash@owner.app',
        password: 'plain123!',
        name: '해시',
      });

      expect(savedUser.password).not.toBe('plain123!');
      expect(await bcrypt.compare('plain123!', savedUser.password!)).toBe(true);
    });

    it('[오류] 중복 이메일 → ConflictException(409)', async () => {
      userRepo.findOne.mockResolvedValue(mockUser());

      await expect(
        service.register({
          email: 'test@owner.app',
          password: 'pw',
          name: 'dup',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('login', () => {
    it('[Happy] 올바른 credentials → access_token + is_onboarding_completed 반환', async () => {
      const user = mockUser();
      user.password = await bcrypt.hash('Test1234!', 12);
      userRepo.findOne.mockResolvedValue(user);

      const result = await service.login({
        email: user.email,
        password: 'Test1234!',
      });

      expect(result).toHaveProperty('access_token');
      expect(result).toHaveProperty('is_onboarding_completed', false);
    });

    it('[오류] 존재하지 않는 이메일 → UnauthorizedException', async () => {
      userRepo.findOne.mockResolvedValue(null);

      await expect(
        service.login({ email: 'ghost@owner.app', password: 'pw' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('[경계] 비밀번호 불일치 → UnauthorizedException', async () => {
      const user = mockUser();
      user.password = await bcrypt.hash('correct!', 12);
      userRepo.findOne.mockResolvedValue(user);

      await expect(
        service.login({ email: user.email, password: 'wrong!' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
