/// GET /rituals/today 응답
class RitualTodayDto {
  const RitualTodayDto({
    required this.date,
    this.morningMood,
    this.morningPromise,
    required this.eveningCompleted,
    required this.promiseKept,
    required this.xpEarned,
  });

  factory RitualTodayDto.fromJson(Map<String, dynamic> json) => RitualTodayDto(
        date: json['date'] as String,
        morningMood: (json['morning_mood'] as num?)?.toInt(),
        morningPromise: json['morning_promise'] as String?,
        eveningCompleted: json['evening_completed'] as bool,
        promiseKept: json['promise_kept'] as bool,
        xpEarned: (json['xp_earned_today'] as num? ?? 0).toInt(),
      );

  final String date;
  final int? morningMood;
  final String? morningPromise;
  final bool eveningCompleted;
  final bool promiseKept;
  final int xpEarned;
}

/// POST /rituals/morning/mood 요청
class MorningMoodRequest {
  const MorningMoodRequest({required this.mood});

  /// 1~5 숫자 (great=5, okay=3, tired=2, exhausted=1)
  final int mood;

  Map<String, dynamic> toJson() => {'mood': mood};
}

class MorningMoodResponse {
  const MorningMoodResponse({
    required this.mood,
    required this.xpEarned,
    required this.recommendedPromise,
    required this.totalXp,
  });

  factory MorningMoodResponse.fromJson(Map<String, dynamic> json) =>
      MorningMoodResponse(
        mood: (json['mood'] as num).toInt(),
        xpEarned: (json['xp_earned'] as num).toInt(),
        recommendedPromise:
            json['recommended_promise'] as String? ?? '',
        totalXp: (json['total_xp'] as num? ?? 0).toInt(),
      );

  final int mood;
  final int xpEarned;
  final String recommendedPromise;
  final int totalXp;
}

/// POST /rituals/morning/promise 요청
class MorningPromiseRequest {
  const MorningPromiseRequest({required this.promise});

  final String promise;

  Map<String, dynamic> toJson() => {'promise': promise};
}

class MorningPromiseResponse {
  const MorningPromiseResponse({
    required this.promise,
    required this.savedAt,
  });

  factory MorningPromiseResponse.fromJson(Map<String, dynamic> json) =>
      MorningPromiseResponse(
        promise: json['promise'] as String,
        savedAt: json['saved_at'] as String? ?? '',
      );

  final String promise;
  final String savedAt;
}
