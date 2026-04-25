import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

class OwnerMoodCard extends StatelessWidget {
  const OwnerMoodCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? OwnerColors.actionPrimary : OwnerColors.bgSurface;
    final fg = selected ? OwnerColors.textOnAction : OwnerColors.textPrimary;
    final border = selected
        ? Border.all(color: OwnerColors.actionPrimary, width: 1.5)
        : Border.all(color: OwnerColors.borderDefault, width: 0.5);

    return AspectRatio(
      aspectRatio: 1 / 1.2,
      child: Material(
        color: bg,
        borderRadius: OwnerRadius.radiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: OwnerRadius.radiusLg,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: OwnerRadius.radiusLg,
              border: border,
            ),
            padding: const EdgeInsets.all(OwnerSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: OwnerSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: OwnerTypography.caption.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
