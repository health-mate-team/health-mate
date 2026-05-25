import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/codes/data/dto/code_dto.dart';
import 'package:health_mate/features/codes/domain/codes_provider.dart';
import 'package:health_mate/features/evening_ritual/data/dto/evening_dto.dart';
import 'package:health_mate/features/evening_ritual/data/evening_repository.dart';
import 'package:health_mate/features/home/domain/stats_provider.dart';
import 'package:health_mate/features/morning_ritual/domain/rituals_provider.dart';
import 'package:health_mate/shared/utils/test_widget_key.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 명세: [docs/design/owner-mock-develop/11_evening_ritual.json]
class EveningRitualPage extends ConsumerStatefulWidget {
  const EveningRitualPage({super.key});

  @override
  ConsumerState<EveningRitualPage> createState() => _EveningRitualPageState();
}

class _EveningRitualPageState extends ConsumerState<EveningRitualPage> {
  bool _promiseKept = false;
  String? _eveningMoodId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ritual = ref.read(ritualTodayProvider).valueOrNull;
      if (ritual != null && mounted) {
        setState(() => _promiseKept = ritual.promiseKept);
      }
    });
  }

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final req = EveningRitualRequest(promiseKept: _promiseKept);
      await ref.read(eveningRepositoryProvider).submitEvening(req);
      ref.invalidate(statsProvider);
      ref.invalidate(ritualTodayProvider);
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

  @override
  Widget build(BuildContext context) {
    final ritualAsync = ref.watch(ritualTodayProvider);
    final eveningMoodAsync = ref.watch(codeGroupProvider('evening_mood'));
    final isCompleted = ritualAsync.valueOrNull?.eveningCompleted ?? false;
    final promiseText = ritualAsync.valueOrNull?.morningPromise ??
        '오늘의 약속을 아직 정하지 않았어요';

    final borderSubtle = OwnerColors.white.withOpacity(0.15);
    final glassBg = OwnerColors.white.withOpacity(0.08);

    return Scaffold(
      backgroundColor: OwnerColors.cocoa800,
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OwnerSpacing.sm,
                  vertical: OwnerSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: OwnerColors.white.withOpacity(0.15),
                  borderRadius: OwnerRadius.radiusMd,
                ),
                child: Text(
                  '저녁 의식 · 2분',
                  style: OwnerTypography.overline.copyWith(
                    color: OwnerColors.coral100,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  0,
                  OwnerSpacing.base,
                  OwnerSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: OwnerSpacing.xl),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const OwnerMoaAvatar(
                          size: 140,
                          expression: OwnerMoaExpression.sleepy,
                        ),
                        Positioned(
                          top: -4,
                          right: 48,
                          child: Text(
                            'Z',
                            style: OwnerTypography.h3.copyWith(
                              color: OwnerColors.coral300,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 28,
                          child: Text(
                            'z',
                            style: OwnerTypography.body.copyWith(
                              color: OwnerColors.coral300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OwnerSpacing.xl),
                    Text(
                      '오늘 어땠어요?',
                      style: OwnerTypography.h1.copyWith(
                        color: OwnerColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OwnerSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.all(OwnerSpacing.lg),
                      decoration: BoxDecoration(
                        color: glassBg,
                        borderRadius: OwnerRadius.radiusXl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 약속',
                            style: OwnerTypography.overline.copyWith(
                              color: OwnerColors.coral100,
                            ),
                          ),
                          const SizedBox(height: OwnerSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              withTestId(
                                'evening-promise-checkbox',
                                OwnerCheckbox(
                                  checked: _promiseKept,
                                  onChanged: isCompleted
                                      ? null
                                      : (next) =>
                                          setState(() => _promiseKept = next),
                                ),
                              ),
                              const SizedBox(width: OwnerSpacing.sm),
                              Expanded(
                                child: Text(
                                  promiseText,
                                  style: OwnerTypography.body.copyWith(
                                    color: OwnerColors.white,
                                  ),
                                ),
                              ),
                              if (_promiseKept)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: OwnerSpacing.sm,
                                    vertical: OwnerSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: OwnerColors.accentSky
                                        .withOpacity(0.25),
                                    borderRadius: OwnerRadius.radiusMd,
                                  ),
                                  child: Text(
                                    '+60 XP',
                                    style: OwnerTypography.caption.copyWith(
                                      color: OwnerColors.accentSky,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: OwnerSpacing.lg),
                          Divider(color: borderSubtle, height: 24),
                          Text(
                            '기분은?',
                            style: OwnerTypography.bodySm.copyWith(
                              color: OwnerColors.coral100,
                            ),
                          ),
                          const SizedBox(height: OwnerSpacing.md),
                          eveningMoodAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) =>
                                const Text('옵션을 불러오지 못했어요'),
                            data: (options) => Row(
                              children: [
                                for (var i = 0; i < options.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 6),
                                  Expanded(
                                    child: withTestId(
                                      'evening-mood-cell-$i',
                                      _EveningMoodCell(
                                        code: options[i],
                                        selected:
                                            _eveningMoodId == options[i].id,
                                        onTap: isCompleted
                                            ? null
                                            : () => setState(
                                                () => _eveningMoodId =
                                                    options[i].id,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                0,
                OwnerSpacing.base,
                OwnerSpacing.xxl,
              ),
              child: withTestId(
                'evening-finish-btn',
                OwnerButton(
                  label: isCompleted
                      ? '이미 완료했어요'
                      : (_submitting ? '저장 중...' : '오늘 마무리'),
                  onPressed:
                      (isCompleted || _eveningMoodId == null || _submitting)
                          ? null
                          : _finish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EveningMoodCell extends StatelessWidget {
  const _EveningMoodCell({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final CodeDto code;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? OwnerColors.actionPrimary
          : OwnerColors.white.withOpacity(0.1),
      borderRadius: OwnerRadius.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: OwnerRadius.radiusLg,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code.emoji ?? '',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                code.labelKo,
                style: OwnerTypography.caption.copyWith(
                  color: OwnerColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
