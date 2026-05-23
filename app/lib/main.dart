import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter Web e2e 테스트용 semantics 활성화 (Playwright flt-semantics-identifier 접근)
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  await initializeDateFormatting('ko_KR');
  // Drift DB / Riverpod 는 첫 사용 시점에 lazy 초기화 — appDatabaseProvider 가 keepAlive.
  // TODO: Firebase.initializeApp()
  // TODO: WorkManager 초기화
  runApp(const ProviderScope(child: HealthMateApp()));
}
