import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/codes/domain/codes_provider.dart';
import 'package:health_mate/features/users/data/users_repository.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _warmupCodes();
    _timer = Timer(const Duration(milliseconds: 1500), _goNext);
  }

  // codesRepository가 API 실패 시 assets/seed/codes.json 번들 fallback을 처리한다.
  // 다음 화면 진입 시 codeGroupProvider가 즉시 데이터를 반환하도록 사전 로드.
  Future<void> _warmupCodes() async {
    try {
      await ref.read(codesProvider.future);
    } catch (_) {
      // 번들 로드까지 실패한 경우는 화면 측에서 빈 리스트로 처리.
    }
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (token == null) {
      if (!mounted) return;
      context.go('/onboarding/welcome');
      return;
    }
    try {
      final me = await ref.read(usersRepositoryProvider).getMe();
      if (!mounted) return;
      context.go(me.isOnboardingCompleted ? '/home' : '/onboarding/welcome');
    } catch (_) {
      if (!mounted) return;
      context.go('/onboarding/welcome');
    }
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
