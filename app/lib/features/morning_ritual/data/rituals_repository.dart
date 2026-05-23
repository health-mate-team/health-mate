import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/ritual_dto.dart';

final ritualsRepositoryProvider = Provider<RitualsRepository>(
  (ref) => RitualsRepository(ref.watch(apiClientProvider)),
);

class RitualsRepository {
  const RitualsRepository(this._client);

  final ApiClient _client;

  Future<RitualTodayDto> getToday() async {
    final resp = await _client.dio.get('/rituals/today');
    return RitualTodayDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<MorningMoodResponse> submitMorningMood(
    MorningMoodRequest req,
  ) async {
    final resp = await _client.dio.post(
      '/rituals/morning/mood',
      data: req.toJson(),
    );
    return MorningMoodResponse.fromJson(ApiClient.unwrap(resp));
  }

  Future<MorningPromiseResponse> submitMorningPromise(
    MorningPromiseRequest req,
  ) async {
    final resp = await _client.dio.post(
      '/rituals/morning/promise',
      data: req.toJson(),
    );
    return MorningPromiseResponse.fromJson(ApiClient.unwrap(resp));
  }
}
