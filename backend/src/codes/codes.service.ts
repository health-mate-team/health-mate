import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Code } from '../entities/code.entity';
import { CodeItemDto } from './dto/code-response.dto';

const SEED_DATA: Omit<Code, 'id' | 'createdAt' | 'updatedAt'>[] = [
  // mood: 아침 기분 (numeric_value = API mood 파라미터 값)
  {
    groupId: 'mood',
    displayOrder: 0,
    labels: { ko: '좋아요', en: 'Great' },
    emoji: '✨',
    numericValue: 5,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'mood',
    displayOrder: 1,
    labels: { ko: '보통', en: 'Okay' },
    emoji: '☕',
    numericValue: 3,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'mood',
    displayOrder: 2,
    labels: { ko: '피곤', en: 'Tired' },
    emoji: '😴',
    numericValue: 2,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'mood',
    displayOrder: 3,
    labels: { ko: '지침', en: 'Exhausted' },
    emoji: '💧',
    numericValue: 1,
    metadata: {},
    isActive: true,
  },

  // evening_mood: 저녁 기분 (numeric_value 없음)
  {
    groupId: 'evening_mood',
    displayOrder: 0,
    labels: { ko: '평온', en: 'Calm' },
    emoji: '😌',
    numericValue: null,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'evening_mood',
    displayOrder: 1,
    labels: { ko: '기쁨', en: 'Happy' },
    emoji: '😊',
    numericValue: null,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'evening_mood',
    displayOrder: 2,
    labels: { ko: '뿌듯', en: 'Strong' },
    emoji: '💪',
    numericValue: null,
    metadata: {},
    isActive: true,
  },
  {
    groupId: 'evening_mood',
    displayOrder: 3,
    labels: { ko: '지침', en: 'Tired' },
    emoji: '😮‍💨',
    numericValue: null,
    metadata: {},
    isActive: true,
  },

  // goal_option: 온보딩 목표
  {
    groupId: 'goal_option',
    displayOrder: 0,
    labels: { ko: '더 활기차게', en: 'More Energetic' },
    emoji: '⚡',
    numericValue: null,
    metadata: {
      accent_color: 'statEnergy',
      subtitle: '에너지 넘치는 하루를 만들어요',
      goal_type: 'energy',
    },
    isActive: true,
  },
  {
    groupId: 'goal_option',
    displayOrder: 1,
    labels: { ko: '건강한 습관', en: 'Healthy Habits' },
    emoji: '💧',
    numericValue: null,
    metadata: {
      accent_color: 'statHydration',
      subtitle: '물 마시기, 식단 챙기기부터 차근차근',
      goal_type: 'hydration',
    },
    isActive: true,
  },
  {
    groupId: 'goal_option',
    displayOrder: 2,
    labels: { ko: '잘 쉬고 싶어', en: 'Better Rest' },
    emoji: '🌙',
    numericValue: null,
    metadata: {
      accent_color: 'statRest',
      subtitle: '충분한 수면과 회복에 집중해요',
      goal_type: 'rest',
    },
    isActive: true,
  },
  {
    groupId: 'goal_option',
    displayOrder: 3,
    labels: { ko: '몸이 가벼워졌으면', en: 'Feel Lighter' },
    emoji: '🌸',
    numericValue: null,
    metadata: {
      accent_color: 'accentMint',
      subtitle: '꾸준한 운동과 식단 관리로 천천히',
      goal_type: 'fitness',
    },
    isActive: true,
  },
];

@Injectable()
export class CodesService implements OnModuleInit {
  constructor(
    @InjectRepository(Code)
    private readonly codeRepo: Repository<Code>,
  ) {}

  async onModuleInit(): Promise<void> {
    const count = await this.codeRepo.count();
    if (count === 0) {
      await this.codeRepo.save(SEED_DATA.map((d) => this.codeRepo.create(d)));
    }
  }

  private toDto(code: Code): CodeItemDto {
    return {
      id: code.id,
      groupId: code.groupId,
      displayOrder: code.displayOrder,
      labels: code.labels,
      emoji: code.emoji ?? null,
      numericValue: code.numericValue ?? null,
      metadata: code.metadata,
    };
  }

  async getByGroup(groupId: string): Promise<CodeItemDto[]> {
    const codes = await this.codeRepo.find({
      where: { groupId, isActive: true },
      order: { displayOrder: 'ASC' },
    });
    return codes.map((c) => this.toDto(c));
  }

  async getByGroups(
    groupIds: string[],
  ): Promise<Record<string, CodeItemDto[]>> {
    const codes = await this.codeRepo.find({
      where: { groupId: In(groupIds), isActive: true },
      order: { displayOrder: 'ASC' },
    });

    const result: Record<string, CodeItemDto[]> = {};
    for (const gid of groupIds) {
      result[gid] = codes
        .filter((c) => c.groupId === gid)
        .map((c) => this.toDto(c));
    }
    return result;
  }
}
