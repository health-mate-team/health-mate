import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/analytics_event_table.dart';
import 'tables/cycle_input_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CycleInputs, AnalyticsEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'health_mate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
