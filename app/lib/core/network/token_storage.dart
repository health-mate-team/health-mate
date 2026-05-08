import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  Future<void> clearTokens() => _storage.delete(key: _accessKey);
}
