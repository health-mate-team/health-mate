// Backend 실제 응답 fixture ↔ Flutter DTO fromJson 정합성 contract test.
// Stage 2-A: API_SPEC.md 명세 적합성 검증의 Flutter 측 회귀 보호.
import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/core/constants/cycle_phase.dart';
import 'package:health_mate/features/action/data/dto/action_dto.dart';
import 'package:health_mate/features/auth/data/dto/auth_dto.dart';
import 'package:health_mate/features/nutrition/data/dto/nutrition_dto.dart';
import 'package:health_mate/features/workout/data/dto/workout_dto.dart';
import 'package:health_mate/features/cycle/data/dto/cycle_dto.dart';
import 'package:health_mate/features/evening_ritual/data/dto/evening_dto.dart';
import 'package:health_mate/features/evolution/data/dto/rewards_dto.dart';
import 'package:health_mate/features/home/data/dto/stats_dto.dart';
import 'package:health_mate/features/morning_ritual/data/dto/ritual_dto.dart';
import 'package:health_mate/features/onboarding/data/dto/onboarding_dto.dart';
import 'package:health_mate/features/users/data/dto/user_profile_dto.dart';

void main() {
  group('P0 Auth + Users 응답 contract', () {
    test('register 응답 → access_token 추출', () {
      final res = RegisterResponse.fromJson({
        'access_token': 'eyJ.test.token',
      });
      expect(res.accessToken, 'eyJ.test.token');
    });

    test('login 응답 → access_token + is_onboarding_completed', () {
      final res = LoginResponse.fromJson({
        'access_token': 'eyJ.test.token',
        'is_onboarding_completed': false,
      });
      expect(res.accessToken, 'eyJ.test.token');
      expect(res.isOnboardingCompleted, false);
    });

    test('users/me 응답 → UserProfileDto (created_at은 의도적 무시)', () {
      final dto = UserProfileDto.fromJson({
        'id': '11111111-2222-3333-4444-555555555555',
        'email': 'user@test.app',
        'name': '검증',
        'is_onboarding_completed': true,
        'created_at': '2026-05-08T00:00:00.000Z',
      });
      expect(dto.id, '11111111-2222-3333-4444-555555555555');
      expect(dto.name, '검증');
      expect(dto.isOnboardingCompleted, true);
    });
  });

  group('P0 Onboarding 응답 contract', () {
    test('onboarding/complete → initial_stats + current_phase', () {
      final res = OnboardingCompleteResponse.fromJson({
        'initial_stats': {
          'energy_score': 50,
          'hydration_score': 50,
          'mood_score': 50,
          'rest_score': 50,
          'water_cups': 0,
          'total_xp': 0,
          'level': 1,
          'streak': 0,
        },
        'current_phase': 'follicular',
      });
      expect(res.currentPhase, 'follicular');
      expect(res.initialStats.energyScore, 50);
      expect(res.initialStats.hydrationScore, 50);
      expect(res.initialStats.moodScore, 50);
      expect(res.initialStats.restScore, 50);
      expect(res.initialStats.totalXp, 0);
      expect(res.initialStats.level, 1);
      expect(res.initialStats.streak, 0);
    });
  });

  group('P1 Cycle 응답 contract', () {
    test('cycle/current → CycleCurrentDto (8 fields, phase enum 매핑)', () {
      final dto = CycleCurrentDto.fromJson({
        'current_phase': 'follicular',
        'day_of_cycle': 10,
        'days_until_next_period': 18,
        'next_period_date': '2026-05-26',
        'average_cycle_length': 28,
        'average_period_length': 5,
        'is_irregular': false,
        'goal_type': 'energy',
      });
      expect(dto.currentPhase, CyclePhase.follicular);
      expect(dto.dayOfCycle, 10);
      expect(dto.daysUntilNextPeriod, 18);
      expect(dto.nextPeriodDate, '2026-05-26');
      expect(dto.averageCycleLength, 28);
      expect(dto.averagePeriodLength, 5);
      expect(dto.isIrregular, false);
      expect(dto.goalType, 'energy');
    });
  });

  group('P1 Rituals 응답 contract', () {
    test('rituals/today (초기) → null mood/promise + xp_earned_today=0', () {
      final dto = RitualTodayDto.fromJson({
        'date': '2026-05-08',
        'morning_mood': null,
        'morning_promise': null,
        'evening_completed': false,
        'promise_kept': false,
        'xp_earned_today': 0,
      });
      expect(dto.morningMood, isNull);
      expect(dto.morningPromise, isNull);
      expect(dto.eveningCompleted, false);
      expect(dto.promiseKept, false);
      expect(dto.xpEarned, 0);
    });

    test('rituals/today (완료) → mood=4, evening_completed, xp=70', () {
      final dto = RitualTodayDto.fromJson({
        'date': '2026-05-08',
        'morning_mood': 4,
        'morning_promise': '오늘 물 8잔 마시기',
        'evening_completed': true,
        'promise_kept': true,
        'xp_earned_today': 70,
      });
      expect(dto.morningMood, 4);
      expect(dto.morningPromise, '오늘 물 8잔 마시기');
      expect(dto.eveningCompleted, true);
      expect(dto.promiseKept, true);
      expect(dto.xpEarned, 70);
    });

    test('morning/mood 응답 → recommended_promise는 string', () {
      final res = MorningMoodResponse.fromJson({
        'mood': 4,
        'xp_earned': 10,
        'recommended_promise': '건강한 식사 계획 세우기',
        'total_xp': 10,
      });
      expect(res.mood, 4);
      expect(res.xpEarned, 10);
      expect(res.recommendedPromise, '건강한 식사 계획 세우기');
      expect(res.totalXp, 10);
    });

    test('morning/promise 응답 → {promise, saved_at}', () {
      final res = MorningPromiseResponse.fromJson({
        'promise': '오늘 물 8잔 마시기',
        'saved_at': '2026-05-08T07:15:00.000Z',
      });
      expect(res.promise, '오늘 물 8잔 마시기');
      expect(res.savedAt, '2026-05-08T07:15:00.000Z');
    });

    test('evening 응답 (약속 지킴) → xp_earned=60, total_xp=70', () {
      final res = EveningRitualResponse.fromJson({
        'promise_kept': true,
        'xp_earned': 60,
        'total_xp': 70,
        'streak': 1,
        'level': 1,
      });
      expect(res.promiseKept, true);
      expect(res.xpEarned, 60);
      expect(res.totalXp, 70);
      expect(res.streak, 1);
      expect(res.level, 1);
    });

    test('evening 응답 (약속 미달성) → xp_earned=10', () {
      final res = EveningRitualResponse.fromJson({
        'promise_kept': false,
        'xp_earned': 10,
        'total_xp': 20,
        'streak': 0,
        'level': 1,
      });
      expect(res.xpEarned, 10);
      expect(res.streak, 0);
    });
  });

  group('P1 Stats 응답 contract (nested → flat 변환)', () {
    test('stats/today → 평탄 DTO 매핑 (10 fields)', () {
      final dto = StatsTodayDto.fromJson({
        'user': {
          'id': '11111111-aaaa-bbbb-cccc-222222222222',
          'name': '검증',
          'email': 'user@test.app',
        },
        'stats': {
          'energy_score': 75,
          'hydration_score': 62,
          'mood_score': 70,
          'rest_score': 80,
          'water_cups': 4,
          'total_xp': 240,
          'level': 3,
          'streak': 7,
        },
        'cycle': {
          'current_phase': 'follicular',
          'day_of_cycle': 10,
          'goal_type': 'energy',
        },
        'today_ritual': {
          'morning_mood': 4,
          'morning_promise': '10분 산책하기',
          'evening_completed': false,
          'promise_kept': false,
          'xp_earned_today': 10,
        },
      });
      expect(dto.energy, 75);
      expect(dto.hydration, 62);
      expect(dto.rest, 80);
      expect(dto.totalXp, 240);
      expect(dto.level, 3);
      expect(dto.streak, 7);
      expect(dto.currentPhase, 'follicular');
      expect(dto.dayOfCycle, 10);
      expect(dto.userName, '검증');
      expect(dto.xpToday, 10);
    });

    test('stats/today → cycle/today_ritual null 시 default fallback', () {
      final dto = StatsTodayDto.fromJson({
        'user': {'id': 'x', 'name': '기본', 'email': 'x@x.com'},
        'stats': null,
        'cycle': null,
        'today_ritual': null,
      });
      expect(dto.energy, 50);
      expect(dto.hydration, 50);
      expect(dto.rest, 50);
      expect(dto.level, 1);
      expect(dto.streak, 0);
      expect(dto.currentPhase, 'follicular');
      expect(dto.dayOfCycle, 1);
      expect(dto.xpToday, 0);
      expect(dto.userName, '기본');
    });
  });

  group('CyclePhase enum 매핑', () {
    test('파싱: follicular/luteal/menstrual/ovulation', () {
      expect(CyclePhase.parse('follicular'), CyclePhase.follicular);
      expect(CyclePhase.parse('luteal'), CyclePhase.luteal);
      expect(CyclePhase.parse('menstrual'), CyclePhase.menstrual);
      expect(CyclePhase.parse('ovulation'), CyclePhase.ovulation);
    });

    test('파싱: 빈 문자열 / unknown → fallback (follicular)', () {
      expect(CyclePhase.parse(''), CyclePhase.follicular);
      expect(CyclePhase.parse('unknown'), CyclePhase.follicular);
    });
  });

  group('P2 Actions contract', () {
    test('POST /actions/water 응답 → WaterActionResponse 매핑', () {
      final dto = WaterActionResponse.fromJson({
        'today_cups_total': 4,
        'daily_target_cups': 8,
        'hydration_stat': 62,
        'xp_earned': 5,
        'moa_reaction': '물 마셨군요! 💧',
      });
      expect(dto.todayCupsTotal, 4);
      expect(dto.dailyTargetCups, 8);
      expect(dto.hydrationStat, 62);
      expect(dto.xpEarned, 5);
      expect(dto.moaReaction, '물 마셨군요! 💧');
    });

    test('GET /actions/water/today 응답 → WaterTodayDto 매핑', () {
      final dto = WaterTodayDto.fromJson({
        'date': '2026-05-08',
        'cups_total': 3,
        'daily_target_cups': 8,
      });
      expect(dto.cupsTotal, 3);
      expect(dto.dailyTargetCups, 8);
    });

    test('POST /actions/walk/start 응답 → WalkStartResponse 매핑', () {
      final dto = WalkStartResponse.fromJson({
        'walk_session_id': 'uuid-1234',
        'started_at': '2026-05-08T18:30:00.000Z',
      });
      expect(dto.walkSessionId, 'uuid-1234');
    });

    test('POST /actions/walk/complete 응답 → WalkCompleteResponse 매핑', () {
      final dto = WalkCompleteResponse.fromJson({
        'duration_minutes': 15,
        'distance_km': 1.26,
        'energy_stat_delta': 8,
        'xp_earned': 30,
        'moa_reaction': '15분 걸었어요! 🐾',
      });
      expect(dto.durationMinutes, 15);
      expect(dto.xpEarned, 30);
      expect(dto.energyStatDelta, 8);
    });
  });

  group('P2 Rewards contract', () {
    test('GET /rewards/summary 응답 → RewardsSummaryDto 매핑', () {
      final dto = RewardsSummaryDto.fromJson({
        'level': 5,
        'current_xp': 320,
        'xp_to_next_level': 380,
        'total_xp_earned': 320,
        'streak': {'current': 7, 'longest': 12},
        'evolution_stage': {
          'stage': 2,
          'name': '성장 모아',
          'color_token': 'OwnerColors.accentMint',
          'next_stage_xp_threshold': 300,
          'xp_to_next': 380,
        },
        'badges': [
          {
            'code': 'first_ritual',
            'name': '첫 의식 완료',
            'description': '처음으로 아침 의식을 완료했어요',
            'earned_at': '2026-05-01T07:00:00.000Z',
          }
        ],
        'xp_log': [
          {
            'delta': 10,
            'reason': 'morning_mood',
            'label': '아침 기분 체크 +10 XP',
            'created_at': '2026-05-08T07:00:00.000Z',
          }
        ],
      });
      expect(dto.level, 5);
      expect(dto.currentXp, 320);
      expect(dto.streak.current, 7);
      expect(dto.streak.longest, 12);
      expect(dto.evolutionStage.stage, 2);
      expect(dto.evolutionStage.name, '성장 모아');
      expect(dto.badges.length, 1);
      expect(dto.badges.first.code, 'first_ritual');
      expect(dto.xpLog.length, 1);
      expect(dto.xpLog.first.delta, 10);
      expect(dto.xpLog.first.reason, 'morning_mood');
    });

    test('badges/xpLog 빈 배열 → fallback', () {
      final dto = RewardsSummaryDto.fromJson({
        'level': 1,
        'current_xp': 0,
        'streak': {'current': 0, 'longest': 0},
        'evolution_stage': {
          'stage': 1,
          'name': '새싹 모아',
          'color_token': '',
          'next_stage_xp_threshold': 0,
          'xp_to_next': 300,
        },
      });
      expect(dto.badges, isEmpty);
      expect(dto.xpLog, isEmpty);
      expect(dto.level, 1);
    });
  });

  group('P3 Workout contract', () {
    test('GET /workout/recommend → WorkoutRecommendDto 매핑', () {
      final dto = WorkoutRecommendDto.fromJson({
        'recommendation': {
          'workout_id': 'follicular_strength_01',
          'title': '난포기 5분 근력 빌드업',
          'type': 'strength_training',
          'intensity': 'moderate',
          'duration_minutes': 5,
          'phase_fit': 'follicular',
          'thumbnail_url': null,
          'video_url': null,
          'is_video_ready': false,
          'fallback_type': 'svg_animation',
        },
        'based_on': {'phase': 'follicular', 'mood': 'okay', 'goal': 'energy'},
        'alternative': {
          'workout_id': 'follicular_cardio_01',
          'title': '난포기 빠르게 걷기 5분',
          'type': 'light_cardio',
          'intensity': 'low',
          'duration_minutes': 5,
          'phase_fit': 'follicular',
          'thumbnail_url': null,
          'video_url': null,
          'is_video_ready': false,
          'fallback_type': 'svg_animation',
        },
      });
      expect(dto.recommendation.workoutId, 'follicular_strength_01');
      expect(dto.recommendation.type, 'strength_training');
      expect(dto.recommendation.durationMinutes, 5);
      expect(dto.alternative?.workoutId, 'follicular_cardio_01');
    });

    test('GET /workout/recommend → alternative null 허용', () {
      final dto = WorkoutRecommendDto.fromJson({
        'recommendation': {
          'workout_id': 'menstrual_stretching_01',
          'title': '월경기 따뜻한 5분 요가',
          'type': 'stretching',
          'intensity': 'low',
          'duration_minutes': 5,
          'phase_fit': 'menstrual',
          'thumbnail_url': null,
          'video_url': null,
          'is_video_ready': false,
          'fallback_type': 'svg_animation',
        },
        'based_on': {'phase': 'menstrual', 'mood': 'okay', 'goal': 'rest'},
        'alternative': null,
      });
      expect(dto.recommendation.phaseFit, 'menstrual');
      expect(dto.alternative, isNull);
    });

    test('POST /workout/complete 응답 → WorkoutCompleteResponse 매핑', () {
      final dto = WorkoutCompleteResponse.fromJson({
        'xp_earned': 30,
        'energy_stat_delta': 10,
        'streak_updated': {'current_streak': 8},
        'level_up': null,
      });
      expect(dto.xpEarned, 30);
      expect(dto.energyStatDelta, 10);
    });

    test('POST /workout/skip 응답 → WorkoutSkipResponse 매핑', () {
      final dto = WorkoutSkipResponse.fromJson({
        'skipped': true,
        'workout_id': 'follicular_strength_01',
      });
      expect(dto.skipped, true);
      expect(dto.workoutId, 'follicular_strength_01');
    });
  });

  group('P3 Nutrition contract', () {
    test('GET /nutrition/search 응답 → NutritionSearchDto 매핑', () {
      final dto = NutritionSearchDto.fromJson({
        'query': '닭가슴살',
        'results': [
          {
            'food_id': 'mfds_001234',
            'name': '닭가슴살 (삶은 것)',
            'calories_per_100g': 109,
            'protein_g': 23.1,
            'carbs_g': 0,
            'fat_g': 1.2,
            'source': '식약처',
          }
        ],
      });
      expect(dto.query, '닭가슴살');
      expect(dto.results.length, 1);
      expect(dto.results.first.foodId, 'mfds_001234');
      expect(dto.results.first.caloriesPer100g, 109);
    });

    test('POST /nutrition/logs 응답 → NutritionLogResponse 매핑', () {
      final dto = NutritionLogResponse.fromJson({
        'meal_log_id': 'uuid-meal-001',
        'total_calories': 164,
        'xp_earned': 10,
      });
      expect(dto.mealLogId, 'uuid-meal-001');
      expect(dto.totalCalories, 164);
      expect(dto.xpEarned, 10);
    });

    test('GET /nutrition/today → NutritionTodayDto 매핑', () {
      final dto = NutritionTodayDto.fromJson({
        'date': '2026-05-08',
        'total_calories': 1240,
        'daily_target_calories': 1800,
        'phase_recommendation': {
          'phase': 'follicular',
          'focus_nutrients': ['단백질', '복합 탄수화물'],
          'message': '난포기에는 단백질 섭취를 늘려 근육 회복을 도와요',
        },
        'meals': [
          {'meal_type': 'lunch', 'calories': 520, 'foods_count': 3}
        ],
      });
      expect(dto.totalCalories, 1240);
      expect(dto.dailyTargetCalories, 1800);
      expect(dto.phaseRecommendation.phase, 'follicular');
      expect(dto.phaseRecommendation.focusNutrients, ['단백질', '복합 탄수화물']);
      expect(dto.meals.length, 1);
      expect(dto.meals.first.mealType, 'lunch');
    });

    test('GET /nutrition/today → phase_recommendation null fallback', () {
      final dto = NutritionTodayDto.fromJson({
        'date': '2026-05-08',
        'total_calories': 0,
        'daily_target_calories': 1800,
        'phase_recommendation': null,
        'meals': [],
      });
      expect(dto.phaseRecommendation.focusNutrients, isEmpty);
      expect(dto.meals, isEmpty);
    });
  });
}
