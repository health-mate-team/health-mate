import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';

/// 02_CYCLE_OS.json computation_logic.phase_assignment_algorithm 의 Dart 구현.
///
/// 입력: 마지막 생리 시작일 + 사이클 길이 + 생리 길이 + 오늘.
/// 출력: 오늘이 며칠차이고, 어떤 phase 에 속하는지.
class PhaseAssignmentService {
  const PhaseAssignmentService();

  /// [today] 와 [input] 으로 [ComputedState] 산출.
  /// [CycleInput.lastPeriodStartDate] 가 null 이면 호출 전에 걸러야 함 — 여기서는 ArgumentError.
  ComputedState computeState({
    required DateTime today,
    required CycleInput input,
  }) {
    final start = input.lastPeriodStartDate;
    if (start == null) {
      throw ArgumentError(
          'lastPeriodStartDate is null. Call computeStateOrNull instead.');
    }
    if (today.isBefore(start)) {
      throw ArgumentError('today ($today) is before lastPeriodStartDate ($start).');
    }

    final cycleLen = input.averageCycleLength;
    final periodLen = input.averagePeriodLength;

    final daysSince = _diffInDays(start, today);
    final dayOfCycle = (daysSince % cycleLen) + 1;

    final phase = _assignPhase(
      dayOfCycle: dayOfCycle,
      cycleLen: cycleLen,
      periodLen: periodLen,
    );

    final lutealSub = phase == CyclePhase.luteal
        ? _assignLutealSubPhase(
            dayOfCycle: dayOfCycle,
            cycleLen: cycleLen,
            periodLen: periodLen,
          )
        : null;

    final daysUntilNext = _daysUntilNextPhase(
      dayOfCycle: dayOfCycle,
      currentPhase: phase,
      cycleLen: cycleLen,
      periodLen: periodLen,
    );

    final confidence = input.isIrregular ? 0.5 : 0.95;

    // 예상 다음 생리일 = lastPeriod + cycleLen.
    // 그 이후 7일이 지나도 사용자가 새 생리일을 입력하지 않은 상태면 alert.
    final expectedNext = start.add(Duration(days: cycleLen));
    final missedAlert = today.isAfter(expectedNext.add(const Duration(days: 7)));

    return ComputedState(
      phase: phase,
      dayOfCycle: dayOfCycle,
      daysUntilNextPhase: daysUntilNext,
      phaseConfidence: confidence,
      lutealSubPhase: lutealSub,
      missedPeriodAlert: missedAlert,
    );
  }

  /// [CycleInput.lastPeriodStartDate] 가 null 이면 null 반환.
  /// 일반 라이프스타일 모드에서 호출하기 위한 nullable 변형.
  ComputedState? computeStateOrNull({
    required DateTime today,
    required CycleInput input,
  }) {
    if (input.lastPeriodStartDate == null) return null;
    return computeState(today: today, input: input);
  }

  static int _diffInDays(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return bDate.difference(aDate).inDays;
  }

  /// 02_CYCLE_OS phase_assignment_algorithm:
  ///   menstrual: 1 ~ periodLen
  ///   follicular: periodLen+1 ~ (cycleLen/2 - 2)
  ///   ovulatory: (cycleLen/2 - 1) ~ (cycleLen/2 + 1)
  ///   luteal: (cycleLen/2 + 2) ~ cycleLen
  static CyclePhase _assignPhase({
    required int dayOfCycle,
    required int cycleLen,
    required int periodLen,
  }) {
    final mid = cycleLen ~/ 2;
    final ovulStart = mid - 1;
    final ovulEnd = mid + 1;
    final follicularEnd = mid - 2;

    if (dayOfCycle <= periodLen) return CyclePhase.menstrual;
    if (dayOfCycle <= follicularEnd) return CyclePhase.follicular;
    if (dayOfCycle <= ovulEnd && dayOfCycle >= ovulStart) {
      return CyclePhase.ovulatory;
    }
    if (dayOfCycle > ovulEnd) return CyclePhase.luteal;
    // periodLen+1 부터 follicularEnd 가 비정상적으로 좁은 경우 (짧은 사이클) follicular 로 fallback.
    return CyclePhase.follicular;
  }

  /// 황체기 시작일 기준 1-7일은 early, 8일 이상은 late.
  static LutealSubPhase _assignLutealSubPhase({
    required int dayOfCycle,
    required int cycleLen,
    required int periodLen,
  }) {
    final mid = cycleLen ~/ 2;
    final lutealStart = mid + 2;
    final dayWithinLuteal = dayOfCycle - lutealStart + 1;
    return dayWithinLuteal <= 7 ? LutealSubPhase.early : LutealSubPhase.late;
  }

  /// 현재 phase 의 다음 phase 가 시작될 때까지 남은 일수 (>= 1).
  static int _daysUntilNextPhase({
    required int dayOfCycle,
    required CyclePhase currentPhase,
    required int cycleLen,
    required int periodLen,
  }) {
    final mid = cycleLen ~/ 2;
    final follicularStart = periodLen + 1;
    final ovulStart = mid - 1;
    final lutealStart = mid + 2;

    switch (currentPhase) {
      case CyclePhase.menstrual:
        return follicularStart - dayOfCycle;
      case CyclePhase.follicular:
        return ovulStart - dayOfCycle;
      case CyclePhase.ovulatory:
        return lutealStart - dayOfCycle;
      case CyclePhase.luteal:
        // 다음 menstrual 시작 = cycleLen + 1 일차 = 새 사이클 day 1
        return (cycleLen - dayOfCycle) + 1;
    }
  }
}
