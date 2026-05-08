/// POST /rituals/evening 요청
class EveningRitualRequest {
  const EveningRitualRequest({required this.promiseKept});

  final bool promiseKept;

  Map<String, dynamic> toJson() => {'promise_kept': promiseKept};
}

class EveningRitualResponse {
  const EveningRitualResponse({
    required this.promiseKept,
    required this.xpEarned,
    required this.totalXp,
    required this.streak,
    required this.level,
  });

  factory EveningRitualResponse.fromJson(Map<String, dynamic> json) =>
      EveningRitualResponse(
        promiseKept: json['promise_kept'] as bool,
        xpEarned: (json['xp_earned'] as num).toInt(),
        totalXp: (json['total_xp'] as num? ?? 0).toInt(),
        streak: (json['streak'] as num).toInt(),
        level: (json['level'] as num? ?? 1).toInt(),
      );

  final bool promiseKept;
  final int xpEarned;
  final int totalXp;
  final int streak;
  final int level;
}
