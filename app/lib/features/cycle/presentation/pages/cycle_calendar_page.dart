import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/domain/entities/computed_state.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 02_CYCLE_OS visual_indicators.locations[1] (13_cycle_calendar) — 신규 화면.
/// 28일 원형 캘린더로 4단계를 컬러 코딩해서 보여주고, 오늘 위치를 강조.
/// 원의 각 일자를 탭하면 해당일의 단계·메시지·추천 운동 타입을 카드로 표시.
class CycleCalendarPage extends ConsumerStatefulWidget {
  const CycleCalendarPage({super.key});

  @override
  ConsumerState<CycleCalendarPage> createState() => _CycleCalendarPageState();
}

class _CycleCalendarPageState extends ConsumerState<CycleCalendarPage> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final inputAsync = ref.watch(cycleInputStreamProvider);
    final input = inputAsync.valueOrNull;
    final today = ref.watch(computedStateNotifierProvider);
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: OwnerColors.bgPrimary,
        elevation: 0,
        title: Text('나의 사이클', style: OwnerTypography.h3),
        iconTheme: const IconThemeData(color: OwnerColors.textPrimary),
      ),
      body: SafeArea(
        child: input == null || input.lastPeriodStartDate == null
            ? const _EmptyState()
            : _Body(
                input: input,
                today: today,
                selectedDay: _selectedDay ?? today?.dayOfCycle,
                onDayTap: (d) => setState(() => _selectedDay = d),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OwnerSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const SizedBox(height: OwnerSpacing.lg),
            Text(
              '사이클 정보를 입력하면\n오늘이 며칠차인지 보여드릴게요',
              textAlign: TextAlign.center,
              style: OwnerTypography.h3,
            ),
            const SizedBox(height: OwnerSpacing.md),
            Text(
              '입력은 설정에서 언제든 수정할 수 있어요',
              style: OwnerTypography.bodySm.copyWith(
                color: OwnerColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.input,
    required this.today,
    required this.selectedDay,
    required this.onDayTap,
  });

  final CycleInput input;
  final ComputedState? today;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final cycleLen = input.averageCycleLength;
    final periodLen = input.averagePeriodLength;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: OwnerSpacing.md),
          Center(
            child: _CalendarRing(
              cycleLength: cycleLen,
              periodLength: periodLen,
              todayDay: today?.dayOfCycle,
              selectedDay: selectedDay,
              onDayTap: onDayTap,
            ),
          ),
          const SizedBox(height: OwnerSpacing.lg),
          if (selectedDay != null)
            Padding(
              padding: OwnerSpacing.pageHorizontal,
              child: _DayDetail(
                day: selectedDay!,
                cycleLength: cycleLen,
                periodLength: periodLen,
                isToday: today?.dayOfCycle == selectedDay,
              ),
            ),
          const SizedBox(height: OwnerSpacing.md),
          Padding(
            padding: OwnerSpacing.pageHorizontal,
            child: _Legend(),
          ),
          const SizedBox(height: OwnerSpacing.xxl),
        ],
      ),
    );
  }
}

class _CalendarRing extends StatelessWidget {
  const _CalendarRing({
    required this.cycleLength,
    required this.periodLength,
    required this.todayDay,
    required this.selectedDay,
    required this.onDayTap,
  });

  final int cycleLength;
  final int periodLength;
  final int? todayDay;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;

