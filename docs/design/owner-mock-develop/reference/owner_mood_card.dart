import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'owner_colors.dart';
import 'owner_typography.dart';
import 'owner_tokens.dart';

/// 오우너 무드 카드 (아침 의식 기분 선택)
///
/// 4개 그리드로 배치되는 정사각 카드.
/// 선택 시 코랄 배경 + 흰 텍스트.
class OwnerMoodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  const OwnerMoodCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: AnimatedContainer(
        duration: OwnerMotion.fast,
        curve: OwnerMotion.standard,
        padding: const EdgeInsets.symmetric(
          vertical: OwnerSpacing.base,
          horizontal: OwnerSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? OwnerColors.actionPrimary : OwnerColors.bgSurface,
          borderRadius: OwnerRadius.radiusLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              style: OwnerTypography.caption.copyWith(
                color:
                    selected ? OwnerColors.textOnAction : OwnerColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
