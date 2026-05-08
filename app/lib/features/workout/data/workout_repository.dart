import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/workout_dto.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(apiClientProvider)),
);

class WorkoutRepository {
  const WorkoutRepository(this._client);

  final ApiClient _client;

  Future<WorkoutRecommendDto> getRecommend() async {
    final resp = await _client.dio.get('/workout/recommend');
    return WorkoutRecommendDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<WorkoutCompleteResponse> completeWorkout(
    WorkoutCompleteRequest req,
  ) async {
    final resp =
        await _client.dio.post('/workout/complete', data: req.toJson());
    return WorkoutCompleteResponse.fromJson(ApiClient.unwrap(resp));
  }

  Future<WorkoutSkipResponse> skipWorkout(WorkoutSkipRequest req) async {
    final resp = await _client.dio.post('/workout/skip', data: req.toJson());
    return WorkoutSkipResponse.fromJson(ApiClient.unwrap(resp));
  }
}
