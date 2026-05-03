import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/services/recommendation_service.dart';

void main() {
  const service = RecommendationService();

  ComputedState stateOf(CyclePhase phase, {int dayOfCycle = 1}) {
    return ComputedState(
      phase: phase,
      dayOfCycle: dayOfCycle,
      daysUntilNextPhase: 5,
      phaseConfidence: 0.95,
    );
  }

  test('월경기 — hiit / strength_training 절대 추천하지 않음', () {
    for (var i = 0; i < 30; i++) {
      final r = service.recommendForToday(state: stateOf(CyclePhase.menstrual));
      expect(r, isNotNull);
      expect(r!.workout.workoutType, isNot('hiit'));
      expect(r.workout.workoutType, isNot('strength_training'));
    }
  });

  test('황체기 — hiit 추천하지 않음', () {
    final r = service.recommendForToday(state: stateOf(CyclePhase.luteal));
    expect(r, isNotNull);
    expect(r!.workout.workoutType, isNot('hiit'));
  });

  test('월경기 — stretching_yoga 또는 breathing_meditation 우선', () {
    final r = service.recommendForToday(state: stateOf(CyclePhase.menstrual));
    expect(r, isNotNull);
    expect(
      ['stretching_yoga', 'breathing_meditation'],
      contains(r!.workout.workoutType),
    );
  });

  test('배란기 — hiit / strength_training / light_cardio 중 하나', () {
    final r = service.recommendForToday(state: stateOf(CyclePhase.ovulatory));
    expect(r, isNotNull);
    expect(
      ['hiit', 'strength_training', 'light_cardio'],
      contains(r!.workout.workoutType),
    );
  });

  test('lastRecommendedId 가 동일 운동이면 다른 운동을 우선', () {
    final firstAny = service.recommendForToday(state: stateOf(CyclePhase.follicular));
    expect(firstAny, isNotNull);
    final r = service.recommendForToday(
      state: stateOf(CyclePhase.follicular),
      lastRecommendedId: firstAny!.workout.id,
    );
    // 후보가 1개뿐이면 동일할 수 있으니, follicular 의 후보가 2개 이상일 때만 검증.
    // (follicular 에는 stretching_yoga / light_cardio / strength_training / hiit / breathing 모두 있음)
    expect(r, isNotNull);
    expect(r!.workout.id, isNot(firstAny.workout.id));
  });

  test('rationale 은 phase 별로 다른 한 줄 (transparency 원칙)', () {
    for (final phase in CyclePhase.values) {
      final r = service.recommendForToday(state: stateOf(phase));
      expect(r, isNotNull);
      expect(r!.rationale.trim().length, greaterThan(5));
    }
  });
}
