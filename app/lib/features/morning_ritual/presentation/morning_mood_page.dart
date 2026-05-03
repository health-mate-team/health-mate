import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

class _MoodOption {
  const _MoodOption({
    required this.id,
    required this.emoji,
    required this.label,
    required this.score,
  });

  final String id;
  final String emoji;
  final String label;
  final int score; // OBS_02 자가 보고 에너지 매핑
}

class MorningMoodPage extends ConsumerStatefulWidget {
  const MorningMoodPage({super.key});

  @override
  ConsumerState<MorningMoodPage> createState() => _MorningMoodPageState();
}

class _MorningMoodPageState extends ConsumerState<MorningMoodPage>
    with SingleTickerProviderStateMixin {
  static const _options = <_MoodOption>[
    _MoodOption(id: 'great', emoji: '✨', label: '좋아요', score: 5),
    _MoodOption(id: 'okay', emoji: '☕', label: '보통', score: 3),
    _MoodOption(id: 'tired', emoji: '😴', label: '피곤', score: 2),
    _MoodOption(id: 'exhausted', emoji: '💧', label: '지침', score: 1),
  ];

  String? _selectedId;
  String _userName = '친구';
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    unawaited(_loadName());
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// 02_CYCLE_OS visual_indicators.locations[2]
  /// "황체기 22일차 — 컨디션 가라앉을 거예요" 같은 라벨.
  String? _cycleLabel(ComputedState? cycle) {
    if (cycle == null) return null;
    final phase = cycle.phase;
    final profile = kPhaseProfiles[phase]!;
    // 매일 다른 메시지: dayOfYear % messages.length 로 deterministic 선택
    final messages = profile.exampleMessages;
    final dayOfYear = _dayOfYear(DateTime.now());
    final msg = messages[dayOfYear % messages.length];
    return '${phase.koreanName} ${cycle.dayOfCycle}일차 — $msg';
  }

  static int _dayOfYear(DateTime d) {
    return int.parse(DateFormat('D').format(d));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.MMMEd('ko_KR').format(DateTime.now());
    final cycle = ref.watch(computedStateNotifierProvider);
    final cycleLabel = _cycleLabel(cycle);
    final moaExpression = cycle != null
        ? moaExpressionFor(cycle.phase, lutealSub: cycle.lutealSubPhase)
        : OwnerMoaExpression.happy;

    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '좋은 아침 · $dateLabel',
                    style: OwnerTypography.overline,
                  ),
                  if (cycleLabel != null) ...[
                    const SizedBox(height: OwnerSpacing.xs),
                    Text(
                      cycleLabel,
                      style: OwnerTypography.bodySm.copyWith(
                        color: kPhaseProfiles[cycle!.phase]!.colorToken,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = CurvedAnimation(
                        parent: _pulse,
                        curve: OwnerMotion.gentle,
                      ).value;
                      final scale = 0.95 + t * 0.1;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OwnerColors.coral300.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1),
                    duration: OwnerMotion.character,
                    curve: OwnerMotion.bouncy,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: OwnerMoaAvatar(
                      size: 160,
                      expression: moaExpression,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Padding(
              padding: OwnerSpacing.pageHorizontal,
              child: Text(
                '$_userName, 오늘 기분은\n어때요?',
                style: OwnerTypography.h1,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Expanded(
              child: Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: OwnerSpacing.sm,
                    mainAxisSpacing: OwnerSpacing.sm,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, i) {
                    final o = _options[i];
                    return OwnerMoodCard(
                      emoji: o.emoji,
                      label: o.label,
                      selected: _selectedId == o.id,
                      onTap: () => _onSelect(o, cycle),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString(OwnerPrefsKeys.displayName);
    if (!mounted) return;
    if (n != null && n.isNotEmpty) {
      setState(() => _userName = n);
    }
  }

  void _onSelect(_MoodOption option, ComputedState? cycle) {
    setState(() => _selectedId = option.id);
    final recorder = ref.read(analyticsRecorderProvider);
    unawaited(recorder.record(
      AnalyticsEvent.morningRitualCompleted(
        moodScore: option.score,
        energyScore: option.score,
        phase: cycle?.phase,
        dayOfCycle: cycle?.dayOfCycle,
        ts: DateTime.now(),
      ),
    ));
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () async {
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(OwnerPrefsKeys.morningMoodId, option.id);
        if (!mounted) return;
        context.go('/morning/promise');
      }),
    );
  }
}
