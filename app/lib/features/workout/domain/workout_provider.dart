import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/workout/data/dto/workout_dto.dart';
import 'package:health_mate/features/workout/data/workout_repository.dart';

final workoutRecommendProvider =
    AsyncNotifierProvider<WorkoutRecommendNotifier, WorkoutRecommendDto?>(
  WorkoutRecommendNotifier.new,
);

class WorkoutRecommendNotifier
    extends AsyncNotifier<WorkoutRecommendDto?> {
  @override
  Future<WorkoutRecommendDto?> build() async {
    return null;
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).getRecommend(),
    );
  }

  Future<WorkoutCompleteResponse?> complete(
    String workoutId, {
    int? durationMinutes,
  }) async {
    final repo = ref.read(workoutRepositoryProvider);
    final resp = await repo.completeWorkout(
      WorkoutCompleteRequest(
        workoutId: workoutId,
        durationActualMinutes: durationMinutes,
      ),
    );
    ref.invalidateSelf();
    return resp;
  }

  Future<void> skip(String workoutId, {String? reason}) async {
    final repo = ref.read(workoutRepositoryProvider);
    await repo.skipWorkout(
      WorkoutSkipRequest(workoutId: workoutId, skipReason: reason),
    );
    ref.invalidateSelf();
  }
}
