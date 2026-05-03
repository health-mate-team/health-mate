import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle_input.freezed.dart';

/// 사용자가 직접 입력하는 사이클 데이터.
/// 02_CYCLE_OS.json data_model.user_cycle_input 매핑.
/// [lastPeriodStartDate]가 null이면 사용자가 입력을 건너뛴 상태(general_lifestyle 모드).
@freezed
class CycleInput with _$CycleInput {
  const factory CycleInput({
    required DateTime? lastPeriodStartDate,
    @Default(28) int averageCycleLength,
    @Default(5) int averagePeriodLength,
    @Default(false) bool isIrregular,
    required DateTime updatedAt,
  }) = _CycleInput;

  factory CycleInput.empty(DateTime now) => CycleInput(
        lastPeriodStartDate: null,
        updatedAt: now,
      );
}
