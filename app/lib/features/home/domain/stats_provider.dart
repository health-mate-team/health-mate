import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/home/data/dto/stats_dto.dart';
import 'package:health_mate/features/home/data/stats_repository.dart';

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, StatsTodayDto>(StatsNotifier.new);

class StatsNotifier extends AsyncNotifier<StatsTodayDto> {
  @override
  Future<StatsTodayDto> build() =>
      ref.watch(statsRepositoryProvider).getToday();

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
