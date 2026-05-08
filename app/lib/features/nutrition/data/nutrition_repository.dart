import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/nutrition_dto.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepository(ref.watch(apiClientProvider)),
);

class NutritionRepository {
  const NutritionRepository(this._client);

  final ApiClient _client;

  Future<NutritionSearchDto> search(String q, {int limit = 10}) async {
    final resp = await _client.dio
        .get('/nutrition/search', queryParameters: {'q': q, 'limit': limit});
    return NutritionSearchDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<NutritionLogResponse> logMeal(NutritionLogRequest req) async {
    final resp =
        await _client.dio.post('/nutrition/logs', data: req.toJson());
    return NutritionLogResponse.fromJson(ApiClient.unwrap(resp));
  }

  Future<NutritionTodayDto> getToday() async {
    final resp = await _client.dio.get('/nutrition/today');
    return NutritionTodayDto.fromJson(ApiClient.unwrap(resp));
  }
}
