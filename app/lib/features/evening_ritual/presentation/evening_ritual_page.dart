import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 명세: [docs/design/owner-mock-develop/11_evening_ritual.json]
/// 사이클 단계가 활성이면 단계 라벨 + 수면 권장 시간을 함께 표시.
class EveningRitualPage extends ConsumerStatefulWidget {
  const EveningRitualPage({super.key});

  @override
  ConsumerState<EveningRitualPage> createState() => _EveningRitualPageState();
}

class _EveningRitualPageState extends ConsumerState<EveningRitualPage> {
  bool _promiseKept = false;
  String? _eveningMood;
  String _promiseText = '오늘의 약속을 아직 정하지 않았어요';
  int _promiseXp = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final text = prefs.getString(OwnerPrefsKeys.todayPromiseText);
    final xp = prefs.getInt(OwnerPrefsKeys.todayPromiseRewardXp);
    final done = prefs.getBool(OwnerPrefsKeys.todayPromiseCompleted);
    setState(() {
      if (text != null && text.isNotEmpty) {
        _promiseText = text;
      }
      if (xp != null) {
        _promiseXp = xp;
      }
      if (done != null) {
        _promiseKept = done;
      }
    });
  }

  Future<void> _persistPromiseDone(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OwnerPrefsKeys.todayPromiseCompleted, v);
  }

  Future<void> _finish() async {
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final borderSubtle = OwnerColors.white.withOpacity(0.15);
    final glassBg = OwnerColors.white.withOpacity(0.08);
    final cycle = ref.watch(computedStateNotifierProvider);
    final cycleLabel = cycle == null
        ? null
        : '${cycle.phase.koreanName} ${cycle.dayOfCycle}일차 · 수면 ${kPhaseProfiles[cycle.phase]!.sleepTargetHours}시간';

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
              child: Wrap(
                spacing: OwnerSpacing.xs,
                runSpacing: OwnerSpacing.xs,
                children: [
                  Container(
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
                  if (cycleLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OwnerSpacing.sm,
                        vertical: OwnerSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: kPhaseProfiles[cycle!.phase]!
                            .colorToken
                            .withValues(alpha: 0.25),
                        borderRadius: OwnerRadius.radiusMd,
                      ),
                      child: Text(
                        '${cycle.phase.emoji} $cycleLabel',
                        style: OwnerTypography.overline.copyWith(
                          color: OwnerColors.white,
                        ),
                      ),
                    ),
                ],
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
                              OwnerCheckbox(
                                checked: _promiseKept,
                                onChanged: (next) {
                                  setState(() => _promiseKept = next);
                                  _persistPromiseDone(next);
                                },
                              ),
                              const SizedBox(width: OwnerSpacing.sm),
                              Expanded(
                                child: Text(
                                  _promiseText,
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
                                    '+$_promiseXp',
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
                          Row(
                            children: [
                              for (var i = 0; i < _eveningOptions.length; i++) ...[
                                if (i > 0) const SizedBox(width: 6),
                                Expanded(
                                  child: _EveningMoodCell(
                                    emoji: _eveningOptions[i].emoji,
                                    label: _eveningOptions[i].label,
                                    selected:
                                        _eveningMood == _eveningOptions[i].id,
                                    onTap: () => setState(
                                      () => _eveningMood =
                                          _eveningOptions[i].id,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
              child: OwnerButton(
                label: '오늘 마무리',
                onPressed: _eveningMood != null ? _finish : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _eveningOptions = <({String id, String emoji, String label})>[
  (id: 'calm', emoji: '😌', label: '평온'),
  (id: 'happy', emoji: '😊', label: '기쁨'),
  (id: 'strong', emoji: '💪', label: '뿌듯'),
  (id: 'tired', emoji: '😮‍💨', label: '지침'),
];

class _EveningMoodCell extends StatelessWidget {
  const _EveningMoodCell({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
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
