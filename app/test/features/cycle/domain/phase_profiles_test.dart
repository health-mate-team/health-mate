import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate/core/theme/owner/owner_colors.dart';
import 'package:health_mate/features/cycle/domain/entities/cycle_phase.dart';
import 'package:health_mate/features/cycle/static_data/phase_profiles.dart';
import 'package:health_mate/features/cycle/static_data/workout_matrix.dart';
import 'package:health_mate/shared/widgets/owner/owner_moa_avatar.dart';

void main() {
  group('PhaseProfiles', () {
    test('모든 phase 가 프로필을 가진다', () {
      for (final phase in CyclePhase.values) {
        expect(kPhaseProfiles[phase], isNotNull,
            reason: '${phase.id} 프로필 누락');
      }
    });

    test('컬러 토큰이 02_CYCLE_OS.json 매핑과 일치', () {
      // 02_CYCLE_OS.json phases[*].color_token 사양:
      expect(kPhaseProfiles[CyclePhase.menstrual]!.colorToken,
          OwnerColors.cocoa800);
      expect(kPhaseProfiles[CyclePhase.follicular]!.colorToken,
          OwnerColors.beige300);
      expect(kPhaseProfiles[CyclePhase.ovulatory]!.colorToken,
          OwnerColors.coral500);
      expect(kPhaseProfiles[CyclePhase.luteal]!.colorToken,
          OwnerColors.accentLavender);
    });

    test('avoid 단어가 디자인 룰 — 죄책감/명령형을 차단한다', () {
      // 배란기 ("무리하지 마"는 의도적 차단어)와 황체기 ("힘내자" 차단)
      expect(kPhaseProfiles[CyclePhase.ovulatory]!.avoidWords,
          contains('무리하지 마'));
      expect(kPhaseProfiles[CyclePhase.luteal]!.avoidWords, contains('힘내자'));
      // 월경기는 격려성 단어가 차단되어야 함
      expect(kPhaseProfiles[CyclePhase.menstrual]!.avoidWords,
          contains('힘내'));
    });

    test('moaExpression 매핑 — 황체기 후반은 sleepy', () {
      expect(moaExpressionFor(CyclePhase.menstrual),
          OwnerMoaExpression.sleepy);
      expect(moaExpressionFor(CyclePhase.ovulatory),
          OwnerMoaExpression.starEyes);
      expect(
          moaExpressionFor(CyclePhase.luteal,
              lutealSub: LutealSubPhase.early),
          OwnerMoaExpression.default_);
      expect(
          moaExpressionFor(CyclePhase.luteal,
              lutealSub: LutealSubPhase.late),
          OwnerMoaExpression.sleepy);
    });

    test('exampleMessages 가 비어있지 않다 (모아 메시지 SOURCE OF TRUTH)', () {
      for (final phase in CyclePhase.values) {
        expect(kPhaseProfiles[phase]!.exampleMessages, isNotEmpty);
      }
    });
  });

  group('WorkoutMatrix', () {
    test('모든 phase 에 적어도 1개 운동이 있다', () {
      for (final phase in CyclePhase.values) {
        final workouts = workoutsForPhase(phase).toList();
        expect(workouts, isNotEmpty, reason: '${phase.id} 운동 없음');
      }
    });

    test('월경기에는 hiit 와 strength_training 이 없다 (skip 규칙)', () {
      final menstrualWorkouts = workoutsForPhase(CyclePhase.menstrual).toList();
      expect(menstrualWorkouts.any((w) => w.workoutType == 'hiit'), isFalse);
      expect(
          menstrualWorkouts.any((w) => w.workoutType == 'strength_training'),
          isFalse);
    });

    test('황체기에는 hiit 가 없다 (skip 규칙)', () {
      final lutealWorkouts = workoutsForPhase(CyclePhase.luteal).toList();
      expect(lutealWorkouts.any((w) => w.workoutType == 'hiit'), isFalse);
    });

    test('운동 id 가 모두 고유하다', () {
      final ids = kWorkoutMatrix.map((w) => w.id).toSet();
      expect(ids.length, kWorkoutMatrix.length);
    });

    test('각 운동에 moves 가 1개 이상', () {
      for (final w in kWorkoutMatrix) {
        expect(w.moves, isNotEmpty, reason: '${w.id} moves 비어있음');
      }
    });

    test('모든 운동의 duration 은 5분 이내 (R04: 시간 부담 최소화)', () {
      for (final w in kWorkoutMatrix) {
        expect(w.durationSeconds, lessThanOrEqualTo(300),
            reason: '${w.id} duration 5분 초과');
      }
    });
  });
}
