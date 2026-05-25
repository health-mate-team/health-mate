import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'dto/user_profile_dto.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiClientProvider)),
);

class UsersRepository {
  const UsersRepository(this._client);

  final ApiClient _client;

  Future<UserProfileDto> getMe() async {
    final resp = await _client.dio.get('/users/me');
    return UserProfileDto.fromJson(ApiClient.unwrap(resp));
  }

  Future<UserProfileDto> updateMe(UpdateProfileRequest req) async {
    final resp = await _client.dio.patch('/users/me', data: req.toJson());
    return UserProfileDto.fromJson(ApiClient.unwrap(resp));
  }
}
