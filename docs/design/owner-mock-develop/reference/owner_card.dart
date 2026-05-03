import 'package:flutter/material.dart';
import 'owner_colors.dart';
import 'owner_tokens.dart';

/// 오우너 카드
///
/// 변형: surface(기본) / elevated(강조) / hero(CTA)
enum OwnerCardVariant { surface, elevated, hero }

class OwnerCard extends StatelessWidget {
  final OwnerCardVariant variant;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const OwnerCard({
    super.key,
    this.variant = OwnerCardVariant.surface,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _config();
    final radius = borderRadius ?? OwnerRadius.radiusLg;

    final container = Container(
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: radius,
        border: config.border,
      ),
      padding: padding ?? OwnerSpacing.cardDefault,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: container,
        ),
      );
    }
    return container;
  }

  _CardConfig _config() {
    return switch (variant) {
      OwnerCardVariant.surface => _CardConfig(
          background: OwnerColors.bgSurface,
          border: Border.all(color: OwnerColors.borderDefault, width: 0.5),
        ),
      OwnerCardVariant.elevated => _CardConfig(
          background: OwnerColors.bgElevated,
          border: null,
        ),
      OwnerCardVariant.hero => _CardConfig(
          background: OwnerColors.actionPrimary,
          border: null,
        ),
    };
  }
}

class _CardConfig {
  final Color background;
  final Border? border;
  _CardConfig({required this.background, this.border});
}
