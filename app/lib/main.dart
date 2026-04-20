import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase.initializeApp()
  // TODO: Drift DB 초기화
  // TODO: WorkManager 초기화
  runApp(const ProviderScope(child: HealthMateApp()));
}
