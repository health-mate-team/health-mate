import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

enum OwnerChipVariant { default_, info, success, warning }

class OwnerChip extends StatelessWidget {
  /// README v1.1의 `defaultStyle` 네이밍과 동일 의미 ([OwnerChipVariant.default_]).
  static const OwnerChipVariant defaultStyle = OwnerChipVariant.default_;

  const OwnerChip({
    super.key,
    required this.label,
    this.variant = OwnerChipVariant.default_,
  });

  final String label;
  final OwnerChipVariant variant;

  (Color bg, Color fg) _colors() {
    switch (variant) {
      case OwnerChipVariant.default_:
        return (OwnerColors.coral50, OwnerColors.textBrand);
      case OwnerChipVariant.info:
        return (
          OwnerColors.accentSky.withOpacity(0.2),
          OwnerColors.accentSky,
        );
      case OwnerChipVariant.success:
        return (
          OwnerColors.accentMint.withOpacity(0.2),
          OwnerColors.accentMint,
        );
      case OwnerChipVariant.warning:
        return (
          OwnerColors.accentOrange.withOpacity(0.2),
          OwnerColors.accentOrange,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.sm,
        vertical: OwnerSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: OwnerRadius.radiusMd,
      ),
      child: Text(
        label,
        style: OwnerTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
