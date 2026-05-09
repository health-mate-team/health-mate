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
    // 낙관적 업데이트: API 호출 전 cupsTotal +1을 즉시 반영
    final prev = state.valueOrNull;
    if (prev != null) {
      state = AsyncData(WaterTodayDto(
        date: prev.date,
        cupsTotal: (prev.cupsTotal + 1).clamp(0, prev.dailyTargetCups),
        dailyTargetCups: prev.dailyTargetCups,
      ));
    }
    try {
      final result = await ref
          .read(actionsRepositoryProvider)
          .addWater(const WaterActionRequest(cupsAdded: 1));
      ref.invalidateSelf(); // 서버 확정 값으로 최종 동기화
      return result;
    } catch (e) {
      // API 실패 시 이전 상태로 롤백
      if (prev != null) state = AsyncData(prev);
      rethrow;
    }
  }
}
