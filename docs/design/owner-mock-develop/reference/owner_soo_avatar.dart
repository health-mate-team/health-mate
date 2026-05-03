import 'package:flutter/material.dart';
import 'owner_colors.dart';

/// 수 캐릭터 아바타 (검정 솜뭉치)
///
/// 모아의 0.6배 사이즈로 등장.
/// 보상, 미션, 챌린지 등 특별한 순간에만 사용.
enum SooExpression { defaultExpr, happy, starEyes, cheering }

class OwnerSooAvatar extends StatefulWidget {
  final double size;
  final SooExpression expression;
  final bool withStar;
  final bool breathingAnimation;

  const OwnerSooAvatar({
    super.key,
    this.size = 60,
    this.expression = SooExpression.defaultExpr,
    this.withStar = false,
    this.breathingAnimation = true,
  });

  @override
  State<OwnerSooAvatar> createState() => _OwnerSooAvatarState();
}

class _OwnerSooAvatarState extends State<OwnerSooAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    if (widget.breathingAnimation) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _SooPainter(
          expression: widget.expression,
          withStar: widget.withStar,
        ),
      ),
    );

    if (!widget.breathingAnimation) return base;

    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        final scale = 1.0 + (_breathController.value * 0.02);
        return Transform.scale(scale: scale, child: child);
      },
      child: base,
    );
  }
}

class _SooPainter extends CustomPainter {
  final SooExpression expression;
  final bool withStar;

  _SooPainter({required this.expression, required this.withStar});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 수 몸통 (검정)
    final bodyPaint = Paint()..color = OwnerColors.cocoa900;
    canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.55),
          width: w * 0.85,
          height: h * 0.8,
        ),
        bodyPaint);

    // 눈 (흰색)
    final eyeWhitePaint = Paint()..color = OwnerColors.white;
    final eyePaint = Paint()..color = OwnerColors.cocoa900;
    final eyeY = h * 0.5;
    final leftEyeX = w * 0.35;
    final rightEyeX = w * 0.65;
    final eyeRadius = w * 0.08;
    final pupilRadius = w * 0.04;

    canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, eyeWhitePaint);
    canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, eyeWhitePaint);

    // 표정별 동공
    switch (expression) {
      case SooExpression.starEyes:
        _drawStar(canvas, Offset(leftEyeX, eyeY), pupilRadius * 1.5,
            Paint()..color = OwnerColors.accentOrange);
        _drawStar(canvas, Offset(rightEyeX, eyeY), pupilRadius * 1.5,
            Paint()..color = OwnerColors.accentOrange);
        break;
      default:
        canvas.drawCircle(Offset(leftEyeX, eyeY), pupilRadius, eyePaint);
        canvas.drawCircle(Offset(rightEyeX, eyeY), pupilRadius, eyePaint);
    }

    // 별 소품 (옵션)
    if (withStar) {
      _drawStar(canvas, Offset(w * 0.85, h * 0.2), w * 0.08,
          Paint()..color = OwnerColors.accentOrange);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 36) * 3.14159 / 180 - 1.5708;
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * _cos(angle);
      final y = center.dy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => _table(rad, true);
  double _sin(double rad) => _table(rad, false);
  double _table(double rad, bool isCos) {
    // 간단 구현 — 실 프로덕션에선 dart:math 사용
    final x = rad;
    if (isCos) {
      return 1 - (x * x) / 2 + (x * x * x * x) / 24;
    }
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  @override
  bool shouldRepaint(_SooPainter old) =>
      old.expression != expression || old.withStar != withStar;
}
