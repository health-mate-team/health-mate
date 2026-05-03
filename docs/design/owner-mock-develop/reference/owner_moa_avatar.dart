import 'package:flutter/material.dart';
import 'owner_colors.dart';

/// 모아 캐릭터 아바타
///
/// 표정과 사이즈에 맞춰 모아를 렌더링.
/// 기본적으로 호흡 모션 적용 (살아있음 표현).
///
/// 실제 구현 시:
/// - SVG asset (flutter_svg) 또는 Lottie 사용 권장
/// - 표정별 자산을 expression enum으로 분기
/// - V1.0은 단순 SVG, V1.1+에서 Rive로 업그레이드 가능
enum MoaExpression {
  defaultExpr,
  happy,
  sleepy,
  sad,
  surprised,
  starEyes,
  wink,
  determined,
  waving,
}

enum MoaStage {
  sprout,   // 새싹 (Lv.1-2)
  small,    // 작은 (Lv.3-6)
  owner,    // 오우너 (Lv.7-14) ★ 기본
  shining,  // 빛나는 (Lv.15-29)
  master,   // 마스터 (Lv.30+)
}

class OwnerMoaAvatar extends StatefulWidget {
  final double size;
  final MoaExpression expression;
  final MoaStage stage;
  final bool breathingAnimation;
  final List<Widget>? floatingDecorations;

  const OwnerMoaAvatar({
    super.key,
    this.size = 100,
    this.expression = MoaExpression.defaultExpr,
    this.stage = MoaStage.owner,
    this.breathingAnimation = true,
    this.floatingDecorations,
  });

  @override
  State<OwnerMoaAvatar> createState() => _OwnerMoaAvatarState();
}

class _OwnerMoaAvatarState extends State<OwnerMoaAvatar>
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
        painter: _MoaPainter(
          expression: widget.expression,
          stage: widget.stage,
        ),
      ),
    );

    final animated = widget.breathingAnimation
        ? AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final scale = 1.0 + (_breathController.value * 0.02);
              return Transform.scale(scale: scale, child: child);
            },
            child: base,
          )
        : base;

    if (widget.floatingDecorations == null ||
        widget.floatingDecorations!.isEmpty) {
      return animated;
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [animated, ...widget.floatingDecorations!],
    );
  }
}

/// 임시 Painter — 실제 프로덕션에서는 SVG/Rive 자산으로 교체 권장
class _MoaPainter extends CustomPainter {
  final MoaExpression expression;
  final MoaStage stage;

  _MoaPainter({required this.expression, required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 모아 몸통 (베이지)
    final bodyPaint = Paint()..color = OwnerColors.beige300;
    final bodyPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.55),
        width: w * 0.85,
        height: h * 0.8,
      ));
    canvas.drawPath(bodyPath, bodyPaint);

    // 눈 (표정별 분기 - 단순화)
    final eyePaint = Paint()..color = OwnerColors.cocoa900;
    final eyeY = h * 0.5;
    final leftEyeX = w * 0.35;
    final rightEyeX = w * 0.65;
    final eyeRadius = w * 0.05;

    switch (expression) {
      case MoaExpression.sleepy:
        // 감긴 눈 (선)
        final strokePaint = Paint()
          ..color = OwnerColors.cocoa900
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(leftEyeX - eyeRadius, eyeY),
            Offset(leftEyeX + eyeRadius, eyeY),
            strokePaint);
        canvas.drawLine(
            Offset(rightEyeX - eyeRadius, eyeY),
            Offset(rightEyeX + eyeRadius, eyeY),
            strokePaint);
        break;
      case MoaExpression.happy:
        // 웃는 눈 (∩ 모양)
        final strokePaint = Paint()
          ..color = OwnerColors.cocoa900
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        final leftPath = Path()
          ..moveTo(leftEyeX - eyeRadius, eyeY + eyeRadius * 0.3)
          ..quadraticBezierTo(
              leftEyeX, eyeY - eyeRadius, leftEyeX + eyeRadius, eyeY + eyeRadius * 0.3);
        final rightPath = Path()
          ..moveTo(rightEyeX - eyeRadius, eyeY + eyeRadius * 0.3)
          ..quadraticBezierTo(
              rightEyeX, eyeY - eyeRadius, rightEyeX + eyeRadius, eyeY + eyeRadius * 0.3);
        canvas.drawPath(leftPath, strokePaint);
        canvas.drawPath(rightPath, strokePaint);
        break;
      default:
        // 기본 동그란 눈
        canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, eyePaint);
        canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, eyePaint);
    }

    // 볼터치 (코랄)
    final cheekPaint = Paint()
      ..color = OwnerColors.coral300.withValues(alpha: 0.55);
    canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.22, h * 0.62),
          width: w * 0.13,
          height: h * 0.06,
        ),
        cheekPaint);
    canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.78, h * 0.62),
          width: w * 0.13,
          height: h * 0.06,
        ),
        cheekPaint);

    // 입
    final mouthPaint = Paint()
      ..color = OwnerColors.coral900
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(w * 0.42, h * 0.68)
      ..quadraticBezierTo(w * 0.5, h * 0.74, w * 0.58, h * 0.68);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(_MoaPainter old) {
    return old.expression != expression || old.stage != stage;
  }
}
