import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.md,
                OwnerSpacing.base,
                0,
              ),
              child: OwnerStoryProgressBar(
                totalSteps: 4,
                currentStep: 1,
              ),
            ),
            Expanded(
              child: Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const OwnerMoaAvatar(
                      size: 200,
                      expression: OwnerMoaExpression.waving,
                    ),
                    const SizedBox(height: OwnerSpacing.xxl),
                    Text(
                      '안녕! 나는 모아예요',
                      style: OwnerTypography.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OwnerSpacing.md),
                    Text(
                      '당신의 작은 약속을 지키는\n동반자가 되어줄게요',
                      style: OwnerTypography.body.copyWith(
                        color: OwnerColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
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
              child: Column(
                children: [
                  OwnerButton(
                    label: '시작할게요',
                    onPressed: () => context.go('/onboarding/name'),
                  ),
                  const SizedBox(height: OwnerSpacing.md),
                  Center(
                    child: OwnerButton(
                      label: '이미 계정이 있어요',
                      variant: OwnerButtonVariant.text,
                      fullWidth: false,
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
