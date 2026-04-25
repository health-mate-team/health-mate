import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

class OwnerCheckbox extends StatelessWidget {
  const OwnerCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: OwnerMotion.fast,
        curve: OwnerMotion.bouncy,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: checked ? OwnerColors.actionPrimary : OwnerColors.bgSurface,
          borderRadius: OwnerRadius.radiusSm,
          border: Border.all(
            color: checked ? OwnerColors.actionPrimary : OwnerColors.borderDefault,
            width: checked ? 2 : 1,
          ),
        ),
        child: checked
            ? const Icon(
                Icons.check,
                size: 18,
                color: OwnerColors.textOnAction,
              )
            : null,
      ),
    );
  }
}
