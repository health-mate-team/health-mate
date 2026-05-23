export enum BadgeCode {
  FirstRitual = 'first_ritual',
  SevenDayStreak = '7day_streak',
  ThirtyDayStreak = '30day_streak',
  WaterGoal = 'water_goal',
  WalkComplete = 'walk_complete',
}

export const BADGE_META: Record<
  BadgeCode,
  { name: string; description: string }
> = {
  [BadgeCode.FirstRitual]: {
    name: '첫 의식 완료',
    description: '처음으로 아침 의식을 완료했어요',
  },
  [BadgeCode.SevenDayStreak]: {
    name: '7일 연속',
    description: '7일 연속으로 저녁 의식을 완료했어요',
  },
  [BadgeCode.ThirtyDayStreak]: {
    name: '30일 연속',
    description: '30일 연속으로 저녁 의식을 완료했어요',
  },
  [BadgeCode.WaterGoal]: {
    name: '수분 목표 달성',
    description: '하루 물 8잔 목표를 달성했어요',
  },
  [BadgeCode.WalkComplete]: {
    name: '첫 산책 완료',
    description: '처음으로 산책을 완료했어요',
  },
};
