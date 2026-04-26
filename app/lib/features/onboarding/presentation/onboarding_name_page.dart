import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [docs/design/owner-mock-develop/03_onboarding_name.json]
class OnboardingNamePage extends StatefulWidget {
  const OnboardingNamePage({super.key});

  @override
  State<OnboardingNamePage> createState() => _OnboardingNamePageState();
}

class _OnboardingNamePageState extends State<OnboardingNamePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OwnerPrefsKeys.displayName, name);
    if (!mounted) return;
    context.go('/onboarding/goal');
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
                  final ok = _controller.text.trim().isNotEmpty;
                  return OwnerButton(
                    label: '다음',
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
