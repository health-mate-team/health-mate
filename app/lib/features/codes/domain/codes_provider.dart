import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/features/codes/data/codes_repository.dart';
import 'package:health_mate/features/codes/data/dto/code_dto.dart';

const _allGroups = ['mood', 'evening_mood', 'goal_option'];

final codesProvider =
    FutureProvider<Map<String, List<CodeDto>>>((ref) async {
  final repo = ref.watch(codesRepositoryProvider);
  return repo.fetchGroups(_allGroups);
});

final codeGroupProvider = Provider.family<AsyncValue<List<CodeDto>>, String>(
  (ref, groupId) {
    return ref.watch(codesProvider).whenData(
          (data) => data[groupId] ?? const [],
        );
  },
);
