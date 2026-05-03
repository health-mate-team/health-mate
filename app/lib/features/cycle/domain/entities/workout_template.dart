import 'package:freezed_annotation/freezed_annotation.dart';

import 'cycle_phase.dart';

part 'workout_template.freezed.dart';

/// 03_WORKOUT_MATRIX.json matrix[*].phases[phaseId] 의 한 칸.
/// MVP에서는 영상 없이 fallback (텍스트 + moves 리스트) 모드로 사용.
@freezed
class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    required CyclePhase phase,
    required String workoutType,
    required String workoutTypeKorean,
    required WorkoutPriority priority,
    required int durationSeconds,
    required String titleSuggestion,
    required String descriptionForUser,
    required int productionPriority,
    required List<String> moves,
    @Default(WorkoutFormat.illustrated) WorkoutFormat format,
  }) = _WorkoutTemplate;
}

enum WorkoutPriority {
  /// 단계의 코어 운동
  core,
  /// 메인 운동
  main,
  /// 워밍업
  warmup,
  /// 쿨다운
  cooldown,
  /// 짧은/소프트 옵션
  soft,
  /// 짧은 호흡/명상
short,
  /// 입문
  intro,
  /// 추천하지 않음
  skip,
}

enum WorkoutFormat {
  /// 영상 + 일러스트
  video,
  /// 일러스트 + 텍스트 큐
  illustrated,
  /// 오디오 가이드만
  audioGuide,
}
