import 'package:flutter/material.dart';
import 'package:health_mate/core/theme/owner/owner_design_system.dart';

/// 디자인 토큰 사용 예시 화면
///
/// 신규 화면 개발 시 참고용. 라우트에 연결하지 않으면 미사용.
class OwnerDesignExampleScreen extends StatelessWidget {
  const OwnerDesignExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerColors.bgPrimary,
      appBar: AppBar(
        title: const Text('디자인 토큰 예시'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: OwnerSpacing.base,
          vertical: OwnerSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SECTION LABEL', style: OwnerTypography.overline),
            const SizedBox(height: OwnerSpacing.xs),
            const Text('오늘의 약속', style: OwnerTypography.h1),
            const SizedBox(height: OwnerSpacing.xs),
            Text(
              '모아와 함께 작은 약속 하나만 지켜요',
              style: OwnerTypography.bodySm,
            ),
            const SizedBox(height: OwnerSpacing.xl),
            Container(
              padding: OwnerSpacing.cardDefault,
              decoration: BoxDecoration(
                color: OwnerColors.bgSurface,
                borderRadius: OwnerRadius.radiusLg,
                border: Border.all(
                  color: OwnerColors.borderDefault,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘 딱 하나만',
                    style: OwnerTypography.caption.copyWith(
                      color: OwnerColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: OwnerSpacing.sm),
                  const Text(
                    '저녁 먹고\n20분 산책하기',
                    style: OwnerTypography.h2,
                  ),
                  const SizedBox(height: OwnerSpacing.md),
                  Wrap(
                    spacing: OwnerSpacing.sm,
                    children: const [
                      _ExampleChip(label: '약 110 kcal'),
                      _ExampleChip(label: '저녁 8시'),
                    ],
                  ),
                  const SizedBox(height: OwnerSpacing.lg),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('약속할게요'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OwnerSpacing.xl),
            const Text('모아의 상태', style: OwnerTypography.h2),
            const SizedBox(height: OwnerSpacing.md),
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icon: Icons.bolt,
                    label: '에너지',
                    value: 80,
                    color: OwnerColors.statEnergy,
                  ),
                ),
                SizedBox(width: OwnerSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop,
                    label: '수분',
                    value: 50,
                    color: OwnerColors.statHydration,
                  ),
                ),
                SizedBox(width: OwnerSpacing.sm),
                Expanded(
                  child: _StatCard(
                    icon: Icons.bedtime,
                    label: '휴식',
                    value: 70,
                    color: OwnerColors.statRest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OwnerSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  const _ExampleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OwnerSpacing.sm,
        vertical: OwnerSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: OwnerColors.coral50,
        borderRadius: OwnerRadius.radiusMd,
      ),
      child: Text(
        label,
        style: OwnerTypography.caption.copyWith(
          color: OwnerColors.textBrand,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OwnerSpacing.md),
      decoration: BoxDecoration(
        color: OwnerColors.bgSurface,
        borderRadius: OwnerRadius.radiusLg,
        border: Border.all(
          color: OwnerColors.borderDefault,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: OwnerIconSize.lg, color: color),
          const SizedBox(height: OwnerSpacing.xs),
          Text(
            label,
            style: OwnerTypography.caption,
          ),
          const SizedBox(height: OwnerSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: OwnerMotion.slow,
              curve: OwnerMotion.standard,
              builder: (context, t, child) {
                return LinearProgressIndicator(
                  value: t,
                  minHeight: 4,
                  backgroundColor: OwnerColors.beige100,
                  color: color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
