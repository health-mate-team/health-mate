import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/services/phase_assignment_service.dart';

void main() {
  const service = PhaseAssignmentService();

  CycleInput inputAt(DateTime start, {int cycle = 28, int period = 5, bool irregular = false}) {
    return CycleInput(
      lastPeriodStartDate: start,
      averageCycleLength: cycle,
      averagePeriodLength: period,
      isIrregular: irregular,
      updatedAt: start,
    );
  }

  group('28일 사이클, 5일 생리 — phase 매핑', () {
    final start = DateTime(2026, 5, 1);

    void check(int dayOfCycle, CyclePhase expected) {
      test('day $dayOfCycle → ${expected.id}', () {
        final today = start.add(Duration(days: dayOfCycle - 1));
        final s = service.computeState(today: today, input: inputAt(start));
        expect(s.dayOfCycle, dayOfCycle);
        expect(s.phase, expected);
      });
    }

    check(1, CyclePhase.menstrual);
    check(5, CyclePhase.menstrual);
    check(6, CyclePhase.follicular);
    check(12, CyclePhase.follicular);
    check(13, CyclePhase.ovulatory);
    check(14, CyclePhase.ovulatory);
    check(15, CyclePhase.ovulatory);
    check(16, CyclePhase.luteal);
    check(22, CyclePhase.luteal);
    check(28, CyclePhase.luteal);
  });

  test('day 30 → 다음 사이클 day 3 (28일 사이클 모듈로)', () {
    final start = DateTime(2026, 5, 1);
    final today = start.add(const Duration(days: 29));
    final s = service.computeState(today: today, input: inputAt(start));
    expect(s.dayOfCycle, 2);
    expect(s.phase, CyclePhase.menstrual);
  });

  test('황체기 sub_phase — early/late 분기', () {
    final start = DateTime(2026, 5, 1);
    final earlyDay = start.add(const Duration(days: 18)); // day 19
    final lateDay = start.add(const Duration(days: 25)); // day 26

    final earlyState = service.computeState(today: earlyDay, input: inputAt(start));
    expect(earlyState.phase, CyclePhase.luteal);
    expect(earlyState.lutealSubPhase, LutealSubPhase.early);

    final lateState = service.computeState(today: lateDay, input: inputAt(start));
    expect(lateState.phase, CyclePhase.luteal);
    expect(lateState.lutealSubPhase, LutealSubPhase.late);
  });

  test('isIrregular=true → confidence ≤ 0.6', () {
    final start = DateTime(2026, 5, 1);
    final s = service.computeState(
      today: start.add(const Duration(days: 5)),
      input: inputAt(start, irregular: true),
    );
    expect(s.phaseConfidence, lessThanOrEqualTo(0.6));
  });

  test('정상 입력 → confidence ≥ 0.9', () {
    final start = DateTime(2026, 5, 1);
    final s = service.computeState(
      today: start.add(const Duration(days: 5)),
      input: inputAt(start),
    );
    expect(s.phaseConfidence, greaterThanOrEqualTo(0.9));
  });

  test('미래 날짜 입력 → ArgumentError', () {
    final start = DateTime(2026, 5, 10);
    final today = DateTime(2026, 5, 1);
    expect(
      () => service.computeState(today: today, input: inputAt(start)),
      throwsArgumentError,
    );
  });

  test('null lastPeriodStartDate — computeStateOrNull 은 null 반환', () {
    final s = service.computeStateOrNull(
      today: DateTime(2026, 5, 1),
      input: CycleInput.empty(DateTime(2026, 5, 1)),
    );
    expect(s, isNull);
  });

  test('missedPeriodAlert — 마지막 생리일 + 35일 초과 시 true', () {
    final start = DateTime(2026, 5, 1);
    // 28일 사이클이라 다음 생리 예상일 = 5/29. +7일 = 6/5. 그 이후 = 6/6.
    final today = DateTime(2026, 6, 6);
    final s = service.computeState(today: today, input: inputAt(start));
    expect(s.missedPeriodAlert, isTrue);
  });

  test('21일 단주기 — 경계 동작', () {
    final start = DateTime(2026, 5, 1);
    final today = start.add(const Duration(days: 9)); // day 10
    final s = service.computeState(
      today: today,
      input: inputAt(start, cycle: 21, period: 4),
    );
    // mid = 10, ovulStart = 9, ovulEnd = 11 → day 10 = ovulatory
    expect(s.phase, CyclePhase.ovulatory);
  });

  test('35일 장주기 — 경계 동작', () {
    final start = DateTime(2026, 5, 1);
    final today = start.add(const Duration(days: 16)); // day 17
    final s = service.computeState(
      today: today,
      input: inputAt(start, cycle: 35, period: 5),
    );
    // mid = 17, ovulStart = 16, ovulEnd = 18 → day 17 = ovulatory
    expect(s.phase, CyclePhase.ovulatory);
  });
}
