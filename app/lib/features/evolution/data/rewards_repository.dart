import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/rewards_dto.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepository(ref.watch(apiClientProvider)),
);

class RewardsRepository {
  const RewardsRepository(this._client);

  final ApiClient _client;

  Future<RewardsSummaryDto> getSummary() async {
    final resp = await _client.dio.get('/rewards/summary');
    return RewardsSummaryDto.fromJson(ApiClient.unwrap(resp));
  }
}
