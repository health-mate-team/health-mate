import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [docs/design/owner-mock-develop/05_onboarding_meet_moa.json]
enum _MeetScene { eggIdle, eggCracking, moaAppearing }

class OnboardingMeetMoaPage extends StatefulWidget {
  const OnboardingMeetMoaPage({super.key});

  @override
  State<OnboardingMeetMoaPage> createState() => _OnboardingMeetMoaPageState();
}

class _OnboardingMeetMoaPageState extends State<OnboardingMeetMoaPage>
    with SingleTickerProviderStateMixin {
  _MeetScene _scene = _MeetScene.eggIdle;
  String _name = '친구';
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString(OwnerPrefsKeys.displayName);
    if (!mounted) return;
    if (n != null && n.isNotEmpty) {
      setState(() => _name = n);
    }
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  Future<void> _onEggTap() async {
    if (_scene != _MeetScene.eggIdle) return;
    setState(() => _scene = _MeetScene.eggCracking);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _scene = _MeetScene.moaAppearing);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OwnerPrefsKeys.onboardingDone, true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
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
                totalSteps: 4,
                currentStep: 4,
              ),
            ),
            Expanded(
              child: Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: OwnerMotion.slow,
                          child: _scene == _MeetScene.moaAppearing
                              ? TweenAnimationBuilder<double>(
                                  key: const ValueKey('moa'),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: OwnerMotion.character,
                                  curve: Curves.elasticOut,
                                  builder: (context, t, child) {
                                    return Transform.scale(
                                      scale: t,
                                      child: child,
                                    );
                                  },
                                  child: const OwnerMoaAvatar(
                                    size: 200,
                                    expression: OwnerMoaExpression.default_,
                                  ),
                                )
                              : _scene == _MeetScene.eggCracking
                                  ? const _EggVisual(
                                      key: ValueKey('crack'),
                                      cracking: true,
                                    )
                                  : GestureDetector(
                                      key: const ValueKey('egg'),
                                      onTap: _onEggTap,
                                      child: AnimatedBuilder(
                                        animation: _wiggle,
                                        builder: (context, child) {
                                          final a = (_wiggle.value - 0.5) * 0.06;
                                          return Transform.rotate(
                                            angle: a,
                                            child: child,
                                          );
                                        },
                                        child: const _EggVisual(cracking: false),
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: OwnerSpacing.xl),
                    AnimatedSwitcher(
                      duration: OwnerMotion.slow,
                      child: _scene == _MeetScene.moaAppearing
                          ? Text(
                              '안녕, $_name!\n나의 오우너가 되어줘',
                              key: const ValueKey('moaText'),
                              style: OwnerTypography.h1,
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              '탭해서\n알을 깨워주세요',
                              key: const ValueKey('eggHint'),
                              style: OwnerTypography.body.copyWith(
                                color: OwnerColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                0,
                OwnerSpacing.base,
                OwnerSpacing.xxl,
              ),
              child: _scene == _MeetScene.moaAppearing
                  ? OwnerButton(
                      label: '함께 시작하기',
                      onPressed: _finish,
                    )
                  : const SizedBox(height: 52),
            ),
          ],
        ),
      ),
    );
  }
}

class _EggVisual extends StatelessWidget {
  const _EggVisual({super.key, required this.cracking});

  final bool cracking;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              cracking ? '🐣' : '🥚',
              style: TextStyle(
                fontSize: cracking ? 160 : 140,
              ),
            ),
          ),
        ),
        if (cracking)
          const SizedBox(
            height: 8,
            width: 200,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
