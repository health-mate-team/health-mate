import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(OwnerPrefsKeys.onboardingDone) ?? false;
    if (!mounted) return;
    context.go(done ? '/home' : '/onboarding/welcome');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: OwnerMotion.character,
          curve: OwnerMotion.bouncy,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OwnerMoaAvatar(
                size: 140,
                expression: OwnerMoaExpression.happy,
                breathingAnimation: false,
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Text(
                '오우너',
                style: OwnerTypography.h1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: OwnerSpacing.sm),
              Text(
                '오늘도 함께해요',
                style: OwnerTypography.bodySm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
