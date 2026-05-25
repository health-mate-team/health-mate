/// POST /actions/water 요청
class WaterActionRequest {
  const WaterActionRequest({required this.cupsAdded, this.date});

  final int cupsAdded;
  final String? date;

  Map<String, dynamic> toJson() => {
        'cups_added': cupsAdded,
        if (date != null) 'date': date,
      };
}

/// POST /actions/water 응답
class WaterActionResponse {
  const WaterActionResponse({
    required this.todayCupsTotal,
    required this.dailyTargetCups,
    required this.hydrationStat,
    required this.xpEarned,
    required this.moaReaction,
  });

  factory WaterActionResponse.fromJson(Map<String, dynamic> json) =>
      WaterActionResponse(
        todayCupsTotal: (json['today_cups_total'] as num).toInt(),
        dailyTargetCups: (json['daily_target_cups'] as num? ?? 8).toInt(),
        hydrationStat: (json['hydration_stat'] as num).toInt(),
        xpEarned: (json['xp_earned'] as num).toInt(),
        moaReaction: json['moa_reaction'] as String? ?? '',
      );

  final int todayCupsTotal;
  final int dailyTargetCups;
  final int hydrationStat;
  final int xpEarned;
  final String moaReaction;
}

/// GET /actions/water/today 응답
class WaterTodayDto {
  const WaterTodayDto({
    required this.date,
    required this.cupsTotal,
    required this.dailyTargetCups,
  });

  factory WaterTodayDto.fromJson(Map<String, dynamic> json) => WaterTodayDto(
        date: json['date'] as String,
        cupsTotal: (json['cups_total'] as num).toInt(),
        dailyTargetCups: (json['daily_target_cups'] as num? ?? 8).toInt(),
      );

  final String date;
  final int cupsTotal;
  final int dailyTargetCups;
}

/// POST /actions/walk/start 요청
class WalkStartRequest {
  const WalkStartRequest({required this.startedAt});

  final String startedAt;

  Map<String, dynamic> toJson() => {'started_at': startedAt};
}

/// POST /actions/walk/start 응답
class WalkStartResponse {
  const WalkStartResponse({
    required this.walkSessionId,
    required this.startedAt,
  });

  factory WalkStartResponse.fromJson(Map<String, dynamic> json) =>
      WalkStartResponse(
        walkSessionId: json['walk_session_id'] as String,
        startedAt: json['started_at'] as String,
      );

  final String walkSessionId;
  final String startedAt;
}

/// POST /actions/walk/complete 요청
class WalkCompleteRequest {
  const WalkCompleteRequest({
    required this.walkSessionId,
    required this.endedAt,
    required this.durationMinutes,
    this.stepsCount,
    this.distanceKm,
  });

  final String walkSessionId;
  final String endedAt;
  final int durationMinutes;
  final int? stepsCount;
  final double? distanceKm;

  Map<String, dynamic> toJson() => {
        'walk_session_id': walkSessionId,
        'ended_at': endedAt,
        'duration_minutes': durationMinutes,
        if (stepsCount != null) 'steps_count': stepsCount,
        if (distanceKm != null) 'distance_km': distanceKm,
      };
}

/// POST /actions/walk/complete 응답
class WalkCompleteResponse {
  const WalkCompleteResponse({
    required this.durationMinutes,
    required this.distanceKm,
    required this.energyStatDelta,
    required this.xpEarned,
    required this.moaReaction,
  });

  factory WalkCompleteResponse.fromJson(Map<String, dynamic> json) =>
      WalkCompleteResponse(
        durationMinutes: (json['duration_minutes'] as num).toInt(),
        distanceKm: (json['distance_km'] as num? ?? 0).toDouble(),
        energyStatDelta: (json['energy_stat_delta'] as num).toInt(),
        xpEarned: (json['xp_earned'] as num).toInt(),
        moaReaction: json['moa_reaction'] as String? ?? '',
      );

  final int durationMinutes;
  final double distanceKm;
  final int energyStatDelta;
  final int xpEarned;
  final String moaReaction;
}
