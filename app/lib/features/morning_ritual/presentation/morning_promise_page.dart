import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/morning_ritual/domain/rituals_provider.dart';
import 'package:health_mate/shared/utils/test_widget_key.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

OwnerMoaExpression _expressionForMood(int? mood) {
  if (mood == null) return OwnerMoaExpression.default_;
  if (mood >= 4) return OwnerMoaExpression.happy;
  if (mood <= 2) return OwnerMoaExpression.sleepy;
  return OwnerMoaExpression.default_;
}

String _speechForMood(int? mood) {
  if (mood == null) return '오늘도 작은 약속 하나만 정해봐요';
  if (mood >= 5) return '오늘 컨디션 좋네요! 기분 좋게 도전해봐요 ✨';
  if (mood >= 3) return '보통이군요. 오늘은 가볍게 해봐요!';
  if (mood == 2) return '조금 피곤하시군요. 천천히 갈게요';
  return '오늘은 무리하지 말고 쉬어요';
}

class MorningPromisePage extends ConsumerStatefulWidget {
  const MorningPromisePage({super.key});

  @override
  ConsumerState<MorningPromisePage> createState() => _MorningPromisePageState();
}

class _PromiseOption {
  const _PromiseOption({required this.id, required this.text});
  final String id;
  final String text;
}

class _MorningPromisePageState extends ConsumerState<MorningPromisePage> {
  String? _selectedId;
  bool _submitting = false;

  static const _alternatives = <_PromiseOption>[
    _PromiseOption(id: 'stairs', text: '계단 한 층 오르내리기'),
    _PromiseOption(id: 'breathing', text: '창문 열고 심호흡 1분'),
    _PromiseOption(id: 'music', text: '좋아하는 음악 한 곡 듣기'),
  ];

  @override
  Widget build(BuildContext context) {
    final ritualAsync = ref.watch(ritualTodayProvider);

    return ritualAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (ritual) {
        final mood = ritual.morningMood;
        final selectedText = _selectedId == null
            ? null
            : _alternatives.firstWhere((o) => o.id == _selectedId).text;
        final promise = selectedText ?? ritual.morningPromise ?? '오늘 딱 하나, 작은 약속';
        final speech = _speechForMood(mood);
        final moaExpr = _expressionForMood(mood);

        return Scaffold(
          backgroundColor: OwnerColors.coral100,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OwnerSpacing.base,
                    OwnerSpacing.xl,
                    OwnerSpacing.base,
                    0,
                  ),
                  child: Text('오늘의 약속', style: OwnerTypography.overline),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OwnerSpacing.base,
                    OwnerSpacing.lg,
                    OwnerSpacing.base,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OwnerMoaAvatar(size: 60, expression: moaExpr),
                      const SizedBox(width: OwnerSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(OwnerSpacing.md),
                          decoration: BoxDecoration(
                            color: OwnerColors.bgSurface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(OwnerRadius.lg),
                              bottomLeft: Radius.circular(OwnerRadius.lg),
                              bottomRight: Radius.circular(OwnerRadius.lg),
                            ),
                            border: Border.all(color: OwnerColors.borderDefault),
                          ),
                          child: Text(
                            speech,
                            style: OwnerTypography.bodySm.copyWith(
                              color: OwnerColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OwnerSpacing.base,
                    OwnerSpacing.base,
                    OwnerSpacing.base,
                    0,
                  ),
                  child: OwnerCard(
                    variant: OwnerCardVariant.surface,
                    padding: const EdgeInsets.all(OwnerSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('오늘 딱 하나만', style: OwnerTypography.overline),
                        const SizedBox(height: OwnerSpacing.md),
                        withTestId('morning-promise-text',
                            Text(promise, style: OwnerTypography.h2)),
                        const SizedBox(height: OwnerSpacing.lg),
                        withTestId(
                          'morning-promise-commit-btn',
                          OwnerButton(
                            label: _submitting ? '저장 중...' : '약속할게요',
                            onPressed: _submitting ? null : () => _commit(promise),
                          ),
                        ),
                        const SizedBox(height: OwnerSpacing.sm),
                        Center(
                          child: withTestId(
                            'morning-promise-change-btn',
                            OwnerButton(
                              label: '다른 걸로 바꾸기',
                              variant: OwnerButtonVariant.text,
                              fullWidth: false,
                              onPressed: _submitting
                                  ? null
                                  : () => _showAlternatives(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _commit(String promise) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(ritualTodayProvider.notifier).submitPromise(promise);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했어요: $e')),
      );
      setState(() => _submitting = false);
    }
  }

  Future<void> _showAlternatives(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: OwnerColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: OwnerRadius.sheetTop,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(OwnerSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('다른 약속 고르기', style: OwnerTypography.h3),
                const SizedBox(height: OwnerSpacing.md),
                for (final alt in _alternatives)
                  ListTile(
                    title: Text(alt.text, style: OwnerTypography.body),
                    selected: _selectedId == alt.id,
                    onTap: () {
                      setState(() => _selectedId = alt.id);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
