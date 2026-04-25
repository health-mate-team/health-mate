import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/owner_colors.dart';
import '../theme/owner_tokens.dart';

/// 오우너 체크박스 (약속/할일 완료용)
///
/// Material 기본보다 큰 28x28.
/// 체크 시 scale_bounce 모션.
class OwnerCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final double size;

  const OwnerCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onChanged!(!checked);
            },
      child: AnimatedContainer(
        duration: OwnerMotion.fast,
        curve: OwnerMotion.bouncy,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? OwnerColors.actionPrimary : OwnerColors.bgSurface,
          borderRadius: OwnerRadius.radiusSm,
          border: Border.all(
            color: checked
                ? OwnerColors.actionPrimary
                : OwnerColors.borderStrong,
            width: 1.5,
          ),
        ),
        child: AnimatedScale(
          scale: checked ? 1.0 : 0.0,
          duration: OwnerMotion.fast,
          curve: OwnerMotion.bouncy,
          child: Icon(
            Icons.check_rounded,
            color: OwnerColors.textOnAction,
            size: size * 0.7,
          ),
        ),
      ),
    );
  }
}
