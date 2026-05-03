import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/action/presentation/water_action_result.dart';
import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/features/survey/domain/entities/survey.dart';
import 'package:health_mate/features/survey/presentation/survey_providers.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCharacterPage extends ConsumerStatefulWidget {
  const HomeCharacterPage({super.key});

  @override
  ConsumerState<HomeCharacterPage> createState() => _HomeCharacterPageState();
}

class _HomeCharacterPageState extends ConsumerState<HomeCharacterPage> {
  static const _fallbackName = '친구';

  String _displayName = _fallbackName;
  String? _goalId;
  String _promiseText = '저녁 먹고\n20분 산책하기';
  String _promiseTime = '저녁 8시';
  int _promiseXp = 50;
  int energy = 72;
  int hydration = 45;
  int rest = 68;
  bool promiseDone = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPrefs());
    _recordAppOpen();
    unawaited(_checkSurveyDue());
  }

  /// 04_SUCCESS_METRICS measurement_window 의 D0/D14/D28 ±1일 윈도우면 설문 화면으로 자동 이동.
  /// 같은 사용자가 D0 만 안 풀고 D14 가 트리거되면 D14 가 우선 (서비스의 우선순위 로직).
  Future<void> _checkSurveyDue() async {
    // 첫 프레임 이후로 미뤄야 GoRouter context 사용 가능.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final due = await ref.read(nextDueSurveyProvider.future);
    if (!mounted || due == null) return;
    unawaited(context.push('/survey/${due.id}'));
  }

  void _recordAppOpen() {
    final recorder = ref.read(analyticsRecorderProvider);
    recorder.record(AnalyticsEvent.appOpen(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      ts: DateTime.now(),
    ));
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final n = prefs.getString(OwnerPrefsKeys.displayName);
    final goal = prefs.getString(OwnerPrefsKeys.goalId);
    final pt = prefs.getString(OwnerPrefsKeys.todayPromiseText);
    final st = prefs.getString(OwnerPrefsKeys.todayPromiseScheduledTime);
    final xp = prefs.getInt(OwnerPrefsKeys.todayPromiseRewardXp);
    final done = prefs.getBool(OwnerPrefsKeys.todayPromiseCompleted);
    setState(() {
      if (n != null && n.isNotEmpty) {
        _displayName = n;
      }
      _goalId = goal;
      if (pt != null && pt.isNotEmpty) {
        _promiseText = pt;
      }
      if (st != null && st.isNotEmpty) {
        _promiseTime = st;
      }
      if (xp != null) {
        _promiseXp = xp;
      }
      if (done != null) {
        promiseDone = done;
      }
    });
  }

  void _onPromiseChecked(bool v) {
    setState(() => promiseDone = v);
    SharedPreferences.getInstance().then(
      (p) => p.setBool(OwnerPrefsKeys.todayPromiseCompleted, v),
    );
  }

  /// 사이클 OS 가 활성이면 phase 의 모아 표정을 우선 사용,
  /// 아니면 기존 stat 기반 fallback.
  OwnerMoaExpression _expression(ComputedState? cycle) {
    if (cycle != null) {
      return moaExpressionFor(cycle.phase, lutealSub: cycle.lutealSubPhase);
    }
    if (energy > 70 && hydration > 70 && rest > 70) {
      return OwnerMoaExpression.happy;
    }
    if (hydration < 40 || rest < 40) {
      return OwnerMoaExpression.sleepy;
    }
    return OwnerMoaExpression.default_;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(computedStateNotifierProvider);
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  OwnerSpacing.base,
                  OwnerSpacing.base,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('나의 오우너', style: OwnerTypography.overline),
                        const SizedBox(height: OwnerSpacing.xs),
                        Text(
                          '$_displayName · Lv.3',
                          style: OwnerTypography.h3,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (cycle != null) _CycleIndicator(state: cycle),
                        if (cycle != null) const SizedBox(height: OwnerSpacing.xs),
                        const OwnerStreakBadge(streakDays: 7),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (hydration < 40)
                    const Positioned(
                      top: 8,
                      right: 48,
                      child: Text('💧', style: TextStyle(fontSize: 22)),
                    ),
                  if (rest < 40)
                    const Positioned(
                      top: 8,
                      left: 48,
                      child: Text('💤', style: TextStyle(fontSize: 22)),
                    ),
                  OwnerMoaAvatar(
                    size: 220,
                    expression: _expression(cycle),
                  ),
                ],
              ),
              const SizedBox(height: OwnerSpacing.xl),
              if (cycle != null)
                Padding(
                  padding: OwnerSpacing.pageHorizontal,
                  child: _CycleRecommendationCard(state: cycle, userGoalId: _goalId),
                ),
              if (cycle != null) const SizedBox(height: OwnerSpacing.lg),
              Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: OwnerStatGauge(
                        icon: Icons.bolt_outlined,
                        label: '에너지',
                        value: energy,
                        color: OwnerColors.statEnergy,
                      ),
                    ),
                    const SizedBox(width: OwnerSpacing.sm),
                    Expanded(
                      child: OwnerStatGauge(
                        icon: Icons.water_drop_outlined,
                        label: '수분',
                        value: hydration,
                        color: OwnerColors.statHydration,
                      ),
                    ),
                    const SizedBox(width: OwnerSpacing.sm),
                    Expanded(
                      child: OwnerStatGauge(
                        icon: Icons.bedtime_outlined,
                        label: '휴식',
                        value: rest,
                        color: OwnerColors.statRest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OwnerSpacing.base),
              Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: OwnerQuickActionButton(
                        label: '+ 물 한 컵',
                        onPressed: () async {
                          final r = await context.push<WaterActionResult?>(
                            '/action/water',
                          );
                          if (r != null && r.glassesAdded > 0 && mounted) {
                            setState(() {
                              hydration = (hydration + r.glassesAdded * 8)
                                  .clamp(0, 100);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OwnerQuickActionButton(
                        label: '+ 산책',
                        onPressed: () async {
                          final ok = await context.push<bool>('/action/walk');
                          if (ok == true && mounted) {
                            setState(() {
                              energy = (energy + 8).clamp(0, 100);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OwnerQuickActionButton(
                        label: '+ 식사',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: OwnerCard(
                  variant: OwnerCardVariant.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('오늘의 약속', style: OwnerTypography.overline),
                      const SizedBox(height: OwnerSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _promiseText,
                              style: OwnerTypography.h3,
                            ),
                          ),
                          OwnerCheckbox(
                            checked: promiseDone,
                            onChanged: _onPromiseChecked,
                          ),
                        ],
                      ),
                      const SizedBox(height: OwnerSpacing.sm),
                      Row(
                        children: [
                          OwnerChip(label: _promiseTime),
                          const SizedBox(width: OwnerSpacing.sm),
                          OwnerChip(label: '+$_promiseXp XP'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: OwnerSpacing.xxl),
              TextButton(
                onPressed: () => context.push('/morning/mood'),
                child: Text(
                  '아침 의식(목업)',
                  style: OwnerTypography.bodySm.copyWith(
                    color: OwnerColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/evening/ritual'),
                child: Text(
                  '저녁 의식(목업)',
                  style: OwnerTypography.bodySm.copyWith(
                    color: OwnerColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/moment/evolution'),
                child: Text(
                  '진화 모멘트(목업)',
                  style: OwnerTypography.bodySm.copyWith(
                    color: OwnerColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: '리워드',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

/// 02_CYCLE_OS visual_indicators.locations[0]
/// "🍂 22/28" 식. 탭하면 사이클 캘린더로 이동.
class _CycleIndicator extends StatelessWidget {
  const _CycleIndicator({required this.state});

  final ComputedState state;

  @override
  Widget build(BuildContext context) {
    final profile = kPhaseProfiles[state.phase]!;
    final phaseEmoji = state.phase.emoji;
    return Material(
      color: profile.colorToken.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push('/cycle/calendar'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OwnerSpacing.sm,
            vertical: OwnerSpacing.xs,
          ),
          child: Text(
            // 28은 default. 정확한 cycleLength 는 캘린더 화면에서 보여줌.
            '$phaseEmoji ${state.dayOfCycle}/28',
            style: OwnerTypography.bodySm.copyWith(
              color: OwnerColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 사이클 OS 가 추천한 운동 카드.
/// recommendation_service 호출은 위젯 내부에서 한 번만.
class _CycleRecommendationCard extends ConsumerWidget {
  const _CycleRecommendationCard({required this.state, this.userGoalId});

  final ComputedState state;
  final String? userGoalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(recommendationServiceProvider);
    final result = service.recommendForToday(
      state: state,
      userGoalId: userGoalId,
    );
    if (result == null) return const SizedBox.shrink();
    final phaseProfile = kPhaseProfiles[state.phase]!;
    return OwnerCard(
      variant: OwnerCardVariant.surface,
      onTap: () => context.push('/cycle/workout/${result.workout.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(state.phase.emoji,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: OwnerSpacing.xs),
              Text(
                '${state.phase.koreanName} · ${state.dayOfCycle}일차',
                style: OwnerTypography.overline.copyWith(
                  color: phaseProfile.colorToken,
                ),
              ),
            ],
          ),
          const SizedBox(height: OwnerSpacing.sm),
          Text(result.workout.titleSuggestion, style: OwnerTypography.h3),
          const SizedBox(height: OwnerSpacing.xs),
          Text(
            result.rationale,
            style: OwnerTypography.bodySm.copyWith(
              color: OwnerColors.textSecondary,
            ),
          ),
          const SizedBox(height: OwnerSpacing.sm),
          Wrap(
            spacing: OwnerSpacing.xs,
            runSpacing: OwnerSpacing.xs,
            children: [
              OwnerChip(label: '${result.workout.durationSeconds ~/ 60}분'),
              OwnerChip(label: result.workout.workoutTypeKorean),
            ],
          ),
        ],
      ),
    );
  }
}
