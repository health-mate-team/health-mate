import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

class OwnerStreakBadge extends StatelessWidget {
  const OwnerStreakBadge({
    super.key,
    required this.streakDays,
    this.compact = false,
  });

  final int streakDays;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: OwnerSpacing.sm,
        vertical: compact ? OwnerSpacing.xs : OwnerSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusFull,
        border: Border.all(color: OwnerColors.borderDefault, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: compact ? OwnerIconSize.sm : OwnerIconSize.md,
            color: OwnerColors.actionPrimary,
          ),
          const SizedBox(width: OwnerSpacing.xs),
          Text(
            '${streakDays}일',
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
