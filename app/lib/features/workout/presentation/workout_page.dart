import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_mate/features/workout/domain/workout_provider.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(workoutRecommendProvider.notifier).load(),
    );
  }

  Future<void> _complete(String workoutId) async {
    await ref.read(workoutRecommendProvider.notifier).complete(workoutId);
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _skip(String workoutId) async {
    await ref
        .read(workoutRecommendProvider.notifier)
        .skip(workoutId, reason: 'busy');
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutRecommendProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 운동')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (data) {
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rec = data.recommendation;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  rec.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('강도: ${rec.intensity} · ${rec.durationMinutes}분'),
                Text('단계: ${rec.phaseFit}'),
                const Spacer(),
                if (data.alternative != null)
                  TextButton(
                    onPressed: () => _complete(data.alternative!.workoutId),
                    child: Text('대안 운동: ${data.alternative!.title}'),
                  ),
                FilledButton(
                  onPressed: () => _complete(rec.workoutId),
                  child: const Text('운동 완료'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _skip(rec.workoutId),
                  child: const Text('건너뛰기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
