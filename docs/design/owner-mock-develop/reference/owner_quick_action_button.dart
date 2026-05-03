import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'owner_colors.dart';
import 'owner_typography.dart';
import 'owner_tokens.dart';

/// 오우너 퀵 액션 버튼
///
/// 홈 화면의 즉시 액션 (물 한 컵, 산책, 식사 등)
/// 일반 버튼(52px)보다 작은 44px 높이.
class OwnerQuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  const OwnerQuickActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        emphasized ? OwnerColors.actionPrimary : OwnerColors.actionSecondary;
    final textColor =
        emphasized ? OwnerColors.textOnAction : OwnerColors.textBrand;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        borderRadius: OwnerRadius.radiusLg,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: OwnerSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: OwnerRadius.radiusLg,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: OwnerTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
