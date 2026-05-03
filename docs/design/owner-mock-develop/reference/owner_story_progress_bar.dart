import 'package:flutter/material.dart';
import 'owner_colors.dart';
import 'owner_tokens.dart';

/// 오우너 스토리 진행 바
///
/// 온보딩, 풀스크린 모멘트의 스텝 표시.
/// 인스타 스토리식 세그먼트 바 디자인.
class OwnerStoryProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-indexed

  const OwnerStoryProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i < totalSteps - 1 ? OwnerSpacing.xs : 0,
            ),
            child: AnimatedContainer(
              duration: OwnerMotion.base,
              curve: OwnerMotion.standard,
              height: 3,
              decoration: BoxDecoration(
                color: isActive
                    ? OwnerColors.coral500
                    : OwnerColors.coral100.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
