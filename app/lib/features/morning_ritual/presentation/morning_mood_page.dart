import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/codes/domain/codes_provider.dart';
import 'package:health_mate/features/morning_ritual/domain/rituals_provider.dart';
import 'package:health_mate/shared/utils/test_widget_key.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:intl/intl.dart';

class MorningMoodPage extends ConsumerStatefulWidget {
  const MorningMoodPage({super.key});

  @override
  ConsumerState<MorningMoodPage> createState() => _MorningMoodPageState();
}

class _MorningMoodPageState extends ConsumerState<MorningMoodPage>
    with SingleTickerProviderStateMixin {
  String? _selectedId;
  bool _submitting = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.MMMEd('ko_KR').format(DateTime.now());
    const userName = '친구'; // TODO: users/me provider에서 이름 가져오기
    final moodAsync = ref.watch(codeGroupProvider('mood'));

    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: OwnerSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  OwnerSpacing.xl,
                  OwnerSpacing.base,
                  0,
                ),
                child: Text(
                  '좋은 아침 · $dateLabel',
                  style: OwnerTypography.overline,
                ),
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final t = CurvedAnimation(
                          parent: _pulse,
                          curve: OwnerMotion.gentle,
                        ).value;
                        final scale = 0.95 + t * 0.1;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: OwnerColors.coral300.withOpacity(0.35),
                        ),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1),
                      duration: OwnerMotion.character,
                      curve: OwnerMotion.bouncy,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const OwnerMoaAvatar(
                        size: 160,
                        expression: OwnerMoaExpression.happy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: Text(
                  '$userName, 오늘 기분은\n어때요?',
                  style: OwnerTypography.h1,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: OwnerSpacing.xl),
              Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: moodAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: OwnerSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: OwnerSpacing.xxl),
                    child: Center(child: Text('옵션을 불러오지 못했어요')),
                  ),
                  data: (options) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: OwnerSpacing.sm,
                      mainAxisSpacing: OwnerSpacing.sm,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final o = options[i];
                      return withTestId(
                        'morning-mood-card-$i',
                        OwnerMoodCard(
                          emoji: o.emoji ?? '',
                          label: o.labelKo,
                          selected: _selectedId == o.id,
                          onTap: _submitting
                              ? null
                              : () => _onSelect(o.id, o.numericValue ?? 3),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSelect(String id, int numericValue) async {
    if (_submitting) return;
    setState(() {
      _selectedId = id;
      _submitting = true;
    });

    try {
      await ref.read(ritualTodayProvider.notifier).submitMood(numericValue);
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      context.go('/morning/promise');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했어요: $e')),
      );
      setState(() {
        _selectedId = null;
        _submitting = false;
      });
    }
  }
}
