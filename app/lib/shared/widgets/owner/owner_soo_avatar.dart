import 'package:flutter/material.dart';
import 'package:health_mate/shared/constants/mascot_constants.dart';

/// 수(Soo) 캐릭터 — 보상·미션 등 특별 순간용. 모아보다 작게 쓰는 것을 권장.
///
/// 표정별 에셋이 늘어나면 [SooExpression]에 맞춰 분기하면 됩니다.
enum SooExpression { defaultExpr, happy, starEyes, cheering }

class OwnerSooAvatar extends StatefulWidget {
  const OwnerSooAvatar({
    super.key,
    this.size = 60,
    this.expression = SooExpression.defaultExpr,
    this.breathingAnimation = true,
  });

  final double size;
  final SooExpression expression;
  final bool breathingAnimation;

  @override
  State<OwnerSooAvatar> createState() => _OwnerSooAvatarState();
}

class _OwnerSooAvatarState extends State<OwnerSooAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  static String _assetFor(SooExpression e) {
    switch (e) {
      case SooExpression.defaultExpr:
      case SooExpression.happy:
      case SooExpression.starEyes:
      case SooExpression.cheering:
        return MascotConstants.sooDefault;
    }
  }

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.breathingAnimation) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant OwnerSooAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathingAnimation != widget.breathingAnimation) {
      if (widget.breathingAnimation) {
        _breath.repeat(reverse: true);
      } else {
        _breath.stop();
        _breath.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetFor(widget.expression);
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final t = widget.breathingAnimation ? _breath.value : 0.0;
        final scale = 1.0 + 0.02 * t;
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
