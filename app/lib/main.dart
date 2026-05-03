import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Drift DB / Riverpod 는 첫 사용 시점에 lazy 초기화 — appDatabaseProvider 가 keepAlive.
  // TODO: Firebase.initializeApp()
  // TODO: WorkManager 초기화
  runApp(const ProviderScope(child: HealthMateApp()));
}
