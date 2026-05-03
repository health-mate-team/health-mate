import 'package:drift/drift.dart';

@DataClassName('AnalyticsEventRow')
class AnalyticsEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get userIdHash => text().withDefault(const Constant(''))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
