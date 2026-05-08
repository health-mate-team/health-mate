import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DailyRitual } from '../entities/daily-ritual.entity';
import { DailyStat } from '../entities/daily-stat.entity';
import { UserCycle } from '../entities/user-cycle.entity';
import { User } from '../entities/user.entity';
import { XpLog } from '../entities/xp-log.entity';
import { RitualsService } from './rituals.service';

const mockUser = (): User =>
  ({ id: 'user-1', email: 'test@test.com', name: '테스터' }) as User;

function makeRepo<T extends object>(
  overrides: Partial<Record<keyof T, unknown>> = {},
) {
  return {
    findOne: jest.fn(),
    create: jest.fn((data: Partial<T>) => ({ ...data })),
    save: jest.fn((e: T) => Promise.resolve(e)),
    ...overrides,
  };
}

describe('RitualsService', () => {
  let service: RitualsService;
  let ritualRepo: ReturnType<typeof makeRepo>;
  let statRepo: ReturnType<typeof makeRepo>;
  let cycleRepo: ReturnType<typeof makeRepo>;
  let xpLogRepo: ReturnType<typeof makeRepo>;

  beforeEach(async () => {
    ritualRepo = makeRepo<DailyRitual>();
    statRepo = makeRepo<DailyStat>();
    cycleRepo = makeRepo<UserCycle>();
    xpLogRepo = makeRepo<XpLog>();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RitualsService,
        { provide: getRepositoryToken(DailyRitual), useValue: ritualRepo },
        { provide: getRepositoryToken(DailyStat), useValue: statRepo },
        { provide: getRepositoryToken(UserCycle), useValue: cycleRepo },
        { provide: getRepositoryToken(XpLog), useValue: xpLogRepo },
      ],
    }).compile();

    service = module.get<RitualsService>(RitualsService);
  });

  describe('morningMood', () => {
    it('[Happy] 기분 3 → XP +10, mood_score=50 반환', async () => {
      const today = new Date().toISOString().slice(0, 10);
      ritualRepo.findOne.mockResolvedValue(null);
      ritualRepo.create.mockReturnValue({
        userId: 'user-1',
        date: today,
        xpEarned: 0,
      });
      statRepo.findOne.mockResolvedValue(null);
      statRepo.create.mockReturnValue({
        userId: 'user-1',
        date: today,
        energyScore: 50,
        hydrationScore: 50,
        moodScore: 50,
        waterCups: 0,
        totalXp: 0,
        level: 1,
        streak: 0,
      });
      cycleRepo.findOne.mockResolvedValue(null);

      const result = await service.morningMood(mockUser(), { mood: 3 });
      expect(result.xp_earned).toBe(10);
      expect(result.mood).toBe(3);
      expect(result).toHaveProperty('recommended_promise');
    });

    it('[오류] 이미 기분 기록된 경우 → BadRequestException', async () => {
      ritualRepo.findOne.mockResolvedValue({ morningMood: 4, xpEarned: 10 });
      await expect(
        service.morningMood(mockUser(), { mood: 3 }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('evening', () => {
    it('[Happy] promise_kept=true → xp_earned: 60', async () => {
      const today = new Date().toISOString().slice(0, 10);
      ritualRepo.findOne.mockResolvedValue({
        eveningCompleted: false,
        xpEarned: 10,
      });
      statRepo.findOne
        .mockResolvedValueOnce({
          userId: 'user-1',
          date: today,
          totalXp: 10,
          level: 1,
          streak: 0,
        })
        .mockResolvedValueOnce(null); // yesterday
      xpLogRepo.create.mockReturnValue({});

      const result = await service.evening(mockUser(), { promise_kept: true });
      expect(result.xp_earned).toBe(60);
      expect(result.promise_kept).toBe(true);
    });

    it('[Happy] promise_kept=false → xp_earned: 10', async () => {
      const today = new Date().toISOString().slice(0, 10);
      ritualRepo.findOne.mockResolvedValue({
        eveningCompleted: false,
        xpEarned: 10,
      });
      statRepo.findOne
        .mockResolvedValueOnce({
          userId: 'user-1',
          date: today,
          totalXp: 10,
          level: 1,
          streak: 0,
        })
        .mockResolvedValueOnce(null);
      xpLogRepo.create.mockReturnValue({});

      const result = await service.evening(mockUser(), { promise_kept: false });
      expect(result.xp_earned).toBe(10);
    });

    it('[오류] 이미 저녁 완료된 경우 → BadRequestException', async () => {
      ritualRepo.findOne.mockResolvedValue({ eveningCompleted: true });
      await expect(
        service.evening(mockUser(), { promise_kept: true }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
