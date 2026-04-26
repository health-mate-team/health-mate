import 'package:flutter/material.dart';
import '../theme/owner_colors.dart';
import '../theme/owner_typography.dart';
import '../theme/owner_tokens.dart';

/// 오우너 표준 버튼
///
/// 변형: primary / secondary / text
///
/// 사용법:
/// ```dart
/// OwnerButton(
///   variant: OwnerButtonVariant.primary,
///   label: '시작할게요',
///   fullWidth: true,
///   onPressed: () => ...,
/// )
/// ```
enum OwnerButtonVariant { primary, secondary, text }

class OwnerButton extends StatelessWidget {
  final OwnerButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool loading;
  final IconData? icon;

  const OwnerButton({
    super.key,
    this.variant = OwnerButtonVariant.primary,
    required this.label,
    this.onPressed,
    this.fullWidth = false,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    final Widget content = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(OwnerColors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: OwnerIconSize.md),
                const SizedBox(width: 8),
              ],
              Text(label, style: _textStyle()),
            ],
          );

    final Widget button = switch (variant) {
      OwnerButtonVariant.primary => _PrimaryButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        ),
      OwnerButtonVariant.secondary => _SecondaryButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        ),
      OwnerButtonVariant.text => _TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  TextStyle _textStyle() {
    return switch (variant) {
      OwnerButtonVariant.primary => OwnerTypography.button,
      OwnerButtonVariant.secondary =>
          OwnerTypography.button.copyWith(color: OwnerColors.actionPrimary),
      OwnerButtonVariant.text =>
          OwnerTypography.button.copyWith(color: OwnerColors.textSecondary),
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OwnerColors.actionPrimary,
          disabledBackgroundColor: OwnerColors.actionDisabled,
          padding: OwnerSpacing.buttonDefault,
          shape: const RoundedRectangleBorder(
            borderRadius: OwnerRadius.radiusLg,
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const _SecondaryButton({required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: OwnerSpacing.buttonDefault,
          side: const BorderSide(
            color: OwnerColors.actionPrimary,
            width: 1.5,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: OwnerRadius.radiusLg,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const _TextButton({required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: OwnerSpacing.buttonDefault,
        minimumSize: const Size(0, 44),
      ),
      child: child,
    );
  }
}
