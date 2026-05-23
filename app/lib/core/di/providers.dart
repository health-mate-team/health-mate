// 전역 DI 프로바이더 모음.
// 각 Feature의 Repository, Service 프로바이더는 해당 feature/data/ 에 위치.
// 이 파일에는 앱 전역 공유 프로바이더만 등록한다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:health_mate/core/db/app_database.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'package:health_mate/core/network/token_storage.dart';

export 'package:health_mate/routing/app_router.dart';

part 'providers.g.dart';

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(_secureStorageProvider)),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
