import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import 'package:health_mate/core/analytics/analytics_event.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/domain/entities/workout_template.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/features/cycle/static_data/workout_matrix.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 03_WORKOUT_MATRIX.json fallback_for_no_video 명세에 따른 운동 실행 화면.
/// 영상 없이 동작 리스트(moves)를 전체 시간에 균등 분할해서 표시 + 전체 카운트다운.
/// 완료(80% 이상 진행) 시 workout_completed, 중도 종료 시 workout_skipped 송신.
class WorkoutSessionPage extends ConsumerStatefulWidget {
  const WorkoutSessionPage({super.key, required this.workoutId});

  final String workoutId;

  @override
  ConsumerState<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends ConsumerState<WorkoutSessionPage>
    with WidgetsBindingObserver {
  WorkoutTemplate? _workout;
  Timer? _ticker;
  int _elapsedSeconds = 0;
  bool _running = false;
  bool _finishedSent = false;

  // audio_guide 포맷의 운동에서만 활성. 동작이 바뀌는 순간 한 번씩 발화.
  FlutterTts? _tts;
  int _lastSpokenMoveIndex = -1;

  // 백그라운드 진입 시각. resumed 시 경과 초만큼 _elapsedSeconds 에 보정 가산.
  // 운동 중일 때만 의미가 있으며, _running == false 이면 보정하지 않음.
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _workout = _findWorkout(widget.workoutId);
    if (_workout?.format == WorkoutFormat.audioGuide) {
      _tts = FlutterTts()
        ..setLanguage('ko-KR')
        ..setSpeechRate(0.5)
        ..setPitch(1.0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _tts?.stop();
    if (!_finishedSent) {
      _maybeRecordSkip(reason: 'disposed');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 운동 중에 백그라운드로 갔다가 돌아올 때만 보정.
    if (!_running || _workout == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _pausedAt ??= DateTime.now();
        _ticker?.cancel();
        _tts?.stop();
        break;
      case AppLifecycleState.resumed:
        final pausedAt = _pausedAt;
        _pausedAt = null;
        if (pausedAt == null) return;
        final delta = DateTime.now().difference(pausedAt).inSeconds;
        if (delta <= 0) {
          // 즉시 복귀 — 단지 ticker 만 재가동.
          _resumeTicker();
          return;
        }
        final remaining = _workout!.durationSeconds - _elapsedSeconds;
        if (delta >= remaining) {
          // 백그라운드에서 운동 시간이 끝남 → 완주 처리.
          _elapsedSeconds = _workout!.durationSeconds;
          if (mounted) setState(() {});
          _onFinish();
        } else {
          _elapsedSeconds += delta;
          if (mounted) setState(() {});
          _resumeTicker();
        }
        break;
      case AppLifecycleState.detached:
        // 앱 종료 — dispose 가 처리.
        break;
    }
  }

  void _resumeTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds += 1;
      });
      _maybeAnnounceNextMove();
      if (_elapsedSeconds >= _workout!.durationSeconds) {
        _ticker?.cancel();
        _onFinish();
      }
    });
  }

  Future<void> _speak(String text) async {
    final tts = _tts;
    if (tts == null) return;
    await tts.stop();
    await tts.speak(text);
  }

  WorkoutTemplate? _findWorkout(String id) {
    for (final w in kWorkoutMatrix) {
      if (w.id == id) return w;
    }
    return null;
  }

  void _start() {
    if (_running || _workout == null) return;
    setState(() => _running = true);
    // 시작 안내 (audio_guide 만)
    if (_tts != null && _elapsedSeconds == 0) {
      unawaited(_speak('${_workout!.titleSuggestion}. 시작할게요'));
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds += 1;
      });
      _maybeAnnounceNextMove();
      if (_elapsedSeconds >= _workout!.durationSeconds) {
        _ticker?.cancel();
        _onFinish();
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    _tts?.stop();
    if (mounted) setState(() => _running = false);
  }

  /// audio_guide: 동작 인덱스가 바뀌는 1초에만 발화.
  void _maybeAnnounceNextMove() {
    if (_tts == null || _workout == null) return;
    final idx = _currentMoveIndex(_workout!);
    if (idx == _lastSpokenMoveIndex) return;
    _lastSpokenMoveIndex = idx;
    final text = _workout!.moves[idx];
    unawaited(_speak(text));
  }

  void _onFinish() {
    if (_finishedSent || _workout == null) return;
    _finishedSent = true;
    if (_tts != null) {
      unawaited(_speak('잘 했어요. 운동 끝났어요'));
    }
    final recorder = ref.read(analyticsRecorderProvider);
    unawaited(recorder.record(AnalyticsEvent.workoutCompleted(
      workoutId: _workout!.id,
      phase: _workout!.phase,
      durationTargetSeconds: _workout!.durationSeconds,
      durationActualSeconds: _elapsedSeconds,
      ts: DateTime.now(),
    )));
    if (mounted) setState(() => _running = false);
  }

  void _maybeRecordSkip({String reason = 'user_exit'}) {
    if (_finishedSent || _workout == null) return;
    if (_elapsedSeconds == 0) {
      // 시작도 안 했으면 skipped 도 보내지 않음 — 단순 진입 후 이탈은 계측 가치 낮음.
      return;
    }
    _finishedSent = true;
    final recorder = ref.read(analyticsRecorderProvider);
    unawaited(recorder.record(AnalyticsEvent.workoutSkipped(
      workoutId: _workout!.id,
      phase: _workout!.phase,
      skipReason: reason,
      ts: DateTime.now(),
    )));
  }

  Future<void> _handleExit() async {
    if (_finishedSent) {
      context.pop();
      return;
    }
    final progressPct = _workout == null
        ? 0
        : (_elapsedSeconds * 100 ~/ _workout!.durationSeconds);
    if (_elapsedSeconds == 0) {
      context.pop();
      return;
    }
    final stayed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('운동을 멈출까요?'),
        content: Text('지금까지 $progressPct% 진행했어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('멈추기'),
          ),
        ],
      ),
    );
    if (stayed == true && mounted) {
      _maybeRecordSkip(reason: 'user_exit');
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _workout;
    if (w == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('운동을 찾을 수 없어요.')),
      );
    }

    final profile = kPhaseProfiles[w.phase]!;
    final remaining = w.durationSeconds - _elapsedSeconds;
    final progress =
        w.durationSeconds == 0 ? 0.0 : _elapsedSeconds / w.durationSeconds;
    final currentMoveIndex = _currentMoveIndex(w);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: OwnerColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: OwnerColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            color: OwnerColors.textPrimary,
            onPressed: _handleExit,
          ),
          title: Text(
            '${w.phase.koreanName} · ${w.workoutTypeKorean}',
            style: OwnerTypography.bodySm.copyWith(
              color: profile.colorToken,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: OwnerSpacing.pageHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: OwnerSpacing.lg),
                Text(w.titleSuggestion, style: OwnerTypography.h1),
                const SizedBox(height: OwnerSpacing.xs),
                Text(
                  w.descriptionForUser,
                  style: OwnerTypography.bodySm.copyWith(
                    color: OwnerColors.textSecondary,
                  ),
                ),
                const SizedBox(height: OwnerSpacing.xl),
                Center(
                  child: OwnerMoaAvatar(
                    size: 140,
                    expression: profile.moaExpression,
                  ),
                ),
                const SizedBox(height: OwnerSpacing.lg),
                _Timer(
                  remaining: remaining,
                  total: w.durationSeconds,
                  progress: progress,
                  color: profile.colorToken,
                ),
                const SizedBox(height: OwnerSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    itemCount: w.moves.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: OwnerSpacing.sm),
                    itemBuilder: (context, i) {
                      return _MoveTile(
                        index: i + 1,
                        text: w.moves[i],
                        active: i == currentMoveIndex,
                        done: i < currentMoveIndex,
                      );
                    },
                  ),
                ),
                if (_finishedSent && !_running)
                  Padding(
                    padding: const EdgeInsets.only(bottom: OwnerSpacing.md),
                    child: OwnerCard(
                      variant: OwnerCardVariant.elevated,
                      child: Row(
                        children: [
                          Text(profile.moaDecorations.isNotEmpty
                              ? profile.moaDecorations.first
                              : '✨'),
                          const SizedBox(width: OwnerSpacing.sm),
                          Expanded(
                            child: Text(
                              profile.exampleMessages.first,
                              style: OwnerTypography.bodySm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: OwnerSpacing.lg),
                  child: _BottomActions(
                    finished: _finishedSent,
                    running: _running,
                    onStart: _start,
                    onPause: _pause,
                    onDone: () => context.pop(true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _currentMoveIndex(WorkoutTemplate w) {
    if (w.moves.isEmpty) return 0;
    final perMove = w.durationSeconds / w.moves.length;
    final idx = (_elapsedSeconds / perMove).floor();
    return idx.clamp(0, w.moves.length - 1);
  }
}

class _Timer extends StatelessWidget {
  const _Timer({
    required this.remaining,
    required this.total,
    required this.progress,
    required this.color,
  });

  final int remaining;
  final int total;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final mm = (remaining ~/ 60).toString().padLeft(1, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$mm:$ss',
          textAlign: TextAlign.center,
          style: OwnerTypography.displayXl.copyWith(color: color),
        ),
        const SizedBox(height: OwnerSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: OwnerColors.beige100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({
    required this.index,
    required this.text,
    required this.active,
    required this.done,
  });

  final int index;
  final String text;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final bg = active ? OwnerColors.bgElevated : OwnerColors.bgSurface;
    final border = active
        ? OwnerColors.borderFocus
        : OwnerColors.borderDefault;
    final textColor =
        done ? OwnerColors.textDisabled : OwnerColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.md,
        vertical: OwnerSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: OwnerRadius.radiusMd,
        border: Border.all(color: border, width: active ? 1.5 : 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? OwnerColors.actionPrimary
                  : (active
                      ? OwnerColors.actionPrimary
                      : OwnerColors.bgPrimary),
            ),
            child: done
                ? const Icon(Icons.check,
                    size: 16, color: OwnerColors.textOnAction)
                : Text(
                    '$index',
                    style: OwnerTypography.bodySm.copyWith(
                      color: active
                          ? OwnerColors.textOnAction
                          : OwnerColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: OwnerSpacing.md),
          Expanded(
            child: Text(
              text,
              style: OwnerTypography.body.copyWith(
                color: textColor,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.finished,
    required this.running,
    required this.onStart,
    required this.onPause,
    required this.onDone,
  });

  final bool finished;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return OwnerButton(label: '잘 했어요!', onPressed: onDone);
    }
    if (running) {
      return OwnerButton(
        label: '잠깐 쉬기',
        variant: OwnerButtonVariant.secondary,
        onPressed: onPause,
      );
    }
    return OwnerButton(label: '시작하기', onPressed: onStart);
  }
}
