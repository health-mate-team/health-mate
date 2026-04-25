import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [오우너 목업디벨롭파일/04_onboarding_goal.json]
class _GoalOption {
  const _GoalOption({
    required this.id,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String icon;
  final Color accent;
  final String title;
  final String subtitle;
}

class OnboardingGoalPage extends StatefulWidget {
  const OnboardingGoalPage({super.key});

  @override
  State<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

class _OnboardingGoalPageState extends State<OnboardingGoalPage> {
  static const _goals = <_GoalOption>[
    _GoalOption(
      id: 'energy',
      icon: '⚡',
      accent: OwnerColors.statEnergy,
      title: '더 활기차게',
      subtitle: '에너지 넘치는 하루를 만들어요',
    ),
    _GoalOption(
      id: 'hydration',
      icon: '💧',
      accent: OwnerColors.statHydration,
      title: '건강한 습관',
      subtitle: '물 마시기, 식단 챙기기부터 차근차근',
    ),
    _GoalOption(
      id: 'rest',
      icon: '🌙',
      accent: OwnerColors.statRest,
      title: '잘 쉬고 싶어',
      subtitle: '충분한 수면과 회복에 집중해요',
    ),
    _GoalOption(
      id: 'shape',
      icon: '🌸',
      accent: OwnerColors.accentMint,
      title: '몸이 가벼워졌으면',
      subtitle: '꾸준한 운동과 식단 관리로 천천히',
    ),
  ];

  String? _selectedId;

  Future<void> _next() async {
    final id = _selectedId;
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OwnerPrefsKeys.goalId, id);
    if (!mounted) return;
    context.go('/onboarding/meet-moa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: OwnerSpacing.base,
                vertical: OwnerSpacing.md,
              ),
              child: OwnerStoryProgressBar(
                totalSteps: 4,
                currentStep: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.base,
                OwnerSpacing.base,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '어떤 변화를\n원하세요?',
                    style: OwnerTypography.h1,
                  ),
                  const SizedBox(height: OwnerSpacing.sm),
                  Text(
                    '지금 가장 마음에 드는 하나만 선택하세요',
                    style: OwnerTypography.bodySm,
                  ),
                ],
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: OwnerSpacing.base,
                ),
                itemCount: _goals.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: OwnerSpacing.md),
                itemBuilder: (context, i) {
                  final g = _goals[i];
                  final sel = _selectedId == g.id;
                  return _GoalListTile(
                    goal: g,
                    selected: sel,
                    onTap: () => setState(() => _selectedId = g.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.md,
                OwnerSpacing.base,
                OwnerSpacing.xxl,
              ),
              child: OwnerButton(
                label: '이걸로 시작할게요',
                onPressed: _selectedId != null ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalListTile extends StatelessWidget {
  const _GoalListTile({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final _GoalOption goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? OwnerColors.actionPrimary : OwnerColors.bgSurface;
    final titleStyle = OwnerTypography.h3.copyWith(
      color: selected ? OwnerColors.textOnAction : OwnerColors.textPrimary,
    );
    final subStyle = OwnerTypography.bodySm.copyWith(
      color: selected ? OwnerColors.textOnAction : OwnerColors.textSecondary,
    );

    return Material(
      color: bg,
      borderRadius: OwnerRadius.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: OwnerRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(OwnerSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: OwnerRadius.radiusLg,
            border: Border.all(
              color: selected
                  ? OwnerColors.actionPrimary
                  : OwnerColors.borderDefault,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: OwnerSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: titleStyle),
                    const SizedBox(height: OwnerSpacing.xs),
                    Text(goal.subtitle, style: subStyle),
                  ],
                ),
              ),
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: goal.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
