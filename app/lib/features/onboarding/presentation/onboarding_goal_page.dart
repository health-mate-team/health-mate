import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/codes/data/dto/code_dto.dart';
import 'package:health_mate/features/codes/domain/codes_provider.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [docs/design/owner-mock-develop/04_onboarding_goal.json]
class OnboardingGoalPage extends ConsumerStatefulWidget {
  const OnboardingGoalPage({super.key});

  @override
  ConsumerState<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

class _OnboardingGoalPageState extends ConsumerState<OnboardingGoalPage> {
  String? _selectedId;
  String? _selectedGoalType;

  Future<void> _next() async {
    final id = _selectedId;
    final goalType = _selectedGoalType;
    if (id == null || goalType == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OwnerPrefsKeys.goalId, id);
    await prefs.setString(OwnerPrefsKeys.goalType, goalType);
    if (!mounted) return;
    context.go('/onboarding/meet-moa');
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(codeGroupProvider('goal_option'));

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
              child: goalsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('목표 옵션을 불러오지 못했어요')),
                data: (options) => ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OwnerSpacing.base,
                  ),
                  itemCount: options.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: OwnerSpacing.md),
                  itemBuilder: (context, i) {
                    final g = options[i];
                    final sel = _selectedId == g.id;
                    return _GoalListTile(
                      code: g,
                      selected: sel,
                      onTap: () => setState(() {
                        _selectedId = g.id;
                        _selectedGoalType = g.metadata['goal_type'];
                      }),
                    );
                  },
                ),
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
                onPressed: (_selectedId != null && _selectedGoalType != null)
                    ? _next
                    : null,
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
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final CodeDto code;
  final bool selected;
  final VoidCallback onTap;

  static const _accentColorMap = <String, Color>{
    'statEnergy': OwnerColors.statEnergy,
    'statHydration': OwnerColors.statHydration,
    'statRest': OwnerColors.statRest,
    'accentMint': OwnerColors.accentMint,
  };

  @override
  Widget build(BuildContext context) {
    final bg = selected ? OwnerColors.actionPrimary : OwnerColors.bgSurface;
    final titleStyle = OwnerTypography.h3.copyWith(
      color: selected ? OwnerColors.textOnAction : OwnerColors.textPrimary,
    );
    final subStyle = OwnerTypography.bodySm.copyWith(
      color: selected ? OwnerColors.textOnAction : OwnerColors.textSecondary,
    );
    final accentKey = code.metadata['accent_color'] ?? '';
    final accentColor = _accentColorMap[accentKey] ?? OwnerColors.actionPrimary;
    final subtitle = code.metadata['subtitle'] ?? '';

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
              Text(
                code.emoji ?? '',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: OwnerSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(code.labelKo, style: titleStyle),
                    const SizedBox(height: OwnerSpacing.xs),
                    Text(subtitle, style: subStyle),
                  ],
                ),
              ),
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor,
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