  static const double _ringSize = 320;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ringSize,
      height: _ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_ringSize, _ringSize),
            painter: _RingPainter(
              cycleLength: cycleLength,
              periodLength: periodLength,
            ),
          ),
          ..._dayDots(),
          _CenterLabel(
            todayDay: todayDay,
            cycleLength: cycleLength,
            selectedDay: selectedDay,
            periodLength: periodLength,
          ),
        ],
      ),
    );
  }

  List<Widget> _dayDots() {
    const radius = _ringSize / 2 - 24;
    final widgets = <Widget>[];
    for (var d = 1; d <= cycleLength; d++) {
      // 1일이 위(12시)에 오도록 -90도 시작.
      final angle = (2 * math.pi * (d - 1) / cycleLength) - math.pi / 2;
      final dx = radius * math.cos(angle);
      final dy = radius * math.sin(angle);
      final isToday = d == todayDay;
      final isSelected = d == selectedDay;
      widgets.add(Positioned(
        left: _ringSize / 2 + dx - 14,
        top: _ringSize / 2 + dy - 14,
        child: GestureDetector(
          onTap: () => onDayTap(d),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? OwnerColors.bgSurface
                  : (isSelected
                      ? OwnerColors.bgSurface
                      : Colors.transparent),
              border: isToday
                  ? Border.all(color: OwnerColors.actionPrimary, width: 2)
                  : (isSelected
                      ? Border.all(
                          color: OwnerColors.borderStrong, width: 1.5)
                      : null),
            ),
            child: Text(
              '$d',
              style: OwnerTypography.caption.copyWith(
                color: isToday
                    ? OwnerColors.actionPrimary
                    : OwnerColors.textPrimary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.cycleLength, required this.periodLength});

  final int cycleLength;
  final int periodLength;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 8;
    final innerR = outerR - 18;
    // 4단계의 day 범위 계산 (PhaseAssignmentService 와 동일 규칙).
    final mid = cycleLength ~/ 2;
    final ranges = <_PhaseArc>[
      _PhaseArc(CyclePhase.menstrual, 1, periodLength),
      _PhaseArc(CyclePhase.follicular, periodLength + 1, mid - 2),
      _PhaseArc(CyclePhase.ovulatory, mid - 1, mid + 1),
      _PhaseArc(CyclePhase.luteal, mid + 2, cycleLength),
    ];
    for (final arc in ranges) {
      final start = arc.startDay;
      final end = arc.endDay;
      if (end < start) continue; // 비정상 범위 방지
      final startAngle =
          (2 * math.pi * (start - 1) / cycleLength) - math.pi / 2;
      final sweep = 2 * math.pi * (end - start + 1) / cycleLength;
      final paint = Paint()
        ..color = kPhaseProfiles[arc.phase]!.colorToken.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (outerR - innerR);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (outerR + innerR) / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.cycleLength != cycleLength || old.periodLength != periodLength;
}

class _PhaseArc {
  const _PhaseArc(this.phase, this.startDay, this.endDay);
  final CyclePhase phase;
  final int startDay;
  final int endDay;
}

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({
    required this.todayDay,
    required this.cycleLength,
    required this.selectedDay,
    required this.periodLength,
  });

  final int? todayDay;
  final int cycleLength;
  final int? selectedDay;
  final int periodLength;

  @override
  Widget build(BuildContext context) {
    final showDay = selectedDay ?? todayDay;
    if (showDay == null) {
      return const SizedBox.shrink();
    }
    final phase = _phaseFor(showDay, cycleLength, periodLength);
    final profile = kPhaseProfiles[phase]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(phase.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: OwnerSpacing.xs),
        Text(
          '$showDay / $cycleLength',
          style: OwnerTypography.h2.copyWith(color: profile.colorToken),
        ),
        Text(
          phase.koreanName,
          style: OwnerTypography.bodySm.copyWith(
            color: OwnerColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({
    required this.day,
    required this.cycleLength,
    required this.periodLength,
    required this.isToday,
  });

  final int day;
  final int cycleLength;
  final int periodLength;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final phase = _phaseFor(day, cycleLength, periodLength);
    final profile = kPhaseProfiles[phase]!;
    final messages = profile.exampleMessages;
    final msg = messages[day % messages.length];
    return OwnerCard(
      variant: OwnerCardVariant.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(phase.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: OwnerSpacing.xs),
              Text(
                isToday
                    ? '오늘 · ${phase.koreanName} ${day}일차'
                    : '${phase.koreanName} ${day}일차',
                style: OwnerTypography.overline.copyWith(
                  color: profile.colorToken,
                ),
              ),
            ],
          ),
          const SizedBox(height: OwnerSpacing.sm),
          Text(msg, style: OwnerTypography.h3),
          const SizedBox(height: OwnerSpacing.sm),
          Text(
            '추천 운동: ${profile.workoutTypesPriority.take(2).join(", ")}',
            style: OwnerTypography.bodySm.copyWith(
              color: OwnerColors.textSecondary,
            ),
          ),
          if (profile.workoutTypesAvoid.isNotEmpty) ...[
            const SizedBox(height: OwnerSpacing.xs),
            Text(
              '피하기: ${profile.workoutTypesAvoid.join(", ")}',
              style: OwnerTypography.bodySm.copyWith(
                color: OwnerColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: OwnerSpacing.sm,
      runSpacing: OwnerSpacing.xs,
      children: [
        for (final p in CyclePhase.values)
          _LegendItem(phase: p),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.phase});
  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final profile = kPhaseProfiles[phase]!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.sm,
        vertical: OwnerSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: profile.colorToken.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${phase.emoji} ${phase.koreanName}',
        style: OwnerTypography.bodySm.copyWith(color: OwnerColors.textPrimary),
      ),
    );
  }
}

CyclePhase _phaseFor(int dayOfCycle, int cycleLength, int periodLength) {
  final mid = cycleLength ~/ 2;
  if (dayOfCycle <= periodLength) return CyclePhase.menstrual;
  if (dayOfCycle <= mid - 2) return CyclePhase.follicular;
  if (dayOfCycle <= mid + 1) return CyclePhase.ovulatory;
  return CyclePhase.luteal;
}
