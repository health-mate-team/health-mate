import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/core/network/api_client.dart';
import 'package:health_mate/features/codes/data/dto/code_dto.dart';

final codesRepositoryProvider = Provider<CodesRepository>(
  (ref) => CodesRepository(ref.watch(apiClientProvider)),
);

class CodesRepository {
  const CodesRepository(this._client);

  final ApiClient _client;

  Future<Map<String, List<CodeDto>>> fetchGroups(
    List<String> groupIds,
  ) async {
    try {
      final query = groupIds.join(',');
      final resp = await _client.dio.get('/codes?groups=$query');
      final body = resp.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return data.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => CodeDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    } catch (_) {
      return _loadFromBundle(groupIds);
    }
  }

  Future<Map<String, List<CodeDto>>> _loadFromBundle(
    List<String> groupIds,
  ) async {
    final json = await rootBundle.loadString('assets/seed/codes.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    return {
      for (final gid in groupIds)
        if (data.containsKey(gid))
          gid: (data[gid] as List<dynamic>)
              .map((e) => CodeDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    };
  }
}
