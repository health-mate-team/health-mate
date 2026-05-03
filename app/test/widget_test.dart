// 앱 부트 smoke test — HealthMateApp 이 라우터와 함께 빌드되는지만 확인.
// 본격 위젯 테스트는 features/*/test 에 분리.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_mate/app.dart';

void main() {
  testWidgets('HealthMateApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HealthMateApp()));
    // 라우터 초기 라우트 = /splash. 화면이 빌드되면 MaterialApp 이 뿌리에 있다.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
