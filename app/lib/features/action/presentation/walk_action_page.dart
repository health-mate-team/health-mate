import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 명세: [docs/design/owner-mock-develop/10_action_walk.json]
enum _WalkUiPhase { beforeStart, inProgress, completed }

int _xpForWalkSeconds(int seconds) {
  if (seconds < 300) return 5;
  if (seconds < 900) return 10;
  if (seconds < 1800) return 25;
  return 40;
}

class WalkActionPage extends StatefulWidget {
  const WalkActionPage({super.key});

  @override
  State<WalkActionPage> createState() => _WalkActionPageState();
}

class _WalkActionPageState extends State<WalkActionPage> {
  _WalkUiPhase _phase = _WalkUiPhase.beforeStart;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _phase = _WalkUiPhase.inProgress;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  void _endWalk() {
    _timer?.cancel();
    setState(() => _phase = _WalkUiPhase.completed);
  }

  void _confirmExit() {
    context.pop(true);
  }

  String get _timeLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _stepsStub => _seconds * 2;

  String get _distanceKmStub =>
      (_stepsStub * 0.0007).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: OwnerColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            context.pop(false);
          },
        ),
        title: Text('산책', style: OwnerTypography.h3),
      ),
      body: AnimatedSwitcher(
        duration: OwnerMotion.base,
        child: switch (_phase) {
          _WalkUiPhase.beforeStart => _BeforeStart(
              key: const ValueKey('before'),
              onStart: _start,
            ),
          _WalkUiPhase.inProgress => _InProgress(
              key: const ValueKey('during'),
              timeLabel: _timeLabel,
              steps: _stepsStub,
              distanceKm: _distanceKmStub,
              onEnd: _endWalk,
            ),
          _WalkUiPhase.completed => _Completed(
              key: const ValueKey('done'),
              timeLabel: _timeLabel,
              steps: _stepsStub,
              xp: _xpForWalkSeconds(_seconds),
              onOk: _confirmExit,
            ),
        },
      ),
    );
  }
}

class _BeforeStart extends StatelessWidget {
  const _BeforeStart({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OwnerSpacing.pageHorizontal,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const OwnerMoaAvatar(
            size: 140,
            expression: OwnerMoaExpression.happy,
          ),
          const SizedBox(height: OwnerSpacing.xl),
          Text(
            '준비됐어요?',
            style: OwnerTypography.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OwnerSpacing.sm),
          Text(
            '함께 걸으러 가요',
            style: OwnerTypography.bodySm,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          OwnerButton(label: '산책 시작', onPressed: onStart),
          const SizedBox(height: OwnerSpacing.xxl),
        ],
      ),
    );
  }
}

class _InProgress extends StatelessWidget {
  const _InProgress({
    super.key,
    required this.timeLabel,
    required this.steps,
    required this.distanceKm,
    required this.onEnd,
  });

  final String timeLabel;
  final int steps;
  final String distanceKm;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OwnerSpacing.pageHorizontal,
      child: Column(
        children: [
          const SizedBox(height: OwnerSpacing.lg),
          Text(
            '산책 중',
            style: OwnerTypography.overline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OwnerSpacing.sm),
          Text(
            timeLabel,
            style: OwnerTypography.displayXl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OwnerSpacing.xl),
          const OwnerMoaAvatar(
            size: 120,
            expression: OwnerMoaExpression.default_,
          ),
          const SizedBox(height: OwnerSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OwnerCard(
                  variant: OwnerCardVariant.surface,
                  child: Column(
                    children: [
                      Text('걸음', style: OwnerTypography.caption),
                      Text('$steps', style: OwnerTypography.h2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: OwnerSpacing.md),
              Expanded(
                child: OwnerCard(
                  variant: OwnerCardVariant.surface,
                  child: Column(
                    children: [
                      Text('거리', style: OwnerTypography.caption),
                      Text('${distanceKm}km', style: OwnerTypography.h2),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          OwnerButton(label: '산책 종료', onPressed: onEnd),
          const SizedBox(height: OwnerSpacing.xxl),
        ],
      ),
    );
  }
}

class _Completed extends StatelessWidget {
  const _Completed({
    super.key,
    required this.timeLabel,
    required this.steps,
    required this.xp,
    required this.onOk,
  });

  final String timeLabel;
  final int steps;
  final int xp;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OwnerSpacing.pageHorizontal,
      child: Column(
        children: [
          const SizedBox(height: OwnerSpacing.xl),
          Text(
            '잘했어요!',
            style: OwnerTypography.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OwnerSpacing.lg),
          const OwnerMoaAvatar(
            size: 140,
            expression: OwnerMoaExpression.happy,
          ),
          const SizedBox(height: OwnerSpacing.xl),
          OwnerCard(
            variant: OwnerCardVariant.elevated,
            child: Column(
              children: [
                Text('오늘의 산책', style: OwnerTypography.overline),
                const SizedBox(height: OwnerSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(timeLabel, style: OwnerTypography.h2),
                        Text('시간', style: OwnerTypography.caption),
                      ],
                    ),
                    Column(
                      children: [
                        Text('$steps', style: OwnerTypography.h2),
                        Text('걸음', style: OwnerTypography.caption),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '+$xp',
                          style: OwnerTypography.h2.copyWith(
                            color: OwnerColors.actionPrimary,
                          ),
                        ),
                        Text('XP', style: OwnerTypography.caption),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          OwnerButton(label: '확인', onPressed: onOk),
          const SizedBox(height: OwnerSpacing.xxl),
        ],
      ),
    );
  }
}
