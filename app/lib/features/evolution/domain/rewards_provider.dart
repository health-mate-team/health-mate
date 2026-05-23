import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/evolution/data/dto/rewards_dto.dart';
import 'package:health_mate/features/evolution/data/rewards_repository.dart';

final rewardsSummaryProvider =
    AsyncNotifierProvider<RewardsSummaryNotifier, RewardsSummaryDto>(
  RewardsSummaryNotifier.new,
);

class RewardsSummaryNotifier extends AsyncNotifier<RewardsSummaryDto> {
  @override
  Future<RewardsSummaryDto> build() =>
      ref.watch(rewardsRepositoryProvider).getSummary();

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
