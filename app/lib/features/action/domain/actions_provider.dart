import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/action/data/actions_repository.dart';
import 'package:health_mate/features/action/data/dto/action_dto.dart';

final waterTodayProvider =
    AsyncNotifierProvider<WaterTodayNotifier, WaterTodayDto>(
  WaterTodayNotifier.new,
);

class WaterTodayNotifier extends AsyncNotifier<WaterTodayDto> {
  @override
  Future<WaterTodayDto> build() =>
      ref.watch(actionsRepositoryProvider).getWaterToday();

  Future<WaterActionResponse> addCup() async {
    final result = await ref
        .read(actionsRepositoryProvider)
        .addWater(const WaterActionRequest(cupsAdded: 1));
    ref.invalidateSelf();
    return result;
  }
}
