import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/action/presentation/water_action_result.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCharacterPage extends StatefulWidget {
  const HomeCharacterPage({super.key});

  @override
  State<HomeCharacterPage> createState() => _HomeCharacterPageState();
}

class _HomeCharacterPageState extends State<HomeCharacterPage> {
  static const _fallbackName = '친구';

  String _displayName = _fallbackName;
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
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final n = prefs.getString(OwnerPrefsKeys.displayName);
    final pt = prefs.getString(OwnerPrefsKeys.todayPromiseText);
    final st = prefs.getString(OwnerPrefsKeys.todayPromiseScheduledTime);
    final xp = prefs.getInt(OwnerPrefsKeys.todayPromiseRewardXp);
    final done = prefs.getBool(OwnerPrefsKeys.todayPromiseCompleted);
    setState(() {
      if (n != null && n.isNotEmpty) {
        _displayName = n;
      }
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

  OwnerMoaExpression get _expression {
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
                    const OwnerStreakBadge(streakDays: 7),
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
                    expression: _expression,
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
                      child: OwnerQuickActionButton(
                        label: '+ 물 한 컵',
                        onPressed: () async {
                          final r = await context.push<WaterActionResult?>(
                            '/action/water',
                          );
                          if (r != null &&
                              r.glassesAdded > 0 &&
                              mounted) {
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
                          final ok = await context.push<bool>(
                            '/action/walk',
                          );
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
