import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/stats_dto.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(apiClientProvider)),
);

class StatsRepository {
  const StatsRepository(this._client);

  final ApiClient _client;

  Future<StatsTodayDto> getToday() async {
    final resp = await _client.dio.get('/stats/today');
    return StatsTodayDto.fromJson(ApiClient.unwrap(resp));
  }
}
