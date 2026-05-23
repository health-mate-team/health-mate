import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/evening_dto.dart';

final eveningRepositoryProvider = Provider<EveningRepository>(
  (ref) => EveningRepository(ref.watch(apiClientProvider)),
);

class EveningRepository {
  const EveningRepository(this._client);

  final ApiClient _client;

  Future<EveningRitualResponse> submitEvening(
    EveningRitualRequest req,
  ) async {
    final resp = await _client.dio.post(
      '/rituals/evening',
      data: req.toJson(),
    );
    return EveningRitualResponse.fromJson(ApiClient.unwrap(resp));
  }
}
