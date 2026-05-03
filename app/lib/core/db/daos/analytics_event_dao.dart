import 'package:drift/drift.dart';

import 'package:health_mate/core/db/app_database.dart';
import 'package:health_mate/core/db/tables/analytics_event_table.dart';

part 'analytics_event_dao.g.dart';

@DriftAccessor(tables: [AnalyticsEvents])
class AnalyticsEventDao extends DatabaseAccessor<AppDatabase>
    with _$AnalyticsEventDaoMixin {
  AnalyticsEventDao(super.db);

  Future<int> insertEvent({
    required String name,
    required String payloadJson,
    required DateTime timestamp,
    required String userIdHash,
  }) {
    return into(analyticsEvents).insert(
      AnalyticsEventsCompanion.insert(
        name: name,
        payloadJson: Value(payloadJson),
        timestamp: timestamp,
        userIdHash: Value(userIdHash),
      ),
    );
  }

  Stream<List<AnalyticsEventRow>> watchUnsynced() {
    return (select(analyticsEvents)..where((t) => t.synced.equals(false)))
        .watch();
  }

  Future<List<AnalyticsEventRow>> readAll() {
    return select(analyticsEvents).get();
  }
}
