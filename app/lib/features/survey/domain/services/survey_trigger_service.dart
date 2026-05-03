import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_mate/features/survey/domain/entities/survey.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';

/// 04_SUCCESS_METRICS.json measurement_window 기준 설문 트리거 판정.
///
/// 규칙:
///  - 베타 등록일(D0) 은 첫 onboarding 완료 시 1회 기록.
///  - 각 설문은 `targetDay ± windowDays` 안에서만 활성.
///  - 이미 완료한 설문은 재트리거 안 함.
class SurveyTriggerService {
  const SurveyTriggerService({
    DateTime Function() now = _defaultNow,
    int windowDays = 1,
  })  : _now = now,
        _windowDays = windowDays;

  final DateTime Function() _now;
  final int _windowDays;

  static DateTime _defaultNow() => DateTime.now();

  /// 베타 등록일 기록 (없으면 처음 1회만).
  Future<void> ensureBetaStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(OwnerPrefsKeys.betaStartDate);
    if (existing != null && existing.isNotEmpty) return;
    await prefs.setString(
      OwnerPrefsKeys.betaStartDate,
      _todayIsoDate(),
    );
  }

  /// 지금 진입하면 보여줄 설문이 있으면 반환, 없으면 null.
  /// 우선순위: D28 > D14 > D0 (가장 늦은 게이트가 우선).
  Future<SurveyId?> nextDueSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(OwnerPrefsKeys.betaStartDate);
    if (startStr == null || startStr.isEmpty) return null;
    final start = DateTime.tryParse(startStr);
    if (start == null) return null;

    final daysSinceStart = _diffInDays(start, _now());

    // 늦은 게이트부터 검사 — 같은 날 두 설문이 동시에 열리진 않지만 안전하게 우선순위.
    for (final id in [SurveyId.finalD28, SurveyId.pulseD14, SurveyId.baselineD0]) {
      if (await _isCompleted(prefs, id)) continue;
      final delta = (daysSinceStart - id.targetDay).abs();
      if (delta <= _windowDays) return id;
    }
    return null;
  }

  /// 특정 설문을 완료 처리 (timestamp 저장).
  Future<void> markCompleted(SurveyId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedKey(id), _now().toIso8601String());
  }

  Future<bool> _isCompleted(SharedPreferences prefs, SurveyId id) async {
    final v = prefs.getString(_completedKey(id));
    return v != null && v.isNotEmpty;
  }

  static String _completedKey(SurveyId id) => switch (id) {
        SurveyId.baselineD0 => OwnerPrefsKeys.surveyD0CompletedAt,
        SurveyId.pulseD14 => OwnerPrefsKeys.surveyD14CompletedAt,
        SurveyId.finalD28 => OwnerPrefsKeys.surveyD28CompletedAt,
      };

  static int _diffInDays(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return bDate.difference(aDate).inDays;
  }

  String _todayIsoDate() {
    final n = _now();
    return DateTime(n.year, n.month, n.day).toIso8601String();
  }
}
