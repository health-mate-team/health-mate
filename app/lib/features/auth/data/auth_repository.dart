import 'package:health_mate/core/network/api_client.dart';
import 'package:health_mate/core/network/token_storage.dart';
import 'dto/auth_dto.dart';

class AuthRepository {
  const AuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<RegisterResponse> register(RegisterRequest req) async {
    final resp = await _client.dio.post('/auth/register', data: req.toJson());
    final data = ApiClient.unwrap(resp);
    final result = RegisterResponse.fromJson(data);
    await _tokenStorage.saveAccessToken(result.accessToken);
    return result;
  }

  Future<LoginResponse> login(LoginRequest req) async {
    final resp = await _client.dio.post('/auth/login', data: req.toJson());
    final data = ApiClient.unwrap(resp);
    final result = LoginResponse.fromJson(data);
    await _tokenStorage.saveAccessToken(result.accessToken);
    return result;
  }

  Future<void> logout() async {
    try {
      await _client.dio.post('/auth/logout');
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}
