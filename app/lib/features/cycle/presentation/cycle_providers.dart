import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/analytics/analytics_recorder.dart';
import 'package:health_mate/core/analytics/drift_analytics_recorder.dart';
import 'package:health_mate/core/analytics/user_id_hash.dart';
import 'package:health_mate/core/db/daos/analytics_event_dao.dart';
import 'package:health_mate/core/db/daos/cycle_input_dao.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/features/cycle/data/cycle_repository_impl.dart';
import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:health_mate/features/cycle/domain/services/phase_assignment_service.dart';
import 'package:health_mate/features/cycle/domain/services/recommendation_service.dart';

part 'cycle_providers.g.dart';

@Riverpod(keepAlive: true)
CycleInputDao cycleInputDao(Ref ref) {
  return CycleInputDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
AnalyticsEventDao analyticsEventDao(Ref ref) {
  return AnalyticsEventDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CycleRepository cycleRepository(Ref ref) {
  return CycleRepositoryImpl(ref.watch(cycleInputDaoProvider));
}

@Riverpod(keepAlive: true)
UserIdHashProvider userIdHashProvider(Ref ref) {
  return UserIdHashProvider();
}

@Riverpod(keepAlive: true)
AnalyticsRecorder analyticsRecorder(Ref ref) {
  final dao = ref.watch(analyticsEventDaoProvider);
  final hashProvider = ref.watch(userIdHashProviderProvider);
  return DriftAnalyticsRecorder(dao, hashProvider.get);
}

@Riverpod(keepAlive: true)
PhaseAssignmentService phaseAssignmentService(Ref ref) =>
    const PhaseAssignmentService();

@Riverpod(keepAlive: true)
RecommendationService recommendationService(Ref ref) =>
    const RecommendationService();

/// 사용자 사이클 입력의 단일 진실 공급원.
/// stream 으로 노출 — DB upsert 시 UI 자동 반영.
@Riverpod(keepAlive: true)
Stream<CycleInput?> cycleInputStream(Ref ref) {
  return ref.watch(cycleRepositoryProvider).watch();
}

/// 오늘 시각 + cycle_input 으로 파생되는 ComputedState.
/// cycle_input 이 비어 있으면 null.
/// 이 provider 가 갱신되면서 phase 가 바뀌면 cyclePhaseChanged 이벤트 송신.
@Riverpod(keepAlive: true)
class ComputedStateNotifier extends _$ComputedStateNotifier {
  CyclePhase? _lastPhase;

  @override
  ComputedState? build() {
    final inputAsync = ref.watch(cycleInputStreamProvider);
    final input = inputAsync.valueOrNull;
    if (input == null || input.lastPeriodStartDate == null) {
      return null;
    }
    final service = ref.watch(phaseAssignmentServiceProvider);
    final state = service.computeStateOrNull(today: DateTime.now(), input: input);
    if (state != null) {
      _maybeRecordPhaseChange(state);
    }
    return state;
  }

  void _maybeRecordPhaseChange(ComputedState state) {
    final prev = _lastPhase;
    if (prev != null && prev != state.phase) {
      final recorder = ref.read(analyticsRecorderProvider);
      recorder.record(
        AnalyticsEvent.cyclePhaseChanged(
          fromPhase: prev,
          toPhase: state.phase,
          dayOfCycle: state.dayOfCycle,
          ts: DateTime.now(),
        ),
      );
    }
    _lastPhase = state.phase;
  }
}

// 보조: CycleInput 타입 사용 추적용 (제거 예정)
// ignore: unused_element
CycleInput? _keepCycleInputImport(CycleInput? v) => v;
