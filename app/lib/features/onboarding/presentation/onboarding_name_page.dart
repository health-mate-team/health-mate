import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/auth/data/dto/auth_dto.dart';
import 'package:health_mate/features/auth/domain/auth_notifier.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [docs/design/owner-mock-develop/03_onboarding_name.json]
class OnboardingNamePage extends ConsumerStatefulWidget {
  const OnboardingNamePage({super.key});

  @override
  ConsumerState<OnboardingNamePage> createState() => _OnboardingNamePageState();
}

class _OnboardingNamePageState extends ConsumerState<OnboardingNamePage> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generateGuestEmail() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random.secure().nextInt(0xFFFFFF).toRadixString(16);
    return 'guest_${ts}_$rand@guest.healthmate.app';
  }

  String _generateGuestPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(16, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> _next() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(OwnerPrefsKeys.displayName, name);

      // 게스트 가입 자동 처리 (MVP) — 차후 소셜 로그인 전환 시 교체.
      await ref.read(authNotifierProvider.notifier).register(
            RegisterRequest(
              email: _generateGuestEmail(),
              password: _generateGuestPassword(),
              name: name,
            ),
          );

      if (!mounted) return;
      context.go('/onboarding/goal');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = '가입에 실패했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _hintCaption(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '나중에 변경할 수 있어요';
    return '"$t"이라고 부를게요';
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
                currentStep: 2,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  OwnerSpacing.xl,
                  OwnerSpacing.base,
                  0,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: OwnerMoaAvatar(
                        size: 100,
                        expression: OwnerMoaExpression.default_,
                      ),
                    ),
                    const SizedBox(height: OwnerSpacing.xxl),
                    Text(
                      '당신을 어떻게\n부를까요?',
                      style: OwnerTypography.h1,
                    ),
                    const SizedBox(height: OwnerSpacing.sm),
                    Text(
                      '이름이나 닉네임 모두 좋아요',
                      style: OwnerTypography.bodySm,
                    ),
                    const SizedBox(height: OwnerSpacing.xl),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: 10,
                      enabled: !_submitting,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _next(),
                      style: OwnerTypography.body,
                      decoration: const InputDecoration(
                        hintText: '예: 지민이',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: OwnerSpacing.md),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return Text(
                          _hintCaption(_controller.text),
                          style: OwnerTypography.caption,
                        );
                      },
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: OwnerSpacing.sm),
                      Text(
                        _errorText!,
                        style: OwnerTypography.caption.copyWith(
                          color: OwnerColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.md,
                OwnerSpacing.base,
                OwnerSpacing.xxl,
              ),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  final ok = _controller.text.trim().isNotEmpty && !_submitting;
                  return OwnerButton(
                    label: _submitting ? '처리 중...' : '다음',
                    onPressed: ok ? _next : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
