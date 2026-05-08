import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/cycle_dto.dart';

final cycleRepositoryProvider = Provider<CycleRepository>(
  (ref) => CycleRepository(ref.watch(apiClientProvider)),
);

class CycleRepository {
  const CycleRepository(this._client);

  final ApiClient _client;

  Future<CycleCurrentDto> getCurrent() async {
    final resp = await _client.dio.get('/cycle/current');
    return CycleCurrentDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<CycleCurrentDto> updateSettings(CycleSettingsRequest req) async {
    final resp = await _client.dio.patch(
      '/cycle/settings',
      data: req.toJson(),
    );
    return CycleCurrentDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<List<CycleCalendarDayDto>> getCalendar({
    required int year,
    required int month,
  }) async {
    final resp = await _client.dio.get(
      '/cycle/calendar',
      queryParameters: {'year': year, 'month': month},
    );
    final data = ApiClient.unwrap(resp);
    return (data['days'] as List<dynamic>)
        .map((e) => CycleCalendarDayDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
