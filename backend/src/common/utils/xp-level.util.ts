// XP 임계값별 레벨: 0→1, 300→5, 700→10, 1500→20, 3000→30
const LEVEL_THRESHOLDS: { xp: number; level: number }[] = [
  { xp: 3000, level: 30 },
  { xp: 1500, level: 20 },
  { xp: 700, level: 10 },
  { xp: 300, level: 5 },
  { xp: 0, level: 1 },
];

export function calculateLevel(totalXp: number): number {
  for (const { xp, level } of LEVEL_THRESHOLDS) {
    if (totalXp >= xp) return level;
  }
  return 1;
}

export function xpToNextLevel(totalXp: number): number {
  for (let i = LEVEL_THRESHOLDS.length - 1; i >= 0; i--) {
    if (totalXp < LEVEL_THRESHOLDS[i].xp) {
      return LEVEL_THRESHOLDS[i].xp - totalXp;
    }
  }
  return 0; // 최고 레벨
}

export function evolutionStage(level: number): {
  stage: number;
  name: string;
  colorToken: string;
  xpThreshold: number;
} {
  if (level >= 30)
    return {
      stage: 5,
      name: '마스터 모아',
      colorToken: 'OwnerColors.goldStar',
      xpThreshold: 3000,
    };
  if (level >= 20)
    return {
      stage: 4,
      name: '빛남 모아',
      colorToken: 'OwnerColors.accentGold',
      xpThreshold: 1500,
    };
  if (level >= 10)
    return {
      stage: 3,
      name: '개화 모아',
      colorToken: 'OwnerColors.accentPurple',
      xpThreshold: 700,
    };
  if (level >= 5)
    return {
      stage: 2,
      name: '성장 모아',
      colorToken: 'OwnerColors.accentMint',
      xpThreshold: 300,
    };
  return {
    stage: 1,
    name: '새싹 모아',
    colorToken: 'OwnerColors.coral200',
    xpThreshold: 0,
  };
}
