import 'package:flutter/material.dart';
import 'owner_colors.dart';
import 'owner_typography.dart';
import 'owner_tokens.dart';

/// 오우너 스탯 게이지 (에너지/수분/휴식)
///
/// 0-100 값을 받아 게이지 바 + 아이콘 + 레이블로 표시.
/// 값 변화 시 자동 애니메이션 (motion.slow + standard curve).
class OwnerStatGauge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value; // 0-100
  final Color color;
  final bool emphasized; // 낮은 스탯일 때 강조

  const OwnerStatGauge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OwnerSpacing.md),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusLg,
        border: Border.all(
          color: emphasized ? color : OwnerColors.borderDefault,
          width: emphasized ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: OwnerIconSize.lg, color: color),
          const SizedBox(height: OwnerSpacing.xs),
          Text(
            label,
            style: OwnerTypography.caption.copyWith(
              color: emphasized ? color : OwnerColors.textSecondary,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: OwnerSpacing.sm),
          // 게이지 바
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 4,
              color: OwnerColors.beige100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value / 100),
                duration: OwnerMotion.slow,
                curve: OwnerMotion.standard,
                builder: (context, fraction, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction.clamp(0.0, 1.0),
                    child: Container(color: color),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
