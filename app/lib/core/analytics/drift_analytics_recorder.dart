import 'dart:convert';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/analytics/analytics_recorder.dart';
import 'package:health_mate/core/db/daos/analytics_event_dao.dart';

class DriftAnalyticsRecorder implements AnalyticsRecorder {
  DriftAnalyticsRecorder(this._dao, this._userIdHashProvider);

  final AnalyticsEventDao _dao;
  final Future<String> Function() _userIdHashProvider;

  @override
  Future<void> record(AnalyticsEvent event) async {
    final userIdHash = await _userIdHashProvider();
    await _dao.insertEvent(
      name: event.name,
      payloadJson: jsonEncode(event.payload),
      timestamp: event.ts,
      userIdHash: userIdHash,
    );
  }
}
