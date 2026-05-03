import 'package:health_mate/core/db/app_database.dart';
import 'package:health_mate/core/db/daos/cycle_input_dao.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/repositories/cycle_repository.dart';

class CycleRepositoryImpl implements CycleRepository {
  CycleRepositoryImpl(this._dao);

  final CycleInputDao _dao;

  @override
  Future<CycleInput?> read() async {
    final row = await _dao.readOne();
    return row == null ? null : _toEntity(row);
  }

  @override
  Stream<CycleInput?> watch() {
    return _dao.watchOne().map((row) => row == null ? null : _toEntity(row));
  }

  @override
  Future<void> save(CycleInput input) async {
    await _dao.upsert(
      lastPeriodStartDate: input.lastPeriodStartDate,
      averageCycleLength: input.averageCycleLength,
      averagePeriodLength: input.averagePeriodLength,
      isIrregular: input.isIrregular,
      updatedAt: input.updatedAt,
    );
  }

  CycleInput _toEntity(CycleInputRow row) {
    return CycleInput(
      lastPeriodStartDate: row.lastPeriodStartDate,
      averageCycleLength: row.averageCycleLength,
      averagePeriodLength: row.averagePeriodLength,
      isIrregular: row.isIrregular,
      updatedAt: row.updatedAt,
    );
  }
}
