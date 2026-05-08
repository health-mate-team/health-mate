class OnboardingCompleteRequest {
  const OnboardingCompleteRequest({
    required this.name,
    required this.goalType,
    required this.lastPeriodStartDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.isIrregular,
  });

  final String name;
  final String goalType;
  final String lastPeriodStartDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool isIrregular;

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal_type': goalType,
        'last_period_start_date': lastPeriodStartDate,
        'average_cycle_length': averageCycleLength,
        'average_period_length': averagePeriodLength,
        'is_irregular': isIrregular,
      };
}

class InitialStats {
  const InitialStats({
    required this.energyScore,
    required this.hydrationScore,
    required this.moodScore,
    required this.restScore,
    required this.waterCups,
    required this.totalXp,
    required this.level,
    required this.streak,
  });

  factory InitialStats.fromJson(Map<String, dynamic> json) => InitialStats(
        energyScore: (json['energy_score'] as num).toInt(),
        hydrationScore: (json['hydration_score'] as num).toInt(),
        moodScore: (json['mood_score'] as num).toInt(),
        restScore: (json['rest_score'] as num? ?? 50).toInt(),
        waterCups: (json['water_cups'] as num).toInt(),
        totalXp: (json['total_xp'] as num).toInt(),
        level: (json['level'] as num).toInt(),
        streak: (json['streak'] as num).toInt(),
      );

  final int energyScore;
  final int hydrationScore;
  final int moodScore;
  final int restScore;
  final int waterCups;
  final int totalXp;
  final int level;
  final int streak;
}

class OnboardingCompleteResponse {
  const OnboardingCompleteResponse({
    required this.currentPhase,
    required this.initialStats,
  });

  factory OnboardingCompleteResponse.fromJson(Map<String, dynamic> json) =>
      OnboardingCompleteResponse(
        currentPhase: json['current_phase'] as String,
        initialStats:
            InitialStats.fromJson(json['initial_stats'] as Map<String, dynamic>),
      );

  final String currentPhase;
  final InitialStats initialStats;
}
