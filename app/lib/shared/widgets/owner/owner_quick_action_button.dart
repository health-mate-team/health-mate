import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

class OwnerQuickActionButton extends StatelessWidget {
  const OwnerQuickActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OwnerColors.actionSecondary,
      borderRadius: OwnerRadius.radiusLg,
      child: InkWell(
        onTap: onPressed,
        borderRadius: OwnerRadius.radiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OwnerSpacing.sm,
            vertical: OwnerSpacing.base,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: OwnerTypography.caption.copyWith(
                color: OwnerColors.textBrand,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
