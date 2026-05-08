import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/cycle/data/cycle_repository.dart';
import 'package:health_mate/features/cycle/data/dto/cycle_dto.dart';

final cycleProvider =
    AsyncNotifierProvider<CycleNotifier, CycleCurrentDto>(CycleNotifier.new);

class CycleNotifier extends AsyncNotifier<CycleCurrentDto> {
  @override
  Future<CycleCurrentDto> build() =>
      ref.watch(cycleRepositoryProvider).getCurrent();

  Future<void> updateSettings(CycleSettingsRequest req) async {
    final updated =
        await ref.read(cycleRepositoryProvider).updateSettings(req);
    state = AsyncData(updated);
  }
}
