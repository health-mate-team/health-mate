import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';
import 'package:health_mate/features/cycle/presentation/cycle_providers.dart';
import 'package:health_mate/shared/widgets/owner/owner_widgets.dart';

/// 02_CYCLE_OS.json 의 user_cycle_input 입력 화면.
/// 마지막 생리 시작일 + 평균 사이클 길이 + (옵션) 불규칙 여부.
/// "건너뛰기" 가능 — general_lifestyle 모드 (edge_case.no_period_input).
class OnboardingCyclePage extends ConsumerStatefulWidget {
  const OnboardingCyclePage({super.key});

  @override
  ConsumerState<OnboardingCyclePage> createState() => _OnboardingCyclePageState();
}

class _OnboardingCyclePageState extends ConsumerState<OnboardingCyclePage> {
  DateTime? _lastPeriodStart;
  int _cycleLength = 28;
  bool _isIrregular = false;
  bool _saving = false;

  Future<void> _next({required bool skip}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(cycleRepositoryProvider);
    final now = DateTime.now();
    await repo.save(CycleInput(
      lastPeriodStartDate: skip ? null : _lastPeriodStart,
      averageCycleLength: _cycleLength,
      averagePeriodLength: 5,
      isIrregular: _isIrregular,
      updatedAt: now,
    ));
    if (!mounted) return;
    context.go('/onboarding/meet-moa');
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final initial = _lastPeriodStart ?? today.subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today.subtract(const Duration(days: 90)),
      lastDate: today,
      helpText: '마지막 생리 시작일',
    );
    if (picked != null) {
      setState(() => _lastPeriodStart = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _lastPeriodStart != null && !_saving;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OwnerSpacing.base,
                OwnerSpacing.base,
                OwnerSpacing.base,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '마지막 생리는\n언제 시작했나요?',
                    style: OwnerTypography.h1,
                  ),
                  const SizedBox(height: OwnerSpacing.sm),
                  Text(
                    '오우너가 사이클 단계에 맞춰 운동·휴식을 추천해요',
                    style: OwnerTypography.bodySm,
                  ),
                  const SizedBox(height: OwnerSpacing.xs),
                  Text(
                    '이 데이터는 이 기기에만 저장돼요',
                    style: OwnerTypography.caption.copyWith(
                      color: OwnerColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OwnerSpacing.xxl),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OwnerSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DateSelectorTile(
                      date: _lastPeriodStart,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: OwnerSpacing.lg),
                    _CycleLengthTile(
                      value: _cycleLength,
                      onChanged: (v) => setState(() => _cycleLength = v),
                    ),
                    const SizedBox(height: OwnerSpacing.lg),
                    _IrregularToggle(
                      value: _isIrregular,
                      onChanged: (v) => setState(() => _isIrregular = v),
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
                OwnerSpacing.lg,
              ),
              child: Column(
                children: [
                  OwnerButton(
                    label: '시작하기',
                    onPressed: canProceed ? () => _next(skip: false) : null,
                    loading: _saving,
                  ),
                  const SizedBox(height: OwnerSpacing.sm),
                  OwnerButton(
                    label: '나중에 입력할게요',
                    variant: OwnerButtonVariant.text,
                    onPressed: _saving ? null : () => _next(skip: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  const _DateSelectorTile({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = date != null;
    final label = hasValue
        ? '${date!.year}.${date!.month.toString().padLeft(2, '0')}.${date!.day.toString().padLeft(2, '0')}'
        : '날짜 선택';
    return Material(
      color: OwnerColors.bgSurface,
      borderRadius: OwnerRadius.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: OwnerRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(OwnerSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: OwnerRadius.radiusLg,
            border: Border.all(
              color: hasValue
                  ? OwnerColors.actionPrimary
                  : OwnerColors.borderDefault,
              width: hasValue ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              const Text('🩸', style: TextStyle(fontSize: 28)),
              const SizedBox(width: OwnerSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('마지막 생리 시작일', style: OwnerTypography.bodySm),
                    const SizedBox(height: OwnerSpacing.xs),
                    Text(label, style: OwnerTypography.h3),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: OwnerColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleLengthTile extends StatelessWidget {
  const _CycleLengthTile({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OwnerSpacing.lg),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusLg,
        border: Border.all(color: OwnerColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('평균 사이클 길이', style: OwnerTypography.bodySm),
              const Spacer(),
              Text('$value일', style: OwnerTypography.h3),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 21,
            max: 35,
            divisions: 14,
            label: '$value일',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _IrregularToggle extends StatelessWidget {
  const _IrregularToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OwnerColors.bgSurface,
      borderRadius: OwnerRadius.radiusLg,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: OwnerRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(OwnerSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: OwnerRadius.radiusLg,
            border: Border.all(color: OwnerColors.borderDefault, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('사이클이 불규칙해요', style: OwnerTypography.h3),
                    const SizedBox(height: OwnerSpacing.xs),
                    Text(
                      '추천을 \'대략적인 가이드\'로 표시해요',
                      style: OwnerTypography.bodySm,
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: OwnerColors.actionPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
