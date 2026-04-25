import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

/// 오우너 버튼 (primary / secondary / text)
enum OwnerButtonVariant { primary, secondary, text }

class OwnerButton extends StatelessWidget {
  const OwnerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OwnerButtonVariant.primary,
    this.fullWidth = true,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final OwnerButtonVariant variant;
  final bool fullWidth;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;

    switch (variant) {
      case OwnerButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: 52,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: OwnerColors.textOnAction,
                    ),
                  )
                : _labeledRow(
                    icon: icon,
                    label: label,
                    iconColor: OwnerColors.textOnAction,
                    style: OwnerTypography.button,
                  ),
          ),
        );
      case OwnerButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: 52,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: OwnerColors.actionPrimary,
              side: const BorderSide(
                color: OwnerColors.actionPrimary,
                width: 1.5,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: OwnerRadius.radiusLg,
              ),
              padding: OwnerSpacing.buttonDefault,
            ),
            child: _labeledRow(
              icon: icon,
              label: label,
              iconColor: OwnerColors.actionPrimary,
              style: OwnerTypography.button.copyWith(
                color: OwnerColors.actionPrimary,
              ),
            ),
          ),
        );
      case OwnerButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          child: _labeledRow(
            icon: icon,
            label: label,
            iconColor: OwnerColors.textSecondary,
            style: OwnerTypography.bodySm.copyWith(
              color: OwnerColors.textSecondary,
            ),
          ),
        );
    }
  }

  static Widget _labeledRow({
    required IconData? icon,
    required String label,
    required Color iconColor,
    required TextStyle style,
  }) {
    if (icon == null) {
      return Text(label, style: style);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: OwnerSpacing.sm),
        Text(label, style: style),
      ],
    );
  }
}
