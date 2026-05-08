/// 음식 검색 결과 항목
class FoodSearchResult {
  const FoodSearchResult({
    required this.foodId,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.source,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) =>
      FoodSearchResult(
        foodId: json['food_id'] as String,
        name: json['name'] as String,
        caloriesPer100g: (json['calories_per_100g'] as num).toInt(),
        proteinG: (json['protein_g'] as num).toDouble(),
        carbsG: (json['carbs_g'] as num).toDouble(),
        fatG: (json['fat_g'] as num).toDouble(),
        source: json['source'] as String? ?? '식약처',
      );

  final String foodId;
  final String name;
  final int caloriesPer100g;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String source;
}

/// GET /nutrition/search 응답
class NutritionSearchDto {
  const NutritionSearchDto({required this.query, required this.results});

  factory NutritionSearchDto.fromJson(Map<String, dynamic> json) =>
      NutritionSearchDto(
        query: json['query'] as String? ?? '',
        results: (json['results'] as List<dynamic>? ?? [])
            .map((e) => FoodSearchResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String query;
  final List<FoodSearchResult> results;
}

/// POST /nutrition/logs 요청
class NutritionLogRequest {
  const NutritionLogRequest({
    required this.mealType,
    required this.foods,
    this.date,
  });

  final String mealType;
  final List<FoodItem> foods;
  final String? date;

  Map<String, dynamic> toJson() => {
        'meal_type': mealType,
        'foods': foods.map((f) => f.toJson()).toList(),
        if (date != null) 'date': date,
      };
}

/// 음식 항목
class FoodItem {
  const FoodItem({required this.foodId, required this.amountG});

  final String foodId;
  final int amountG;

  Map<String, dynamic> toJson() => {'food_id': foodId, 'amount_g': amountG};
}

/// POST /nutrition/logs 응답
class NutritionLogResponse {
  const NutritionLogResponse({
    required this.mealLogId,
    required this.totalCalories,
    required this.xpEarned,
  });

  factory NutritionLogResponse.fromJson(Map<String, dynamic> json) =>
      NutritionLogResponse(
        mealLogId: json['meal_log_id'] as String,
        totalCalories: (json['total_calories'] as num).toInt(),
        xpEarned: (json['xp_earned'] as num).toInt(),
      );

  final String mealLogId;
  final int totalCalories;
  final int xpEarned;
}

/// 식사 요약 항목
class MealSummaryItem {
  const MealSummaryItem({
    required this.mealType,
    required this.calories,
    required this.foodsCount,
  });

  factory MealSummaryItem.fromJson(Map<String, dynamic> json) =>
      MealSummaryItem(
        mealType: json['meal_type'] as String,
        calories: (json['calories'] as num).toInt(),
        foodsCount: (json['foods_count'] as num? ?? 0).toInt(),
      );

  final String mealType;
  final int calories;
  final int foodsCount;
}

/// GET /nutrition/today 응답
class NutritionTodayDto {
  const NutritionTodayDto({
    required this.date,
    required this.totalCalories,
    required this.dailyTargetCalories,
    required this.phaseRecommendation,
    required this.meals,
  });

  factory NutritionTodayDto.fromJson(Map<String, dynamic> json) {
    final phaseRec =
        json['phase_recommendation'] as Map<String, dynamic>? ?? {};
    return NutritionTodayDto(
      date: json['date'] as String,
      totalCalories: (json['total_calories'] as num? ?? 0).toInt(),
      dailyTargetCalories:
          (json['daily_target_calories'] as num? ?? 1800).toInt(),
      phaseRecommendation: PhaseRecommendation.fromJson(phaseRec),
      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((e) => MealSummaryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String date;
  final int totalCalories;
  final int dailyTargetCalories;
  final PhaseRecommendation phaseRecommendation;
  final List<MealSummaryItem> meals;
}

/// phase_recommendation 내부
class PhaseRecommendation {
  const PhaseRecommendation({
    required this.phase,
    required this.focusNutrients,
    required this.message,
  });

  factory PhaseRecommendation.fromJson(Map<String, dynamic> json) =>
      PhaseRecommendation(
        phase: json['phase'] as String? ?? 'follicular',
        focusNutrients: (json['focus_nutrients'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        message: json['message'] as String? ?? '',
      );

  final String phase;
  final List<String> focusNutrients;
  final String message;
}
