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
}
