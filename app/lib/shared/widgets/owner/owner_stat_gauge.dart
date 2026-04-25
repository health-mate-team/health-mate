import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

class OwnerStatGauge extends StatelessWidget {
  const OwnerStatGauge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  }) : assert(value >= 0 && value <= 100);

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OwnerSpacing.md),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusLg,
        border: Border.all(
          color: emphasized ? color : OwnerColors.borderDefault,
          width: emphasized ? 2 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: OwnerIconSize.lg, color: color),
          const SizedBox(height: OwnerSpacing.xs),
          Text(label, style: OwnerTypography.caption),
          const SizedBox(height: OwnerSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: OwnerMotion.slow,
              curve: OwnerMotion.standard,
              builder: (context, t, child) {
                return LinearProgressIndicator(
                  value: t,
                  minHeight: 4,
                  backgroundColor: OwnerColors.beige100,
                  color: color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
