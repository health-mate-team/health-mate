import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_mate/core/db/app_database.dart';
import 'package:health_mate/core/db/daos/cycle_input_dao.dart';
import 'package:health_mate/features/cycle/data/cycle_repository_impl.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/services/phase_assignment_service.dart';

void main() {
  late AppDatabase db;
  late CycleRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CycleRepositoryImpl(CycleInputDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('빈 DB → read() == null', () async {
    expect(await repo.read(), isNull);
  });

  test('save() 후 read() 가 동일한 input 반환', () async {
    final start = DateTime(2026, 4, 25);
    final updated = DateTime(2026, 5, 3);
    await repo.save(CycleInput(
      lastPeriodStartDate: start,
      averageCycleLength: 28,
      averagePeriodLength: 5,
      isIrregular: false,
      updatedAt: updated,
    ));

    final loaded = await repo.read();
    expect(loaded, isNotNull);
    expect(loaded!.lastPeriodStartDate, start);
    expect(loaded.averageCycleLength, 28);
    expect(loaded.isIrregular, isFalse);
  });

  test('save() 두 번 호출 시 upsert — row 1개만 유지', () async {
    final updated = DateTime(2026, 5, 3);
    await repo.save(CycleInput(
      lastPeriodStartDate: DateTime(2026, 4, 1),
      updatedAt: updated,
    ));
    await repo.save(CycleInput(
      lastPeriodStartDate: DateTime(2026, 5, 1),
      averageCycleLength: 30,
      updatedAt: updated,
    ));

    final all = await db.select(db.cycleInputs).get();
    expect(all.length, 1);
    expect(all.first.lastPeriodStartDate, DateTime(2026, 5, 1));
    expect(all.first.averageCycleLength, 30);
  });

  test('save → ComputedState 산출 (오늘=2026-05-03, 시작=2026-05-01) → menstrual', () async {
    const service = PhaseAssignmentService();
    await repo.save(CycleInput(
      lastPeriodStartDate: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 3),
    ));
    final input = await repo.read();
    final state = service.computeState(today: DateTime(2026, 5, 3), input: input!);
    expect(state.phase, CyclePhase.menstrual);
    expect(state.dayOfCycle, 3);
  });
}
