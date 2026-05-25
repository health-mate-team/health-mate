import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/nutrition/data/dto/nutrition_dto.dart';
import 'package:health_mate/features/nutrition/data/nutrition_repository.dart';

final nutritionTodayProvider =
    AsyncNotifierProvider<NutritionTodayNotifier, NutritionTodayDto?>(
  NutritionTodayNotifier.new,
);

class NutritionTodayNotifier extends AsyncNotifier<NutritionTodayDto?> {
  @override
  Future<NutritionTodayDto?> build() async {
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(nutritionRepositoryProvider).getToday(),
    );
  }

  Future<NutritionLogResponse?> logMeal(NutritionLogRequest req) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final resp = await repo.logMeal(req);
    await refresh();
    return resp;
  }
}

final nutritionSearchProvider =
    AsyncNotifierProvider<NutritionSearchNotifier, NutritionSearchDto?>(
  NutritionSearchNotifier.new,
);

class NutritionSearchNotifier extends AsyncNotifier<NutritionSearchDto?> {
  @override
  Future<NutritionSearchDto?> build() async => null;

  Future<void> search(String q) async {
    if (q.isEmpty) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(nutritionRepositoryProvider).search(q),
    );
  }
}
