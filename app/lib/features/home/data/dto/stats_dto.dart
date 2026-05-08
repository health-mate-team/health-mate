/// GET /stats/today — backend nested 응답을 평탄 구조로 변환
class StatsTodayDto {
  const StatsTodayDto({
    required this.energy,
    required this.hydration,
    required this.rest,
    required this.xpToday,
    required this.totalXp,
    required this.level,
    required this.streak,
    required this.currentPhase,
    required this.dayOfCycle,
    required this.userName,
  });

  factory StatsTodayDto.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>?;
    final cycle = json['cycle'] as Map<String, dynamic>?;
    final ritual = json['today_ritual'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    return StatsTodayDto(
      energy: ((stats?['energy_score'] as num?) ?? 50).toInt(),
      hydration: ((stats?['hydration_score'] as num?) ?? 50).toInt(),
      rest: ((stats?['rest_score'] as num?) ?? 50).toInt(),
      xpToday: ((ritual?['xp_earned_today'] as num?) ?? 0).toInt(),
      totalXp: ((stats?['total_xp'] as num?) ?? 0).toInt(),
      level: ((stats?['level'] as num?) ?? 1).toInt(),
      streak: ((stats?['streak'] as num?) ?? 0).toInt(),
      currentPhase: cycle?['current_phase'] as String? ?? 'follicular',
      dayOfCycle: ((cycle?['day_of_cycle'] as num?) ?? 1).toInt(),
      userName: user?['name'] as String? ?? '',
    );
  }

  final int energy;
  final int hydration;
  final int rest;
  final int xpToday;
  final int totalXp;
  final int level;
  final int streak;
  final String currentPhase;
  final int dayOfCycle;
  final String userName;
}
