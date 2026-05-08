// Backend 실제 응답 fixture ↔ Flutter DTO fromJson 정합성 contract test.
// Stage 2-A: API_SPEC.md 명세 적합성 검증의 Flutter 측 회귀 보호.
import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/core/constants/cycle_phase.dart';
import 'package:health_mate/features/auth/data/dto/auth_dto.dart';
import 'package:health_mate/features/cycle/data/dto/cycle_dto.dart';
import 'package:health_mate/features/evening_ritual/data/dto/evening_dto.dart';
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
}
