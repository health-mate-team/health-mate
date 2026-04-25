import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

/// 온보딩·풀스크린 모멘트용 세그먼트 진행 바
class OwnerStoryProgressBar extends StatelessWidget {
  const OwnerStoryProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  })  : assert(totalSteps > 0),
        assert(currentStep >= 1 && currentStep <= totalSteps);

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final filled = i < currentStep;
        final isLast = i == totalSteps - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isLast ? 0 : OwnerSpacing.xs,
            ),
            child: AnimatedContainer(
              duration: OwnerMotion.fast,
              curve: OwnerMotion.standard,
              height: 3,
              decoration: BoxDecoration(
                color: filled ? OwnerColors.coral100 : OwnerColors.coral50,
                borderRadius: OwnerRadius.radiusFull,
              ),
            ),
          ),
        );
      }),
    );
  }
}
