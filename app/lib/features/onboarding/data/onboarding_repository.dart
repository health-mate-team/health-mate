import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/onboarding_dto.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(apiClientProvider)),
);

class OnboardingRepository {
  const OnboardingRepository(this._client);

  final ApiClient _client;

  Future<OnboardingCompleteResponse> complete(
    OnboardingCompleteRequest req,
  ) async {
    final resp = await _client.dio.post(
      '/onboarding/complete',
      data: req.toJson(),
    );
    return OnboardingCompleteResponse.fromJson(ApiClient.unwrap(resp));
  }
}
