/// 오우너 앱 로컬(SharedPreferences) 키 — API 연동 전 임시 저장
class OwnerPrefsKeys {
  OwnerPrefsKeys._();

  static const String onboardingDone = 'owner_onboarding_done';
  static const String displayName = 'owner_display_name';
  static const String goalId = 'owner_goal_id';
  static const String morningMoodId = 'owner_morning_mood_id';

  /// 아침 의식에서 확정한 오늘의 약속 (저녁 의식·홈 카드와 공유)
  static const String todayPromiseText = 'owner_today_promise_text';
  static const String todayPromiseScheduledTime =
      'owner_today_promise_scheduled_time';
  static const String todayPromiseRewardXp = 'owner_today_promise_reward_xp';
  static const String todayPromiseCompleted = 'owner_today_promise_completed';

  /// 베타 코호트 시작일 (ISO 8601, 첫 onboarding 완료 시 1회 기록).
  /// 04_SUCCESS_METRICS.measurement_window 의 D0 기준점.
  static const String betaStartDate = 'owner_beta_start_date';

  /// 각 설문(D0/D14/D28)의 완료 시각. null 또는 미존재 = 미완료.
  static const String surveyD0CompletedAt = 'owner_survey_d0_completed_at';
  static const String surveyD14CompletedAt = 'owner_survey_d14_completed_at';
  static const String surveyD28CompletedAt = 'owner_survey_d28_completed_at';
}
