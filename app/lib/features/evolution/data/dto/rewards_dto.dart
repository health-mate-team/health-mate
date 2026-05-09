class StreakDto {
  const StreakDto({required this.current, required this.longest});

  factory StreakDto.fromJson(Map<String, dynamic> json) => StreakDto(
        current: (json['current'] as num).toInt(),
        longest: (json['longest'] as num).toInt(),
      );

  final int current;
  final int longest;
}

class EvolutionStageDto {
  const EvolutionStageDto({
    required this.stage,
    required this.name,
    required this.colorToken,
    required this.nextStageXpThreshold,
    required this.xpToNext,
  });

  factory EvolutionStageDto.fromJson(Map<String, dynamic> json) =>
      EvolutionStageDto(
        stage: (json['stage'] as num).toInt(),
        name: json['name'] as String,
        colorToken: json['color_token'] as String? ?? '',
        nextStageXpThreshold:
            (json['next_stage_xp_threshold'] as num? ?? 0).toInt(),
        xpToNext: (json['xp_to_next'] as num? ?? 0).toInt(),
      );

  final int stage;
  final String name;
  final String colorToken;
  final int nextStageXpThreshold;
  final int xpToNext;
}

class BadgeDto {
  const BadgeDto({
    required this.code,
    required this.name,
    required this.description,
    required this.earnedAt,
  });

  factory BadgeDto.fromJson(Map<String, dynamic> json) => BadgeDto(
        code: json['code'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        earnedAt: json['earned_at'] as String,
      );

  final String code;
  final String name;
  final String description;
  final String earnedAt;
}

class XpLogDto {
  const XpLogDto({
    required this.delta,
    required this.reason,
    required this.label,
    required this.createdAt,
  });

  factory XpLogDto.fromJson(Map<String, dynamic> json) => XpLogDto(
        delta: (json['delta'] as num).toInt(),
        reason: json['reason'] as String,
        label: json['label'] as String? ?? '',
        createdAt: json['created_at'] as String,
      );

  final int delta;
  final String reason;
  final String label;
  final String createdAt;
}

/// GET /rewards/summary 응답
class RewardsSummaryDto {
  const RewardsSummaryDto({
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.totalXpEarned,
    required this.streak,
    required this.evolutionStage,
    required this.badges,
    required this.xpLog,
  });

  factory RewardsSummaryDto.fromJson(Map<String, dynamic> json) =>
      RewardsSummaryDto(
        level: (json['level'] as num? ?? 1).toInt(),
        currentXp: (json['current_xp'] as num).toInt(),
        xpToNextLevel: (json['xp_to_next_level'] as num? ?? 0).toInt(),
        totalXpEarned: (json['total_xp_earned'] as num? ?? 0).toInt(),
        streak: StreakDto.fromJson(
            json['streak'] as Map<String, dynamic>? ?? {'current': 0, 'longest': 0}),
        evolutionStage: EvolutionStageDto.fromJson(
            json['evolution_stage'] as Map<String, dynamic>? ??
                {'stage': 1, 'name': '새싹 모아', 'color_token': ''}),
        badges: (json['badges'] as List<dynamic>? ?? [])
            .map((e) => BadgeDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        xpLog: (json['xp_log'] as List<dynamic>? ?? [])
            .map((e) => XpLogDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int totalXpEarned;
  final StreakDto streak;
  final EvolutionStageDto evolutionStage;
  final List<BadgeDto> badges;
  final List<XpLogDto> xpLog;
}
