import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:health_mate/shared/widgets/owner/owner_moa_avatar.dart';

part 'phase_profile.freezed.dart';

/// 02_CYCLE_OS.json phases[*] 의 정적 프로필.
/// hormone_state, recommendation_profile, moa_messaging_tone, moa_visual_state 통합.
@freezed
class PhaseProfile with _$PhaseProfile {
  const factory PhaseProfile({
    // hormone_state
    required String energyLevel,
    required List<String> commonSymptoms,

    // recommendation_profile
    required String workoutIntensity,
    required List<String> workoutTypesPriority,
    required List<String> workoutTypesAvoid,
    required List<String> foodFocus,
    required List<String> foodAvoid,
    required String restEmphasis,
    required int sleepTargetHours,

    // moa_messaging_tone
    required String voice,
    required List<String> exampleMessages,
    required List<String> avoidWords,

    // moa_visual_state
    required OwnerMoaExpression moaExpression,
    required List<String> moaDecorations,

    // 컬러 토큰 (직접 Color로 보관 — 컴파일 타임에 OwnerColors 심볼 강제)
    required Color colorToken,

    // 기본 day_range (28일 기준; 실제 phase 매핑은 phase_assignment_service에서)
    required int defaultDayRangeStart,
    required int defaultDayRangeEnd,
  }) = _PhaseProfile;
}
