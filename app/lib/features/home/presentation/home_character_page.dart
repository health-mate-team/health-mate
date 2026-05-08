import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/action/presentation/water_action_result.dart';
import 'package:health_mate/features/home/data/dto/stats_dto.dart';
import 'package:health_mate/features/home/domain/stats_provider.dart';
import 'package:health_mate/features/morning_ritual/data/dto/ritual_dto.dart';
import 'package:health_mate/features/morning_ritual/domain/rituals_provider.dart';
import 'package:health_mate/shared/utils/test_widget_key.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

class HomeCharacterPage extends ConsumerStatefulWidget {
  const HomeCharacterPage({super.key});

  @override
  ConsumerState<HomeCharacterPage> createState() => _HomeCharacterPageState();
}

class _HomeCharacterPageState extends ConsumerState<HomeCharacterPage> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);
    final ritualAsync = ref.watch(ritualTodayProvider);

    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(context, e),
          data: (stats) => _buildContent(context, stats, ritualAsync),
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

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const OwnerMoaAvatar(
            size: 120,
            expression: OwnerMoaExpression.sleepy,
          ),
          const SizedBox(height: OwnerSpacing.xl),
          Text('데이터를 불러오지 못했어요', style: OwnerTypography.body),
          const SizedBox(height: OwnerSpacing.md),
          OwnerButton(
            label: '다시 시도',
            onPressed: () => ref.invalidate(statsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StatsTodayDto stats,
    AsyncValue<RitualTodayDto> ritualAsync,
  ) {
    final energy = stats.energy;
    final hydration = stats.hydration;
    final rest = stats.rest;
    final displayName = '친구'; // TODO: users/me에서 가져오기

    final ritual = ritualAsync.valueOrNull;
    final promiseText = ritual?.morningPromise ?? '오늘의 약속을 아직 정하지 않았어요';
    final promiseDone = ritual?.promiseKept ?? false;

    return SingleChildScrollView(
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
                      '$displayName · Lv.${stats.level}',
                      style: OwnerTypography.h3,
                    ),
                  ],
                ),
                OwnerStreakBadge(streakDays: stats.streak),
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
                expression: _moodExpression(energy, hydration, rest),
              ),
            ],
          ),
          const SizedBox(height: OwnerSpacing.xl),
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
                  child: withTestId(
                    'home-water-btn',
                    OwnerQuickActionButton(
                      label: '+ 물 한 컵',
                      onPressed: () async {
                        final r = await context.push<WaterActionResult?>(
                          '/action/water',
                        );
                        if (r != null && r.glassesAdded > 0 && mounted) {
                          ref.invalidate(statsProvider);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: withTestId(
                    'home-walk-btn',
                    OwnerQuickActionButton(
                      label: '+ 산책',
                      onPressed: () async {
                        final ok = await context.push<bool>('/action/walk');
                        if (ok == true && mounted) {
                          ref.invalidate(statsProvider);
                        }
                      },
                    ),
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
                          promiseText,
                          style: OwnerTypography.h3,
                        ),
                      ),
                      OwnerCheckbox(
                        checked: promiseDone,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: OwnerSpacing.sm),
                  Row(
                    children: [
                      OwnerChip(label: '+${ritual?.xpEarned ?? 0} XP'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OwnerSpacing.xxl),
          withTestId(
            'home-morning-ritual-link',
            TextButton(
              onPressed: () => context.push('/morning/mood'),
              child: Text(
                '아침 의식',
                style: OwnerTypography.bodySm.copyWith(
                  color: OwnerColors.textSecondary,
                ),
              ),
            ),
          ),
          withTestId(
            'home-evening-ritual-link',
            TextButton(
              onPressed: () => context.push('/evening/ritual'),
              child: Text(
                '저녁 의식',
                style: OwnerTypography.bodySm.copyWith(
                  color: OwnerColors.textSecondary,
                ),
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
    );
  }

  OwnerMoaExpression _moodExpression(int energy, int hydration, int rest) {
    if (energy > 70 && hydration > 70 && rest > 70) {
      return OwnerMoaExpression.happy;
    }
    if (hydration < 40 || rest < 40) {
      return OwnerMoaExpression.sleepy;
    }
    return OwnerMoaExpression.default_;
  }
}
