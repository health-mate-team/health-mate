import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';

part 'analytics_event.freezed.dart';

/// 04_SUCCESS_METRICS.json analytics_implementation.events_required_in_app 매핑.
/// 모든 이벤트는 device-local Drift 큐에 일단 적재. 서버 동기화는 별도 잡.
@freezed
sealed class AnalyticsEvent with _$AnalyticsEvent {
  /// KPI_03 D7/D30 리텐션
  const factory AnalyticsEvent.appOpen({
    required String sessionId,
    required DateTime ts,
  }) = AnalyticsAppOpen;

  /// KPI_02 운동 완료율
  const factory AnalyticsEvent.workoutCompleted({
    required String workoutId,
    required CyclePhase phase,
    required int durationTargetSeconds,
    required int durationActualSeconds,
    required DateTime ts,
  }) = AnalyticsWorkoutCompleted;

  /// 보조 — 거부 이유 분석
  const factory AnalyticsEvent.workoutSkipped({
    required String workoutId,
    required CyclePhase phase,
    String? skipReason,
    required DateTime ts,
  }) = AnalyticsWorkoutSkipped;

  /// 일일 참여 + OBS_02
  const factory AnalyticsEvent.morningRitualCompleted({
    required int moodScore,
    int? energyScore,
    CyclePhase? phase,
    int? dayOfCycle,
    required DateTime ts,
  }) = AnalyticsMorningRitualCompleted;

  /// 단계 전이 — 보조 분석
  const factory AnalyticsEvent.cyclePhaseChanged({
    required CyclePhase fromPhase,
    required CyclePhase toPhase,
    required int dayOfCycle,
    required DateTime ts,
  }) = AnalyticsCyclePhaseChanged;

  /// KPI_01, 04, 05
  const factory AnalyticsEvent.surveyResponse({
    required String surveyId,
    required String questionId,
    required String responseValue,
    required DateTime ts,
  }) = AnalyticsSurveyResponse;
}

extension AnalyticsEventName on AnalyticsEvent {
  String get name => switch (this) {
        AnalyticsAppOpen() => 'app_open',
        AnalyticsWorkoutCompleted() => 'workout_completed',
        AnalyticsWorkoutSkipped() => 'workout_skipped',
        AnalyticsMorningRitualCompleted() => 'morning_ritual_completed',
        AnalyticsCyclePhaseChanged() => 'cycle_phase_changed',
        AnalyticsSurveyResponse() => 'survey_response',
      };

  Map<String, Object?> get payload => switch (this) {
        AnalyticsAppOpen(:final sessionId) => {'session_id': sessionId},
        AnalyticsWorkoutCompleted(
          :final workoutId,
          :final phase,
          :final durationTargetSeconds,
          :final durationActualSeconds
        ) =>
          {
            'workout_id': workoutId,
            'phase': phase.id,
            'duration_target_seconds': durationTargetSeconds,
            'duration_actual_seconds': durationActualSeconds,
          },
        AnalyticsWorkoutSkipped(
          :final workoutId,
          :final phase,
          :final skipReason
        ) =>
          {
            'workout_id': workoutId,
            'phase': phase.id,
            'skip_reason': skipReason,
          },
        AnalyticsMorningRitualCompleted(
          :final moodScore,
          :final energyScore,
          :final phase,
          :final dayOfCycle
        ) =>
          {
            'mood_score': moodScore,
            'energy_score': energyScore,
            'phase': phase?.id,
            'day_of_cycle': dayOfCycle,
          },
        AnalyticsCyclePhaseChanged(
          :final fromPhase,
          :final toPhase,
          :final dayOfCycle
        ) =>
          {
            'from_phase': fromPhase.id,
            'to_phase': toPhase.id,
            'day_of_cycle': dayOfCycle,
          },
        AnalyticsSurveyResponse(
          :final surveyId,
          :final questionId,
          :final responseValue
        ) =>
          {
            'survey_id': surveyId,
            'question_id': questionId,
            'response_value': responseValue,
          },
      };
}
