import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/survey/domain/entities/survey.dart';
import 'package:health_mate/features/survey/presentation/survey_providers.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 04_SUCCESS_METRICS.json measurement_window 의 D0/D14/D28 설문 화면.
/// 각 질문에 응답하면 즉시 `survey_response` 이벤트 송신.
/// 모든 질문 답변 후 markCompleted → 홈 복귀.
class SurveyPage extends ConsumerStatefulWidget {
  const SurveyPage({super.key, required this.surveyId});

  final SurveyId surveyId;

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  final Map<String, String> _answers = {};
  bool _submitting = false;

  SurveyDefinition get _def => kSurveyDefinitions[widget.surveyId]!;

  bool _allAnswered() {
    for (final q in _def.questions) {
      if ((_answers[q.id] ?? '').trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> _onAnswer(SurveyQuestion q, String value) async {
    setState(() => _answers[q.id] = value);
    final recorder = ref.read(analyticsRecorderProvider);
    unawaited(recorder.record(AnalyticsEvent.surveyResponse(
      surveyId: widget.surveyId.id,
      questionId: q.id,
      responseValue: value,
      ts: DateTime.now(),
    )));
  }

  Future<void> _submit() async {
    if (_submitting || !_allAnswered()) return;
    setState(() => _submitting = true);
    final trigger = ref.read(surveyTriggerServiceProvider);
    await trigger.markCompleted(widget.surveyId);
    // nextDueSurvey 캐시 무효화.
    ref.invalidate(nextDueSurveyProvider);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: OwnerColors.bgPrimary,
        elevation: 0,
        title: Text(_def.surveyId.title, style: OwnerTypography.h3),
        iconTheme: const IconThemeData(color: OwnerColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.md,
                OwnerSpacing.base,
                0,
              ),
              child: Text(
                _def.surveyId.subtitle,
                style: OwnerTypography.bodySm.copyWith(
                  color: OwnerColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(OwnerSpacing.base),
                itemCount: _def.questions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: OwnerSpacing.lg),
                itemBuilder: (context, i) {
                  final q = _def.questions[i];
                  return _QuestionTile(
                    question: q,
                    selected: _answers[q.id],
                    onAnswer: (v) => _onAnswer(q, v),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.md,
                OwnerSpacing.base,
                OwnerSpacing.lg,
              ),
              child: OwnerButton(
                label: '제출하기',
                onPressed: _allAnswered() && !_submitting ? _submit : null,
                loading: _submitting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.selected,
    required this.onAnswer,
  });

  final SurveyQuestion question;
  final String? selected;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: OwnerTypography.h3),
        const SizedBox(height: OwnerSpacing.md),
        switch (question.kind) {
          SurveyQuestionKind.likert5 => _LikertScale(
              labels: question.scaleLabels,
              max: 5,
              selected: int.tryParse(selected ?? ''),
              onSelect: (v) => onAnswer('$v'),
            ),
          SurveyQuestionKind.nps => _LikertScale(
              labels: question.scaleLabels,
              max: 11, // 0–10 = 11 칸
              startAt: 0,
              selected: int.tryParse(selected ?? ''),
              onSelect: (v) => onAnswer('$v'),
            ),
          SurveyQuestionKind.freeText => _FreeTextField(
              initial: selected,
              onCommit: onAnswer,
            ),
        },
      ],
    );
  }
}

class _LikertScale extends StatelessWidget {
  const _LikertScale({
    required this.max,
    required this.selected,
    required this.onSelect,
    this.labels,
    this.startAt = 1,
  });

  final int max;
  final int startAt;
  final int? selected;
  final ValueChanged<int> onSelect;
  final ({String low, String high})? labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var v = startAt; v < startAt + max; v++)
              _ScaleChip(
                value: v,
                selected: selected == v,
                onTap: () => onSelect(v),
              ),
          ],
        ),
        if (labels != null) ...[
          const SizedBox(height: OwnerSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels!.low,
                style: OwnerTypography.caption.copyWith(
                  color: OwnerColors.textSecondary,
                ),
              ),
              Text(
                labels!.high,
                style: OwnerTypography.caption.copyWith(
                  color: OwnerColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScaleChip extends StatelessWidget {
  const _ScaleChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? OwnerColors.actionPrimary : OwnerColors.bgSurface,
      borderRadius: OwnerRadius.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: OwnerRadius.radiusMd,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: OwnerRadius.radiusMd,
            border: Border.all(
              color: selected
                  ? OwnerColors.actionPrimary
                  : OwnerColors.borderDefault,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Text(
            '$value',
            style: OwnerTypography.body.copyWith(
              color: selected
                  ? OwnerColors.textOnAction
                  : OwnerColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeTextField extends StatefulWidget {
  const _FreeTextField({required this.initial, required this.onCommit});

  final String? initial;
  final ValueChanged<String> onCommit;

  @override
  State<_FreeTextField> createState() => _FreeTextFieldState();
}

class _FreeTextFieldState extends State<_FreeTextField> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctl,
      maxLines: 3,
      maxLength: 200,
      decoration: InputDecoration(
        hintText: '한 줄로 적어주세요',
        filled: true,
        fillColor: OwnerColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: OwnerRadius.radiusMd,
          borderSide: const BorderSide(color: OwnerColors.borderDefault),
        ),
      ),
      onChanged: (v) {
        if (v.trim().isNotEmpty) widget.onCommit(v);
      },
    );
  }
}
