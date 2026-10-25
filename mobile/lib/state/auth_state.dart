import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_models.dart';
import 'core_providers.dart';

enum AuthStatus { unknown, guest, authenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.sessionExpired = false});
  final AuthStatus status;
  final UserProfile? user;

  /// True when a previously signed-in session ended involuntarily (refresh rejected); shown once as a message.
  final bool sessionExpired;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isResolved => status != AuthStatus.unknown;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Restores a persisted session at startup. Network failures keep the tokens and treat the user as a guest for now.
  Future<void> restore() async {
    final store = ref.read(tokenStoreProvider);
    if (await store.readRefresh() == null) {
      state = const AuthState(status: AuthStatus.guest);
      return;
    }
    try {
      final user = await ref.read(userRepositoryProvider).me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = (await store.readRefresh()) == null ? const AuthState(status: AuthStatus.guest) : const AuthState(status: AuthStatus.guest);
    }
  }

  Future<void> signedIn(AuthTokens t) async {
    await ref.read(tokenStoreProvider).write(access: t.access, refresh: t.refresh);
    state = AuthState(status: AuthStatus.authenticated, user: t.user);
  }

  void updateUser(UserProfile u) => state = AuthState(status: AuthStatus.authenticated, user: u);

  Future<void> logout() async {
    final store = ref.read(tokenStoreProvider);
    final refresh = await store.readRefresh();
    state = const AuthState(status: AuthStatus.guest);
    await store.clear();
    if (refresh != null) {
      try {
        await ref.read(authRepositoryProvider).logout(refresh);
      } catch (_) {
        // Tokens are already discarded locally; server-side expiry covers the rest.
      }
    }
  }

  /// Called by the API client when refresh was rejected.
  void sessionExpired() {
    if (state.isAuthenticated) {
      ref.read(tokenStoreProvider).clear();
      state = const AuthState(status: AuthStatus.guest, sessionExpired: true);
    }
  }

  void acknowledgeExpiry() {
    if (state.sessionExpired) state = const AuthState(status: AuthStatus.guest);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
