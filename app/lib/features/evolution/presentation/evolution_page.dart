import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 명세: [오우너 목업디벨롭파일/12_evolution.json] — 단색 단계 전환만 사용 (그라디언트 없음).
class _StageData {
  const _StageData({
    required this.icon,
    required this.name,
    required this.perks,
  });

  final String icon;
  final String name;
  final List<String> perks;
}

_StageData _stageForLevel(int level) {
  if (level >= 30) {
    return const _StageData(
      icon: '👑',
      name: '마스터 모아',
      perks: [
        '한정판 굿즈 쿠폰',
        '수 친구 12마리 완성',
        '명예의 전당 등록',
      ],
    );
  }
  if (level >= 15) {
    return const _StageData(
      icon: '✨',
      name: '빛나는 모아',
      perks: [
        '프리미엄 옷장 해금',
        '오우너 메이트 칭호',
        '수 친구 8마리 완성',
      ],
    );
  }
  if (level >= 7) {
    return const _StageData(
      icon: '🧡',
      name: '오우너 모아',
      perks: [
        '주간 리그 참여 가능',
        '옷 10종 사용 가능',
        '수 친구 4마리 완성',
      ],
    );
  }
  return const _StageData(
    icon: '🐣',
    name: '작은 모아',
    perks: [
      '옷장 기능 해금',
      '첫 번째 옷 \'베이직 핀\' 지급',
      '수 친구 1마리 합류',
    ],
  );
}

class EvolutionPage extends StatefulWidget {
  const EvolutionPage({super.key, this.newLevel = 4});

  final int newLevel;

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
  late final _StageData _stage;
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _stage = _stageForLevel(widget.newLevel);
    unawaited(_runIntro());
  }

  Future<void> _runIntro() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _phase = 1);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _phase = 2);
  }

  void _continue() {
    if (_phase >= 2 && _phase < 4) {
      setState(() => _phase++);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase < 2) {
      return Scaffold(
        backgroundColor: _phase == 0
            ? OwnerColors.cocoa800
            : OwnerColors.actionPrimary,
        body: SafeArea(
          child: Center(
            child: _phase == 0
                ? const OwnerMoaAvatar(
                    size: 160,
                    expression: OwnerMoaExpression.default_,
                    breathingAnimation: false,
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1.35),
                    duration: const Duration(milliseconds: 1600),
                    curve: OwnerMotion.bouncy,
                    builder: (context, scale, _) {
                      return Container(
                        width: 200 * scale,
                        height: 200 * scale,
                        decoration: const BoxDecoration(
                          color: OwnerColors.white,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OwnerColors.beige50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: OwnerSpacing.base,
                vertical: OwnerSpacing.md,
              ),
              child: OwnerStoryProgressBar(
                totalSteps: 3,
                currentStep: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.sm,
                OwnerSpacing.base,
                0,
              ),
              child: Text(
                '모아가 자랐어요!',
                style: OwnerTypography.overline.copyWith(
                  color: OwnerColors.actionPrimary,
                ),
              ),
            ),
            const SizedBox(height: OwnerSpacing.lg),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    color: OwnerColors.coral100,
                    shape: BoxShape.circle,
                  ),
                ),
                const OwnerMoaAvatar(
                  size: 220,
                  expression: OwnerMoaExpression.starEyes,
                  breathingAnimation: false,
                ),
              ],
            ),
            const SizedBox(height: OwnerSpacing.md),
            Text(
              'Lv.${widget.newLevel}',
              style: OwnerTypography.displayXl.copyWith(
                color: OwnerColors.actionPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OwnerSpacing.sm),
            Text(
              '${_stage.icon} ${_stage.name}',
              style: OwnerTypography.h1,
              textAlign: TextAlign.center,
            ),
            Text(
              'Lv.${widget.newLevel} 도달',
              style: OwnerTypography.body.copyWith(
                color: OwnerColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OwnerSooAvatar(
                  size: 44,
                  breathingAnimation: false,
                ),
                const SizedBox(width: OwnerSpacing.sm),
                Text(
                  '수도 함께 응원해요',
                  style: OwnerTypography.bodySm,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  OwnerSpacing.lg,
                  OwnerSpacing.base,
                  OwnerSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_phase >= 3) ...[
                      OwnerCard(
                        variant: OwnerCardVariant.surface,
                        padding: const EdgeInsets.all(OwnerSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('새로 풀린 것들', style: OwnerTypography.overline),
                            const SizedBox(height: OwnerSpacing.md),
                            for (final p in _stage.perks)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: OwnerSpacing.sm,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: OwnerIconSize.md,
                                      color: OwnerColors.actionPrimary,
                                    ),
                                    const SizedBox(width: OwnerSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        p,
                                        style: OwnerTypography.bodySm,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OwnerSpacing.lg),
                    ],
                    if (_phase >= 4) ...[
                      OwnerButton(
                        label: '친구에게 자랑하기',
                        icon: Icons.share_outlined,
                        onPressed: () {
                          // TODO: share_plus 등 네이티브 공유 연동
                          context.go('/home');
                        },
                      ),
                      const SizedBox(height: OwnerSpacing.sm),
                      Center(
                        child: OwnerButton(
                          label: '괜찮아요, 그냥 시작할게요',
                          variant: OwnerButtonVariant.text,
                          fullWidth: false,
                          onPressed: () => context.go('/home'),
                        ),
                      ),
                    ],
                    if (_phase == 2 || _phase == 3) ...[
                      const SizedBox(height: OwnerSpacing.lg),
                      OwnerButton(
                        label: '계속',
                        onPressed: _continue,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
