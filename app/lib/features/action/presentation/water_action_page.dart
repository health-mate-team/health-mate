import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/action/presentation/water_action_result.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 명세: [오우너 목업디벨롭파일/09_action_water.json] — 시트형 레이아웃을 풀스크린에 맞춤.
class WaterActionPage extends StatefulWidget {
  const WaterActionPage({super.key});

  @override
  State<WaterActionPage> createState() => _WaterActionPageState();
}

class _WaterActionPageState extends State<WaterActionPage> {
  int _sessionAdded = 0;
  int _cupsBeforeSession = 0;
  bool _justDrank = false;

  @override
  void initState() {
    super.initState();
    // TODO(offline): SharedPreferences로 일일 잔 수 복원 시 _cupsBeforeSession에 반영
  }

  int get _displayCups =>
      (_cupsBeforeSession + _sessionAdded).clamp(0, 8);

  String _feedbackText() {
    final n = _displayCups;
    if (n == 0) return '한 잔씩 기록해요';
    if (n == 1) return '좋은 시작이에요';
    if (n >= 8) return '오늘 목표 달성! 모아가 촉촉해졌어요';
    if (n >= 4) return '잘 챙기고 계세요!';
    return '물 한 잔 더 마셨어요';
  }

  OwnerMoaExpression get _moaExpr {
    if (_justDrank) return OwnerMoaExpression.happy;
    return OwnerMoaExpression.default_;
  }

  Future<void> _afterDrinkPulse() async {
    setState(() => _justDrank = true);
    await Future<void>.delayed(OwnerMotion.character);
    if (mounted) setState(() => _justDrank = false);
  }

  void _addCup() {
    if (_displayCups >= 8) return;
    setState(() => _sessionAdded++);
    _afterDrinkPulse();
  }

  void _close() {
    context.pop(WaterActionResult(glassesAdded: _sessionAdded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgScrim,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: OwnerColors.bgSurface,
            borderRadius: OwnerRadius.sheetTop,
            child: Padding(
              padding: const EdgeInsets.only(bottom: OwnerSpacing.base),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: OwnerSpacing.md),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: OwnerColors.coral100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OwnerSpacing.base,
                      OwnerSpacing.xl,
                      OwnerSpacing.base,
                      0,
                    ),
                    child: Text('오늘 마신 물', style: OwnerTypography.h2),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OwnerSpacing.base,
                      OwnerSpacing.lg,
                      OwnerSpacing.base,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(OwnerSpacing.lg),
                      decoration: BoxDecoration(
                        color: OwnerColors.bgPrimary,
                        borderRadius: OwnerRadius.radiusLg,
                      ),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                            ),
                            itemCount: 8,
                            itemBuilder: (context, i) {
                              final filled = i < _displayCups;
                              return Icon(
                                Icons.water_drop_rounded,
                                size: 28,
                                color: filled
                                    ? OwnerColors.statHydration
                                    : OwnerColors.coral100,
                              );
                            },
                          ),
                          const SizedBox(height: OwnerSpacing.md),
                          Text(
                            '$_displayCups / 8잔',
                            style: OwnerTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OwnerSpacing.base,
                      OwnerSpacing.lg,
                      OwnerSpacing.base,
                      0,
                    ),
                    child: Center(
                      child: OwnerMoaAvatar(
                        size: 100,
                        expression: _moaExpr,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OwnerSpacing.base,
                      OwnerSpacing.base,
                      OwnerSpacing.base,
                      0,
                    ),
                    child: Text(
                      _feedbackText(),
                      style: OwnerTypography.bodySm,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OwnerSpacing.base,
                      OwnerSpacing.lg,
                      OwnerSpacing.base,
                      OwnerSpacing.base,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OwnerButton(
                            label: '취소',
                            variant: OwnerButtonVariant.secondary,
                            onPressed: _close,
                          ),
                        ),
                        const SizedBox(width: OwnerSpacing.md),
                        Expanded(
                          flex: 2,
                          child: OwnerButton(
                            label: '+ 한 잔',
                            onPressed:
                                _displayCups >= 8 ? null : _addCup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
