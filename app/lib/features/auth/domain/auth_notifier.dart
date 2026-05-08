import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_mate/core/di/providers.dart';
import 'package:health_mate/features/auth/data/auth_repository.dart';
import 'package:health_mate/features/auth/data/dto/auth_dto.dart';
import 'package:health_mate/features/users/data/users_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final token = await ref.watch(tokenStorageProvider).getAccessToken();
    if (token == null) return const AuthUnauthenticated();
    try {
      final me = await ref.read(usersRepositoryProvider).getMe();
      return AuthAuthenticated(
        UserDto(
          id: me.id,
          email: me.email,
          name: me.name,
          isOnboardingCompleted: me.isOnboardingCompleted,
        ),
      );
    } catch (_) {
      return const AuthUnauthenticated();
    }
  }

  Future<UserDto> register(RegisterRequest req) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    await repo.register(req);
    final me = await ref.read(usersRepositoryProvider).getMe();
    final user = UserDto(
      id: me.id,
      email: me.email,
      name: me.name,
      isOnboardingCompleted: me.isOnboardingCompleted,
    );
    state = AsyncData(AuthAuthenticated(user));
    return user;
  }

  Future<UserDto> login(LoginRequest req) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    await repo.login(req);
    final me = await ref.read(usersRepositoryProvider).getMe();
    final user = UserDto(
      id: me.id,
      email: me.email,
      name: me.name,
      isOnboardingCompleted: me.isOnboardingCompleted,
    );
    state = AsyncData(AuthAuthenticated(user));
    return user;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthUnauthenticated());
  }
}
