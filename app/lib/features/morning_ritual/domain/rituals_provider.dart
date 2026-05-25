import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/morning_ritual/data/dto/ritual_dto.dart';
import 'package:health_mate/features/morning_ritual/data/rituals_repository.dart';

final ritualTodayProvider =
    AsyncNotifierProvider<RitualTodayNotifier, RitualTodayDto>(
  RitualTodayNotifier.new,
);

class RitualTodayNotifier extends AsyncNotifier<RitualTodayDto> {
  @override
  Future<RitualTodayDto> build() =>
      ref.watch(ritualsRepositoryProvider).getToday();

  Future<MorningMoodResponse> submitMood(int numericValue) async {
    final req = MorningMoodRequest(mood: numericValue);
    final result =
        await ref.read(ritualsRepositoryProvider).submitMorningMood(req);
    ref.invalidateSelf();
    return result;
  }

  Future<MorningPromiseResponse> submitPromise(String promise) async {
    final req = MorningPromiseRequest(promise: promise);
    final result =
        await ref.read(ritualsRepositoryProvider).submitMorningPromise(req);
    ref.invalidateSelf();
    return result;
  }
}
