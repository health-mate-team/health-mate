import 'package:drift/drift.dart';

import 'package:health_mate/core/db/app_database.dart';
import 'package:health_mate/core/db/tables/cycle_input_table.dart';

part 'cycle_input_dao.g.dart';

@DriftAccessor(tables: [CycleInputs])
class CycleInputDao extends DatabaseAccessor<AppDatabase>
    with _$CycleInputDaoMixin {
  CycleInputDao(super.db);

  /// 싱글턴 row(id=1) 조회. 미존재 시 null.
  Future<CycleInputRow?> readOne() async {
    return (select(cycleInputs)..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  /// 변경 스트림.
  Stream<CycleInputRow?> watchOne() {
    return (select(cycleInputs)..where((t) => t.id.equals(1)))
        .watchSingleOrNull();
  }

  Future<void> upsert({
    required DateTime? lastPeriodStartDate,
    required int averageCycleLength,
    required int averagePeriodLength,
    required bool isIrregular,
    required DateTime updatedAt,
  }) async {
    await into(cycleInputs).insertOnConflictUpdate(
      CycleInputsCompanion.insert(
        id: const Value(1),
        lastPeriodStartDate: Value(lastPeriodStartDate),
        averageCycleLength: Value(averageCycleLength),
        averagePeriodLength: Value(averagePeriodLength),
        isIrregular: Value(isIrregular),
        updatedAt: updatedAt,
      ),
    );
  }
}
