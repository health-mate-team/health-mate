import 'package:drift/drift.dart';

@DataClassName('CycleInputRow')
class CycleInputs extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastPeriodStartDate => dateTime().nullable()();
  IntColumn get averageCycleLength =>
      integer().withDefault(const Constant(28))();
  IntColumn get averagePeriodLength =>
      integer().withDefault(const Constant(5))();
  BoolColumn get isIrregular => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
