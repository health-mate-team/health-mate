import 'package:freezed_annotation/freezed_annotation.dart';

import 'cycle_phase.dart';

part 'computed_state.freezed.dart';

/// CycleInput + 오늘 날짜로 계산된 파생 상태.
/// 02_CYCLE_OS.json data_model.computed_state 매핑.
@freezed
class ComputedState with _$ComputedState {
  const factory ComputedState({
    required CyclePhase phase,
    required int dayOfCycle,
    required int daysUntilNextPhase,
    required double phaseConfidence,
    LutealSubPhase? lutealSubPhase,
    @Default(false) bool missedPeriodAlert,
  }) = _ComputedState;
}
