// Backend UNIT stage 실행 후 .verify-cache/ fixture를 로드하여
// Flutter DTO fromJson 정합성을 검증한다.
//
// fixture 없으면 markTestSkipped (graceful skip):
//   cd backend && npx ts-node --project scripts/tsconfig.json scripts/run-cases.ts \
//     --target <catalog_id> --stages unit
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/features/auth/data/dto/auth_dto.dart';
import 'package:health_mate/features/onboarding/data/dto/onboarding_dto.dart';

// CWD = app/ (flutter test 실행 시 pubspec.yaml 위치 기준)
// 프로젝트 루트 .verify-cache/ = ../.verify-cache/
String _fixturePath(String target, String caseId) =>
    '../.verify-cache/$target/$caseId.json';

/// fixture 로드 + body.data 추출. 파일 없으면 null 반환.
Map<String, dynamic>? _loadData(String target, String caseId) {
  final file = File(_fixturePath(target, caseId));
  if (!file.existsSync()) return null;
  final body = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return body['data'] as Map<String, dynamic>?;
}

void main() {
  group('[Contract] auth_register#happy → RegisterResponse', () {
    test('fixture → access_token 파싱', () {
      final data = _loadData('auth_register', 'happy');
      if (data == null) {
        markTestSkipped(
          'fixture 없음: cd backend && npx ts-node --project scripts/tsconfig.json '
          'scripts/run-cases.ts --target auth_register --stages unit',
        );
        return;
      }
      final dto = RegisterResponse.fromJson(data);
      expect(dto.accessToken, isA<String>());
      expect(dto.accessToken, isNotEmpty,
          reason: 'access_token은 비어있으면 안 됨');
    });
  });

  group('[Contract] onboarding_complete#happy → OnboardingCompleteResponse', () {
    test('fixture → initial_stats + current_phase 파싱', () {
      final data = _loadData('onboarding_complete', 'happy');
      if (data == null) {
        markTestSkipped(
          'fixture 없음: cd backend && npx ts-node --project scripts/tsconfig.json '
          'scripts/run-cases.ts --target onboarding_complete --stages unit',
        );
        return;
      }
      final dto = OnboardingCompleteResponse.fromJson(data);
      expect(dto.currentPhase, isA<String>());
      expect(dto.currentPhase, isNotEmpty);
      expect(dto.initialStats.energyScore, isA<int>());
      expect(dto.initialStats.hydrationScore, isA<int>());
      expect(dto.initialStats.restScore, isA<int>());
      expect(dto.initialStats.totalXp, isA<int>());
      expect(dto.initialStats.level, greaterThanOrEqualTo(1));
      expect(dto.initialStats.streak, isA<int>());
    });
  });
}
