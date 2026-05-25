import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { CompleteOnboardingDto } from './dto/complete-onboarding.dto';
import { OnboardingService } from './onboarding.service';

const mockUser = (): User =>
  ({
    id: 'uuid-1',
    email: 'test@owner.app',
    password: 'hashed',
    name: '테스터',
    isOnboardingCompleted: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  }) as User;

const baseDto = (): CompleteOnboardingDto => ({
  name: '테스터',
  goal_type: 'energy',
  last_period_start_date: '2026-04-28',
  average_cycle_length: 28,
  average_period_length: 5,
  is_irregular: false,
});

describe('OnboardingService', () => {
  let service: OnboardingService;

  const mockSave = jest
    .fn()
    .mockImplementation((e: unknown) => Promise.resolve(e));
  const mockCreate = jest
    .fn()
    .mockImplementation((dto: unknown) => ({ ...(dto as object) }));

  beforeEach(async () => {
    jest.clearAllMocks();

    const module = await Test.createTestingModule({
      providers: [
        OnboardingService,
        {
          provide: getRepositoryToken(User),
          useValue: { save: mockSave },
        },
        {
          provide: getRepositoryToken(UserCycle),
          useValue: { create: mockCreate, save: mockSave },
        },
        {
          provide: getRepositoryToken(DailyStat),
          useValue: { create: mockCreate, save: mockSave },
        },
      ],
    }).compile();

    service = module.get(OnboardingService);
  });

  it('[Happy] 온보딩 완료 → initial_stats + current_phase 반환', async () => {
    const result = await service.complete(mockUser(), baseDto());

    expect(result).toHaveProperty('initial_stats');
    expect(result).toHaveProperty('current_phase');
    expect(['menstrual', 'follicular', 'ovulation', 'luteal']).toContain(
      result.current_phase,
    );
  });

  it('[Happy] user.isOnboardingCompleted가 true로 업데이트됨', async () => {
    const user = mockUser();
    await service.complete(user, baseDto());

    expect(user.isOnboardingCompleted).toBe(true);
  });

  it('[Happy] initial_stats 초기값 검증 (energy/hydration/mood = 50)', async () => {
    const result = await service.complete(mockUser(), baseDto());

    expect(result.initial_stats.energy_score).toBe(50);
    expect(result.initial_stats.hydration_score).toBe(50);
    expect(result.initial_stats.mood_score).toBe(50);
    expect(result.initial_stats.total_xp).toBe(0);
    expect(result.initial_stats.level).toBe(1);
  });

  describe('calculatePhase (cycle phase 계산)', () => {
    const testPhase = async (daysAgo: number): Promise<string> => {
      const d = new Date();
      d.setDate(d.getDate() - daysAgo);
      const dto = {
        ...baseDto(),
        last_period_start_date: d.toISOString().slice(0, 10),
      };
      const result = await service.complete(mockUser(), dto);
      return result.current_phase;
    };

    it('[경계] 생리 시작 직후 (day 1) → menstrual', async () => {
      expect(await testPhase(0)).toBe('menstrual');
    });

    it('[경계] 생리 종료 직후 (day 8) → follicular', async () => {
      expect(await testPhase(7)).toBe('follicular');
    });
  });
});
