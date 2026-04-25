import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MoodOption {
  const _MoodOption({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;
}

class MorningMoodPage extends StatefulWidget {
  const MorningMoodPage({super.key});

  @override
  State<MorningMoodPage> createState() => _MorningMoodPageState();
}

class _MorningMoodPageState extends State<MorningMoodPage>
    with SingleTickerProviderStateMixin {
  static const _options = <_MoodOption>[
    _MoodOption(id: 'great', emoji: '✨', label: '좋아요'),
    _MoodOption(id: 'okay', emoji: '☕', label: '보통'),
    _MoodOption(id: 'tired', emoji: '😴', label: '피곤'),
    _MoodOption(id: 'exhausted', emoji: '💧', label: '지침'),
  ];

  String? _selectedId;
  String _userName = '친구';
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    unawaited(_loadName());
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

    return Scaffold(
      backgroundColor: OwnerColors.bgElevated,
      body: SafeArea(
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
            const SizedBox(height: OwnerSpacing.xxl),
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
            const SizedBox(height: OwnerSpacing.xxl),
            Padding(
              padding: OwnerSpacing.pageHorizontal,
              child: Text(
                '$_userName, 오늘 기분은\n어때요?',
                style: OwnerTypography.h1,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Expanded(
              child: Padding(
                padding: OwnerSpacing.pageHorizontal,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: OwnerSpacing.sm,
                    mainAxisSpacing: OwnerSpacing.sm,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, i) {
                    final o = _options[i];
                    return OwnerMoodCard(
                      emoji: o.emoji,
                      label: o.label,
                      selected: _selectedId == o.id,
                      onTap: () => _onSelect(o.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString(OwnerPrefsKeys.displayName);
    if (!mounted) return;
    if (n != null && n.isNotEmpty) {
      setState(() => _userName = n);
    }
  }

  void _onSelect(String id) {
    setState(() => _selectedId = id);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () async {
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(OwnerPrefsKeys.morningMoodId, id);
        if (!mounted) return;
        context.go('/morning/promise');
      }),
    );
  }
}
