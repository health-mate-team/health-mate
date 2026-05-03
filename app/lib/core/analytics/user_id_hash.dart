import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 04_SUCCESS_METRICS.json data_storage_principles 준수:
/// 분석 데이터의 user_id 는 hash 처리 후 사용.
/// 디바이스에 한 번만 생성된 UUID 의 SHA-256 해시를 반환.
class UserIdHashProvider {
  static const _prefsKey = 'analytics.user_seed';

  Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    var seed = prefs.getString(_prefsKey);
    if (seed == null || seed.isEmpty) {
      seed = _randomSeed();
      await prefs.setString(_prefsKey, seed);
    }
    return sha256.convert(utf8.encode(seed)).toString();
  }

  static String _randomSeed() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
