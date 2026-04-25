import 'package:flutter/material.dart';
import 'package:health_mate/shared/constants/mascot_constants.dart';

/// 목업 명세의 표정 id와 대응 (자산 부족 시 가장 가까운 일러스트로 폴백)
enum OwnerMoaExpression {
  default_,
  happy,
  sleepy,
  surprised,
  starEyes,
  wink,
  determined,
  sad,
  waving,
}

class OwnerMoaAvatar extends StatefulWidget {
  const OwnerMoaAvatar({
    super.key,
    required this.size,
    this.expression = OwnerMoaExpression.default_,
    this.breathingAnimation = true,
  });

  final double size;
  final OwnerMoaExpression expression;
  final bool breathingAnimation;

  @override
  State<OwnerMoaAvatar> createState() => _OwnerMoaAvatarState();
}

class _OwnerMoaAvatarState extends State<OwnerMoaAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  static String _assetFor(OwnerMoaExpression e) {
    switch (e) {
      case OwnerMoaExpression.sleepy:
        return MascotConstants.moaAlternate;
      case OwnerMoaExpression.sad:
      case OwnerMoaExpression.determined:
        return MascotConstants.moaDefault;
      case OwnerMoaExpression.happy:
      case OwnerMoaExpression.waving:
      case OwnerMoaExpression.wink:
      case OwnerMoaExpression.starEyes:
      case OwnerMoaExpression.surprised:
      case OwnerMoaExpression.default_:
        return MascotConstants.moaDefault;
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
  void didUpdateWidget(covariant OwnerMoaAvatar oldWidget) {
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
        return Transform.scale(
          scale: scale,
          child: child,
        );
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
