import 'package:health_mate/core/theme/owner/owner_colors.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/entities/phase_profile.dart';
import 'package:health_mate/shared/widgets/owner/owner_moa_avatar.dart';

/// 02_CYCLE_OS.json phases[*] 의 정적 프로필.
/// 모든 추천·메시지·시각의 SOURCE OF TRUTH.
/// 변경 시 02_CYCLE_OS.json 도 함께 업데이트할 것.
final Map<CyclePhase, PhaseProfile> kPhaseProfiles = {
  CyclePhase.menstrual: const PhaseProfile(
    energyLevel: 'low',
    commonSymptoms: ['피로', '복통', '감정 기복', '수면 욕구 증가'],
    workoutIntensity: 'very_low',
    workoutTypesPriority: ['stretching_yoga', 'breathing_meditation'],
    workoutTypesAvoid: ['hiit', 'strength_training'],
    foodFocus: ['철분 (붉은 고기, 시금치)', '따뜻한 음료', '생강·계피'],
    foodAvoid: ['과한 카페인', '찬 음식'],
    restEmphasis: 'high',
    sleepTargetHours: 8,
    voice: '차분하고 따뜻함',
    exampleMessages: [
      '오늘은 누워있어도 괜찮아',
      '몸이 무거운 거 자연스러워',
      '따뜻한 차 한 잔, 어때?',
      '잘 쉬는 것도 운동이야',
    ],
    avoidWords: ['힘내', '이겨내자', '도전!'],
    moaExpression: OwnerMoaExpression.sleepy,
    moaDecorations: ['💤'],
    colorToken: OwnerColors.cocoa800,
    defaultDayRangeStart: 1,
    defaultDayRangeEnd: 5,
  ),
  CyclePhase.follicular: const PhaseProfile(
    energyLevel: 'rising',
    commonSymptoms: ['에너지 회복', '기분 상승', '새 도전 욕구'],
    workoutIntensity: 'moderate_to_high',
    workoutTypesPriority: ['strength_training', 'light_cardio', 'hiit'],
    workoutTypesAvoid: [],
    foodFocus: ['복합탄수화물 (퀴노아, 현미)', '신선 과일 채소', '발효식품'],
    foodAvoid: [],
    restEmphasis: 'moderate',
    sleepTargetHours: 7,
    voice: '밝고 설레는 톤',
    exampleMessages: [
      '오늘 새로운 거 해볼까?',
      '에너지가 올라오는 게 느껴져?',
      '지금이 도전하기 좋은 때야',
      '새 운동 한 번 시도해봐',
    ],
    avoidWords: ['천천히', '쉬어도 돼'],
    moaExpression: OwnerMoaExpression.happy,
    moaDecorations: ['🌱', '✨'],
    colorToken: OwnerColors.beige300,
    defaultDayRangeStart: 6,
    defaultDayRangeEnd: 13,
  ),
  CyclePhase.ovulatory: const PhaseProfile(
    energyLevel: 'peak',
    commonSymptoms: ['최고 컨디션', '자신감', '사회성 증가'],
    workoutIntensity: 'high',
    workoutTypesPriority: ['hiit', 'strength_training', 'light_cardio'],
    workoutTypesAvoid: [],
    foodFocus: ['필수 지방산 (아보카도, 견과류)', '비타민 C', '충분한 단백질'],
    foodAvoid: [],
    restEmphasis: 'low',
    sleepTargetHours: 7,
    voice: '에너지 넘치는 톤',
    exampleMessages: [
      '오늘 PR 깨자!',
      '지금 컨디션이 최고야',
      '한계 한 번 넘어볼까?',
      '오늘 모인 모임 다 가도 돼',
    ],
    avoidWords: ['무리하지 마'],
    moaExpression: OwnerMoaExpression.starEyes,
    moaDecorations: ['⭐', '🔥'],
    colorToken: OwnerColors.coral500,
    defaultDayRangeStart: 14,
    defaultDayRangeEnd: 16,
  ),
  CyclePhase.luteal: const PhaseProfile(
    energyLevel: 'declining',
    commonSymptoms: ['PMS (후반)', '단 거 욕구', '감정 기복', '수면 변화'],
    workoutIntensity: 'moderate_then_low',
    workoutTypesPriority: ['stretching_yoga', 'light_cardio', 'breathing_meditation'],
    workoutTypesAvoid: ['hiit'],
    foodFocus: ['다크 초콜릿 (소량)', '마그네슘 (호박씨, 견과류)', '복합탄수화물'],
    foodAvoid: ['과한 설탕', '알코올 (PMS 악화)'],
    restEmphasis: 'moderate_to_high',
    sleepTargetHours: 8,
    voice: '이해하고 위로하는 톤',
    exampleMessages: [
      '단 거 땡기는 거 자연스러워. 한 조각 OK',
      '황체기라서 그래. 자책하지 마',
      '천천히 가도 괜찮아',
      '오늘은 가벼운 산책 어때?',
    ],
    avoidWords: ['참아', '조절해', '힘내자'],
    moaExpression: OwnerMoaExpression.default_,
    moaDecorations: ['🍂'],
    colorToken: OwnerColors.accentLavender,
    defaultDayRangeStart: 17,
    defaultDayRangeEnd: 28,
  ),
};

/// 황체기 후반(luteal_late)에서는 모아 표정을 sleepy로 전환.
OwnerMoaExpression moaExpressionFor(CyclePhase phase, {LutealSubPhase? lutealSub}) {
  if (phase == CyclePhase.luteal && lutealSub == LutealSubPhase.late) {
    return OwnerMoaExpression.sleepy;
  }
  return kPhaseProfiles[phase]!.moaExpression;
}
