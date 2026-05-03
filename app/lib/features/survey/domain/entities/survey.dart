/// 04_SUCCESS_METRICS.json measurement_window.checkpoint_dates 의 3개 설문.
/// 베타 등록일(D0) 기준 ±1일 윈도우 내에 트리거.
enum SurveyId {
  /// 베이스라인. KPI_01 의 baseline 점수 측정.
  baselineD0,
  /// 중간 펄스. OBS_03 수면 만족도 추세.
  pulseD14,
  /// 최종. KPI_01 endline + KPI_04 + KPI_05 + OBS_01 + 정성.
  finalD28,
}

extension SurveyIdMeta on SurveyId {
  String get id => switch (this) {
        SurveyId.baselineD0 => 'baseline_d0',
        SurveyId.pulseD14 => 'pulse_d14',
        SurveyId.finalD28 => 'final_d28',
      };

  /// 베타 등록일로부터 며칠차에 트리거되는지.
  int get targetDay => switch (this) {
        SurveyId.baselineD0 => 0,
        SurveyId.pulseD14 => 14,
        SurveyId.finalD28 => 28,
      };

  String get title => switch (this) {
        SurveyId.baselineD0 => '시작 전, 짧은 질문',
        SurveyId.pulseD14 => '2주째, 한 가지만',
        SurveyId.finalD28 => '4주 마무리, 짧은 정리',
      };

  String get subtitle => switch (this) {
        SurveyId.baselineD0 => '오우너를 어떻게 시작하는지 1문항으로 적어주세요',
        SurveyId.pulseD14 => '이번 주 어땠는지 한 줄만',
        SurveyId.finalD28 => '4주 사용 후 변화를 알려주세요',
      };
}

/// 한 설문 안의 한 질문.
class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.kind,
    this.scaleLabels,
  });

  final String id;
  final String text;
  final SurveyQuestionKind kind;

  /// 리커트 척도의 양 끝 라벨. (1점, 5점) 또는 (0점, 10점).
  final ({String low, String high})? scaleLabels;
}

enum SurveyQuestionKind {
  /// 1–5 리커트
  likert5,
  /// 0–10 NPS
  nps,
  /// 자유 응답 (정성 신호)
  freeText,
}

/// 한 설문의 정의.
class SurveyDefinition {
  const SurveyDefinition({
    required this.surveyId,
    required this.questions,
  });

  final SurveyId surveyId;
  final List<SurveyQuestion> questions;
}

/// 04_SUCCESS_METRICS.json 의 3개 설문 정의를 const 로.
const Map<SurveyId, SurveyDefinition> kSurveyDefinitions = {
  SurveyId.baselineD0: SurveyDefinition(
    surveyId: SurveyId.baselineD0,
    questions: [
      // KPI_01 baseline (question_baseline_day0)
      SurveyQuestion(
        id: 'cycle_understanding_baseline',
        text: '현재 본인의 호르몬 주기 4단계와 그 영향을 얼마나 이해하고 있나요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '전혀 모름', high: '잘 이해함'),
      ),
      // OBS_01 baseline
      SurveyQuestion(
        id: 'pms_impact_baseline',
        text: '지난 사이클의 PMS 증상이 일상에 얼마나 영향을 줬나요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '거의 없음', high: '매우 심함'),
      ),
    ],
  ),
  SurveyId.pulseD14: SurveyDefinition(
    surveyId: SurveyId.pulseD14,
    questions: [
      // OBS_03 수면 만족도 (3점 척도지만 5점으로 통합 운영)
      SurveyQuestion(
        id: 'sleep_satisfaction_pulse',
        text: '이번 주 수면은 어땠어요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '많이 부족', high: '아주 좋음'),
      ),
    ],
  ),
  SurveyId.finalD28: SurveyDefinition(
    surveyId: SurveyId.finalD28,
    questions: [
      // KPI_01 endline (question_endline_day28)
      SurveyQuestion(
        id: 'cycle_understanding_endline',
        text: '오우너 사용 후 본인의 호르몬 주기 4단계와 그 영향을 얼마나 이해하나요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '전혀 모름', high: '잘 이해함'),
      ),
      // KPI_04 자기 돌봄
      SurveyQuestion(
        id: 'self_care_endline',
        text: '오우너 사용 후 본인의 몸을 돌보는 능력이 향상됐다고 느끼시나요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '전혀 아님', high: '매우 그렇다'),
      ),
      // OBS_01 endline
      SurveyQuestion(
        id: 'pms_impact_endline',
        text: '이번 사이클의 PMS 증상이 일상에 얼마나 영향을 줬나요?',
        kind: SurveyQuestionKind.likert5,
        scaleLabels: (low: '거의 없음', high: '매우 심함'),
      ),
      // KPI_05 NPS
      SurveyQuestion(
        id: 'nps',
        text: '오우너를 친구에게 추천할 의향이 얼마나 있나요?',
        kind: SurveyQuestionKind.nps,
        scaleLabels: (low: '전혀', high: '매우 추천'),
      ),
      // 정성 — qualitative_signals.in_app_open_text
      SurveyQuestion(
        id: 'best_moment_open_text',
        text: '오우너에서 가장 좋았던 순간이 있다면 한 줄로 적어주세요',
        kind: SurveyQuestionKind.freeText,
      ),
    ],
  ),
};
