import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/entities/workout_template.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/features/cycle/static_data/workout_matrix.dart';

/// "왜 이 추천?" 한 줄 설명까지 같이 반환.
/// 02_CYCLE_OS.json ux_principles.transparency 요건.
class RecommendationResult {
  const RecommendationResult({
    required this.workout,
    required this.rationale,
  });

  final WorkoutTemplate workout;
  final String rationale;
}

/// 02_CYCLE_OS.json computation_logic.recommendation_engine_priority 의 Dart 구현.
///
/// 우선순위:
///  1. 현 phase 의 workoutTypesPriority 가중치 (앞쪽일수록 가산)
///  2. workoutTypesAvoid 는 제외
///  3. 최근 추천한 것과 다름 (다양성)
///  4. 사용자가 과거 완료한 운동인가 (재추천 가산)
///  5. 시간대 적합성 — MVP 범위 밖
class RecommendationService {
  const RecommendationService();

  RecommendationResult? recommendForToday({
    required ComputedState state,
    String? userGoalId,
    List<String> recentlyCompletedIds = const [],
    String? lastRecommendedId,
  }) {
    final profile = kPhaseProfiles[state.phase]!;
    final candidates = workoutsForPhase(state.phase)
        .where((w) => !profile.workoutTypesAvoid.contains(w.workoutType))
        .toList();

    if (candidates.isEmpty) return null;

    int score(WorkoutTemplate w) {
      int s = 0;
      // 1. priority 리스트 가중치 (앞쪽 = 높은 점수)
      final priorityIdx = profile.workoutTypesPriority.indexOf(w.workoutType);
      if (priorityIdx >= 0) {
        s += (profile.workoutTypesPriority.length - priorityIdx) * 10;
      }
      // priority enum (core/main 우선)
      switch (w.priority) {
        case WorkoutPriority.core:
          s += 8;
          break;
        case WorkoutPriority.main:
          s += 6;
          break;
        case WorkoutPriority.warmup:
        case WorkoutPriority.cooldown:
          s += 3;
          break;
        case WorkoutPriority.intro:
          s += 4;
          break;
        case WorkoutPriority.soft:
          s += 2;
          break;
        case WorkoutPriority.short:
          s += 1;
          break;
        case WorkoutPriority.skip:
          s -= 100;
          break;
      }
      // 3. 최근 추천과 다르면 가산
      if (lastRecommendedId != null && lastRecommendedId != w.id) s += 2;
      // 4. 과거 완료 가산
      if (recentlyCompletedIds.contains(w.id)) s += 1;
      // 5. userGoal 매핑 가산 — onboarding_goal 결과를 추천에 반영.
      final goalBoosts = _goalBoosts[userGoalId];
      if (goalBoosts != null) {
        s += goalBoosts[w.workoutType] ?? 0;
      }
      return s;
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    final picked = candidates.first;
    return RecommendationResult(
      workout: picked,
      rationale: _rationaleFor(state.phase, picked, userGoalId: userGoalId),
    );
  }

  /// onboarding_goal 의 4가지 목표 id → 운동 타입별 가산점.
  /// 단계 priority(10단위) 보다 작은 4단위로 두어 phase 우선순위를 깨지 않음.
  static const Map<String, Map<String, int>> _goalBoosts = {
    'energy': {
      'hiit': 4,
      'strength_training': 3,
      'light_cardio': 2,
    },
    'hydration': {
      // 직접 매칭 운동은 없음 — 짧고 부담 없는 활동 가산.
      'breathing_meditation': 2,
      'light_cardio': 1,
    },
    'rest': {
      'breathing_meditation': 4,
      'stretching_yoga': 3,
    },
    'shape': {
      'strength_training': 4,
      'hiit': 3,
      'light_cardio': 2,
    },
  };

  static String _rationaleFor(CyclePhase phase, WorkoutTemplate w, {String? userGoalId}) {
    final phaseLine = switch (phase) {
      CyclePhase.menstrual => '월경기라 격한 운동은 피하고 부드러운 동작 위주로 골랐어요',
      CyclePhase.follicular => '난포기는 에너지가 올라오는 시기 — 새 도전을 추천해요',
      CyclePhase.ovulatory => '배란기 컨디션 최고 — 한계까지 시도해볼 수 있어요',
      CyclePhase.luteal => '황체기라 격한 운동은 피해요. 천천히 가도 괜찮아요',
    };
    final goalLine = _goalSuffix(userGoalId, w.workoutType);
    if (goalLine == null) return phaseLine;
    return '$phaseLine · $goalLine';
  }

  static String? _goalSuffix(String? goalId, String workoutType) {
    if (goalId == null) return null;
    final boost = _goalBoosts[goalId]?[workoutType];
    if (boost == null || boost <= 0) return null;
    return switch (goalId) {
      'energy' => '활기 목표에 잘 맞아요',
      'hydration' => '습관 만들기에 좋아요',
      'rest' => '잘 쉬기 목표에 어울려요',
      'shape' => '몸 만들기 목표에 도움돼요',
      _ => null,
    };
  }
}
