import 'package:health_mate/core/constants/cycle_phase.dart';

class CycleCurrentDto {
  const CycleCurrentDto({
    required this.currentPhase,
    required this.dayOfCycle,
    required this.daysUntilNextPeriod,
    required this.nextPeriodDate,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.isIrregular,
    required this.goalType,
  });

  factory CycleCurrentDto.fromJson(Map<String, dynamic> json) =>
      CycleCurrentDto(
        currentPhase: CyclePhase.parse(json['current_phase'] as String? ?? ''),
        dayOfCycle: (json['day_of_cycle'] as num).toInt(),
        daysUntilNextPeriod:
            (json['days_until_next_period'] as num? ?? 0).toInt(),
        nextPeriodDate: json['next_period_date'] as String? ?? '',
        averageCycleLength:
            (json['average_cycle_length'] as num? ?? 28).toInt(),
        averagePeriodLength:
            (json['average_period_length'] as num? ?? 5).toInt(),
        isIrregular: json['is_irregular'] as bool? ?? false,
        goalType: json['goal_type'] as String? ?? '',
      );

  final CyclePhase currentPhase;
  final int dayOfCycle;
  final int daysUntilNextPeriod;
  final String nextPeriodDate;
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool isIrregular;
  final String goalType;
}

class CycleSettingsRequest {
  const CycleSettingsRequest({
    this.lastPeriodStartDate,
    this.averageCycleLength,
    this.averagePeriodLength,
    this.isIrregular,
    this.goalType,
  });

  final String? lastPeriodStartDate;
  final int? averageCycleLength;
  final int? averagePeriodLength;
  final bool? isIrregular;
  final String? goalType;

  Map<String, dynamic> toJson() => {
        if (lastPeriodStartDate != null)
          'last_period_start_date': lastPeriodStartDate,
        if (averageCycleLength != null)
          'average_cycle_length': averageCycleLength,
        if (averagePeriodLength != null)
          'average_period_length': averagePeriodLength,
        if (isIrregular != null) 'is_irregular': isIrregular,
        if (goalType != null) 'goal_type': goalType,
      };
}

class CycleCalendarDayDto {
  const CycleCalendarDayDto({
    required this.date,
    required this.phase,
    required this.dayOfCycle,
  });

  factory CycleCalendarDayDto.fromJson(Map<String, dynamic> json) =>
      CycleCalendarDayDto(
        date: json['date'] as String,
        phase: CyclePhase.parse(json['phase'] as String? ?? ''),
        dayOfCycle: (json['day_of_cycle'] as num).toInt(),
      );

  final String date;
  final CyclePhase phase;
  final int dayOfCycle;
}
