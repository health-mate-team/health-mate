import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:health_mate/features/survey/domain/entities/survey.dart';
import 'package:health_mate/features/survey/domain/services/survey_trigger_service.dart';

part 'survey_providers.g.dart';

@Riverpod(keepAlive: true)
SurveyTriggerService surveyTriggerService(Ref ref) =>
    const SurveyTriggerService();

/// 지금 보여줘야 할 설문 ID.
/// 진입(라우터·홈 initState) 시 한 번 read 해서 분기.
@riverpod
Future<SurveyId?> nextDueSurvey(Ref ref) {
  return ref.watch(surveyTriggerServiceProvider).nextDueSurvey();
}
