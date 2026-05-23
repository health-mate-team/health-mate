import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/action_dto.dart';

final actionsRepositoryProvider = Provider<ActionsRepository>(
  (ref) => ActionsRepository(ref.watch(apiClientProvider)),
);

class ActionsRepository {
  const ActionsRepository(this._client);

  final ApiClient _client;

  Future<WaterTodayDto> getWaterToday() async {
    final resp = await _client.dio.get('/actions/water/today');
    return WaterTodayDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<WaterActionResponse> addWater(WaterActionRequest req) async {
    final resp = await _client.dio.post('/actions/water', data: req.toJson());
    return WaterActionResponse.fromJson(ApiClient.unwrap(resp));
  }

  Future<WalkStartResponse> startWalk(WalkStartRequest req) async {
    final resp =
        await _client.dio.post('/actions/walk/start', data: req.toJson());
    return WalkStartResponse.fromJson(ApiClient.unwrap(resp));
  }

  Future<WalkCompleteResponse> completeWalk(WalkCompleteRequest req) async {
    final resp =
        await _client.dio.post('/actions/walk/complete', data: req.toJson());
    return WalkCompleteResponse.fromJson(ApiClient.unwrap(resp));
  }
}
