import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/nutrition/domain/nutrition_provider.dart';

class NutritionPage extends ConsumerStatefulWidget {
  const NutritionPage({super.key});

  @override
  ConsumerState<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends ConsumerState<NutritionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(nutritionTodayProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionTodayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘 식단')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (data) {
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rec = data.phaseRecommendation;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 섭취: ${data.totalCalories} kcal / ${data.dailyTargetCalories} kcal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  rec.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (rec.focusNutrients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: rec.focusNutrients
                        .map((n) => Chip(label: Text(n)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                if (data.meals.isEmpty)
                  const Text('아직 기록된 식사가 없어요')
                else
                  ...data.meals.map(
                    (m) => ListTile(
                      title: Text(m.mealType),
                      trailing: Text('${m.calories} kcal'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
