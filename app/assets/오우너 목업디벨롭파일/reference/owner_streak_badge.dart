import 'package:flutter/material.dart';
import '../theme/owner_colors.dart';
import '../theme/owner_typography.dart';
import '../theme/owner_tokens.dart';

/// 오우너 스트릭 배지 (연속 일수 표시)
///
/// 홈 화면 헤더에 표시되는 pill 모양 배지.
/// 불꽃 아이콘 + 연속 일수.
class OwnerStreakBadge extends StatelessWidget {
  final int days;

  const OwnerStreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusFull,
        border: Border.all(
          color: OwnerColors.borderDefault,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: OwnerIconSize.sm,
            color: OwnerColors.actionPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            '$days일',
            style: OwnerTypography.caption.copyWith(
              color: OwnerColors.textBrand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
