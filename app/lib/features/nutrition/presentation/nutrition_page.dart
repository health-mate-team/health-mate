import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';
import 'package:health_mate/features/nutrition/data/dto/nutrition_dto.dart';
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

  Future<void> _onFabPressed() async {
    final selectedType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _MealTypeBottomSheet(),
    );

    if (selectedType == null) return;
    if (!mounted) return;

    try {
      await ref.read(nutritionTodayProvider.notifier).logMeal(
            NutritionLogRequest(
              mealType: selectedType,
              foods: const [FoodItem(foodId: 'manual_entry', amountG: 100)],
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식사가 기록되었어요!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기록 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionTodayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘 식단')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: OwnerColors.actionPrimary,
        foregroundColor: OwnerColors.textOnAction,
        icon: const Icon(Icons.restaurant_outlined),
        label: const Text('식사 기록'),
      ),
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

/// 식사 유형 선택 BottomSheet
class _MealTypeBottomSheet extends StatelessWidget {
  const _MealTypeBottomSheet();

  static const List<({String type, String label, IconData icon})> _items = [
    (type: 'breakfast', label: '아침', icon: Icons.wb_sunny_outlined),
    (type: 'lunch', label: '점심', icon: Icons.wb_cloudy_outlined),
    (type: 'dinner', label: '저녁', icon: Icons.nights_stay_outlined),
    (type: 'snack', label: '간식', icon: Icons.cookie_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OwnerColors.bgSurface,
      borderRadius: OwnerRadius.sheetTop,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: OwnerSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: OwnerSpacing.md),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OwnerColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  OwnerSpacing.base,
                  OwnerSpacing.lg,
                  OwnerSpacing.base,
                  OwnerSpacing.md,
                ),
                child: Text('어떤 식사를 기록할까요?', style: OwnerTypography.h3),
              ),
              ..._items.map(
                (item) => InkWell(
                  onTap: () => Navigator.of(context).pop(item.type),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OwnerSpacing.base,
                      vertical: OwnerSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: OwnerColors.bgElevated,
                            borderRadius: OwnerRadius.radiusMd,
                          ),
                          child: Icon(
                            item.icon,
                            color: OwnerColors.actionPrimary,
                          ),
                        ),
                        const SizedBox(width: OwnerSpacing.md),
                        Text(item.label, style: OwnerTypography.body),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
