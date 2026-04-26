import 'package:flutter/material.dart';
import '../theme/owner_colors.dart';
import '../theme/owner_typography.dart';
import '../theme/owner_tokens.dart';

/// 오우너 칩 (메타 정보 표시용)
///
/// 변형: default / info / success / warning
enum OwnerChipVariant { defaultStyle, info, success, warning }

class OwnerChip extends StatelessWidget {
  final String label;
  final OwnerChipVariant variant;
  final IconData? icon;

  const OwnerChip({
    super.key,
    required this.label,
    this.variant = OwnerChipVariant.defaultStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _config();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.sm,
        vertical: OwnerSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: OwnerRadius.radiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: OwnerIconSize.sm, color: config.text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: OwnerTypography.caption.copyWith(
              color: config.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _ChipConfig _config() {
    return switch (variant) {
      OwnerChipVariant.defaultStyle => _ChipConfig(
          background: OwnerColors.chipDefaultBg,
          text: OwnerColors.chipDefaultText,
        ),
      OwnerChipVariant.info => _ChipConfig(
          background: OwnerColors.chipInfoBg,
          text: OwnerColors.chipInfoText,
        ),
      OwnerChipVariant.success => _ChipConfig(
          background: OwnerColors.chipSuccessBg,
          text: OwnerColors.chipSuccessText,
        ),
      OwnerChipVariant.warning => _ChipConfig(
          background: OwnerColors.chipWarningBg,
          text: OwnerColors.chipWarningText,
        ),
    };
  }
}

class _ChipConfig {
  final Color background;
  final Color text;
  _ChipConfig({required this.background, required this.text});
}
