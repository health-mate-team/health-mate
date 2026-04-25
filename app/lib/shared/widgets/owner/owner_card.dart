import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

enum OwnerCardVariant { surface, elevated, hero }

class OwnerCard extends StatelessWidget {
  const OwnerCard({
    super.key,
    required this.child,
    this.variant = OwnerCardVariant.surface,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final OwnerCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding =
        padding ?? OwnerSpacing.cardDefault;

    switch (variant) {
      case OwnerCardVariant.surface:
        final surface = Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: OwnerColors.bgSurface,
            borderRadius: OwnerRadius.radiusLg,
            border: Border.all(
              color: OwnerColors.borderDefault,
              width: 0.5,
            ),
          ),
          child: child,
        );
        if (onTap == null) return surface;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: OwnerRadius.radiusLg,
            child: surface,
          ),
        );
      case OwnerCardVariant.elevated:
        final elevated = Container(
          padding: effectivePadding,
          decoration: const BoxDecoration(
            color: OwnerColors.bgElevated,
            borderRadius: OwnerRadius.radiusLg,
          ),
          child: child,
        );
        if (onTap == null) return elevated;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: OwnerRadius.radiusLg,
            child: elevated,
          ),
        );
      case OwnerCardVariant.hero:
        final heroInner = DefaultTextStyle.merge(
          style: OwnerTypography.h3.copyWith(color: OwnerColors.textOnAction),
          child: IconTheme.merge(
            data: const IconThemeData(color: OwnerColors.textOnAction),
            child: child,
          ),
        );
        final hero = Container(
          padding: effectivePadding,
          decoration: const BoxDecoration(
            color: OwnerColors.actionPrimary,
            borderRadius: OwnerRadius.radiusLg,
          ),
          child: heroInner,
        );
        if (onTap == null) return hero;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: OwnerRadius.radiusLg,
            child: hero,
          ),
        );
    }
  }
}
