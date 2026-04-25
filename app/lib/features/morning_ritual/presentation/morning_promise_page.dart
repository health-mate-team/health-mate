import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/shared/constants/owner_prefs_keys.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 명세: [오우너 목업디벨롭파일/07_morning_ritual_promise.json]

String? _normalizeGoalId(String? raw) {
  switch (raw) {
    case 'move':
      return 'energy';
    case 'water':
      return 'hydration';
    case 'sleep':
      return 'rest';
    case 'meal':
      return 'shape';
    default:
      return raw;
  }
}

OwnerMoaExpression _expressionForMood(String? moodId) {
  switch (moodId) {
    case 'great':
      return OwnerMoaExpression.happy;
    case 'exhausted':
    case 'tired':
      return OwnerMoaExpression.sleepy;
    default:
      return OwnerMoaExpression.default_;
  }
}

String _speechForMood(String? moodId) {
  switch (moodId) {
    case 'great':
      return '오늘 컨디션 좋네요! 기분 좋게 도전해봐요 ✨';
    case 'okay':
      return '보통이군요. 오늘은 가볍게 해봐요!';
    case 'tired':
      return '조금 피곤하시군요. 천천히 갈게요';
    case 'exhausted':
      return '오늘은 무리하지 말고 쉬어요';
    default:
      return '오늘도 작은 약속 하나만 정해봐요';
  }
}

class _PromiseRec {
  const _PromiseRec({
    required this.text,
    required this.scheduledTime,
    required this.rewardXp,
  });

  final String text;
  final String scheduledTime;
  final int rewardXp;
}

_PromiseRec _recommendedPromise(String? moodId, String? goalId) {
  final mood = moodId ?? 'okay';
  final goal = _normalizeGoalId(goalId) ?? 'energy';

  if (mood == 'exhausted') {
    return const _PromiseRec(
      text: '물 8잔 마시기',
      scheduledTime: '하루 종일',
      rewardXp: 30,
    );
  }
  if (mood == 'tired') {
    return const _PromiseRec(
      text: '5분 스트레칭',
      scheduledTime: '아침·점심',
      rewardXp: 25,
    );
  }
  if (mood == 'great' && goal == 'energy') {
    return const _PromiseRec(
      text: '30분 산책 또는 가벼운 홈트',
      scheduledTime: '저녁 6~8시',
      rewardXp: 40,
    );
  }
  if (mood == 'okay' && goal == 'energy') {
    return const _PromiseRec(
      text: '20분 산책',
      scheduledTime: '저녁 무렵',
      rewardXp: 35,
    );
  }
  if (goal == 'hydration') {
    return const _PromiseRec(
      text: '물 6잔 이상 마시기',
      scheduledTime: '하루 종일',
      rewardXp: 30,
    );
  }
  if (goal == 'rest') {
    return const _PromiseRec(
      text: '스크린 끄고 30분 휴식',
      scheduledTime: '잠들기 전',
      rewardXp: 30,
    );
  }
  if (goal == 'shape') {
    return const _PromiseRec(
      text: '가벼운 식사·간식 기록하기',
      scheduledTime: '식사 후',
      rewardXp: 28,
    );
  }
  return const _PromiseRec(
    text: '20분 산책',
    scheduledTime: '저녁 무렵',
    rewardXp: 30,
  );
}

class MorningPromisePage extends StatefulWidget {
  const MorningPromisePage({super.key});

  @override
  State<MorningPromisePage> createState() => _MorningPromisePageState();
}

class _MorningPromisePageState extends State<MorningPromisePage> {
  String? _moodId;
  String? _goalId;
  late _PromiseRec _promise;

  static const _alternatives = <_PromiseRec>[
    _PromiseRec(
      text: '계단 한 층 오르내리기',
      scheduledTime: '점심 무렵',
      rewardXp: 20,
    ),
    _PromiseRec(
      text: '창문 열고 심호흡 1분',
      scheduledTime: '아침',
      rewardXp: 15,
    ),
    _PromiseRec(
      text: '좋아하는 음악 한 곡 듣기',
      scheduledTime: '퇴근 후',
      rewardXp: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _promise = _recommendedPromise(null, null);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final mood = prefs.getString(OwnerPrefsKeys.morningMoodId);
    final goal = prefs.getString(OwnerPrefsKeys.goalId);
    setState(() {
      _moodId = mood;
      _goalId = goal;
      _promise = _recommendedPromise(mood, goal);
    });
  }

  Future<void> _commit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OwnerPrefsKeys.todayPromiseText, _promise.text);
    await prefs.setString(
      OwnerPrefsKeys.todayPromiseScheduledTime,
      _promise.scheduledTime,
    );
    await prefs.setInt(
      OwnerPrefsKeys.todayPromiseRewardXp,
      _promise.rewardXp,
    );
    await prefs.setBool(OwnerPrefsKeys.todayPromiseCompleted, false);
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _showAlternatives() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: OwnerColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: OwnerRadius.sheetTop,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(OwnerSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('다른 약속 고르기', style: OwnerTypography.h3),
                const SizedBox(height: OwnerSpacing.md),
                for (final alt in _alternatives)
                  ListTile(
                    title: Text(alt.text, style: OwnerTypography.body),
                    subtitle: Text(
                      '${alt.scheduledTime} · +${alt.rewardXp} XP',
                      style: OwnerTypography.caption,
                    ),
                    onTap: () {
                      setState(() => _promise = alt);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final speech = _speechForMood(_moodId);
    final moaExpr = _expressionForMood(_moodId);

    return Scaffold(
      backgroundColor: OwnerColors.coral100,
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
                '오늘의 약속',
                style: OwnerTypography.overline,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.lg,
                OwnerSpacing.base,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OwnerMoaAvatar(size: 60, expression: moaExpr),
                  const SizedBox(width: OwnerSpacing.md),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(OwnerSpacing.md),
                      decoration: BoxDecoration(
                        color: OwnerColors.bgSurface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(OwnerRadius.lg),
                          bottomLeft: Radius.circular(OwnerRadius.lg),
                          bottomRight: Radius.circular(OwnerRadius.lg),
                        ),
                        border: Border.all(color: OwnerColors.borderDefault),
                      ),
                      child: Text(
                        speech,
                        style: OwnerTypography.bodySm.copyWith(
                          color: OwnerColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.base,
                OwnerSpacing.base,
                0,
              ),
              child: OwnerCard(
                variant: OwnerCardVariant.surface,
                padding: const EdgeInsets.all(OwnerSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('오늘 딱 하나만', style: OwnerTypography.overline),
                    const SizedBox(height: OwnerSpacing.md),
                    Text(_promise.text, style: OwnerTypography.h2),
                    const SizedBox(height: OwnerSpacing.md),
                    Row(
                      children: [
                        OwnerChip(label: _promise.scheduledTime),
                        const SizedBox(width: OwnerSpacing.sm),
                        OwnerChip(label: '+${_promise.rewardXp} XP'),
                      ],
                    ),
                    const SizedBox(height: OwnerSpacing.lg),
                    OwnerButton(
                      label: '약속할게요',
                      onPressed: _commit,
                    ),
                    const SizedBox(height: OwnerSpacing.sm),
                    Center(
                      child: OwnerButton(
                        label: '다른 걸로 바꾸기',
                        variant: OwnerButtonVariant.text,
                        fullWidth: false,
                        onPressed: _showAlternatives,
                      ),
                    ),
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
