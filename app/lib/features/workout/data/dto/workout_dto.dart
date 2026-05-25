/// GET /workout/recommend → recommendation 항목
class WorkoutRecommendItem {
  const WorkoutRecommendItem({
    required this.workoutId,
    required this.title,
    required this.type,
    required this.intensity,
    required this.durationMinutes,
    required this.phaseFit,
    this.thumbnailUrl,
    this.videoUrl,
    required this.isVideoReady,
    required this.fallbackType,
  });

  factory WorkoutRecommendItem.fromJson(Map<String, dynamic> json) =>
      WorkoutRecommendItem(
        workoutId: json['workout_id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        intensity: json['intensity'] as String,
        durationMinutes: (json['duration_minutes'] as num).toInt(),
        phaseFit: json['phase_fit'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        videoUrl: json['video_url'] as String?,
        isVideoReady: json['is_video_ready'] as bool? ?? false,
        fallbackType: json['fallback_type'] as String? ?? 'svg_animation',
      );

  final String workoutId;
  final String title;
  final String type;
  final String intensity;
  final int durationMinutes;
  final String phaseFit;
  final String? thumbnailUrl;
  final String? videoUrl;
  final bool isVideoReady;
  final String fallbackType;
}

/// GET /workout/recommend 응답
class WorkoutRecommendDto {
  const WorkoutRecommendDto({
    required this.recommendation,
    required this.basedOn,
    this.alternative,
  });

  factory WorkoutRecommendDto.fromJson(Map<String, dynamic> json) =>
      WorkoutRecommendDto(
        recommendation: WorkoutRecommendItem.fromJson(
          json['recommendation'] as Map<String, dynamic>,
        ),
        basedOn: json['based_on'] as Map<String, dynamic>? ?? {},
        alternative: json['alternative'] != null
            ? WorkoutRecommendItem.fromJson(
                json['alternative'] as Map<String, dynamic>,
              )
            : null,
      );

  final WorkoutRecommendItem recommendation;
  final Map<String, dynamic> basedOn;
  final WorkoutRecommendItem? alternative;
}

/// POST /workout/complete 요청
class WorkoutCompleteRequest {
  const WorkoutCompleteRequest({
    required this.workoutId,
    this.date,
    this.durationActualMinutes,
    this.completionRate,
  });

  final String workoutId;
  final String? date;
  final int? durationActualMinutes;
  final double? completionRate;

  Map<String, dynamic> toJson() => {
        'workout_id': workoutId,
        if (date != null) 'date': date,
        if (durationActualMinutes != null)
          'duration_actual_minutes': durationActualMinutes,
        if (completionRate != null) 'completion_rate': completionRate,
      };
}

/// POST /workout/complete 응답
class WorkoutCompleteResponse {
  const WorkoutCompleteResponse({
    required this.xpEarned,
    required this.energyStatDelta,
  });

  factory WorkoutCompleteResponse.fromJson(Map<String, dynamic> json) =>
      WorkoutCompleteResponse(
        xpEarned: (json['xp_earned'] as num).toInt(),
        energyStatDelta: (json['energy_stat_delta'] as num).toInt(),
      );

  final int xpEarned;
  final int energyStatDelta;
}

/// POST /workout/skip 요청
class WorkoutSkipRequest {
  const WorkoutSkipRequest({required this.workoutId, this.date, this.skipReason});

  final String workoutId;
  final String? date;
  final String? skipReason;

  Map<String, dynamic> toJson() => {
        'workout_id': workoutId,
        if (date != null) 'date': date,
        if (skipReason != null) 'skip_reason': skipReason,
      };
}

/// POST /workout/skip 응답
class WorkoutSkipResponse {
  const WorkoutSkipResponse({required this.skipped, required this.workoutId});

  factory WorkoutSkipResponse.fromJson(Map<String, dynamic> json) =>
      WorkoutSkipResponse(
        skipped: json['skipped'] as bool? ?? true,
        workoutId: json['workout_id'] as String,
      );

  final bool skipped;
  final String workoutId;
}
