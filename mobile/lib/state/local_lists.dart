import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';
import 'core_providers.dart';

/// Recent search queries (device-local, most recent first).
class RecentSearchesNotifier extends Notifier<List<String>> {
  static const _key = 'search.recent';
  @override
  List<String> build() => ref.read(sharedPrefsProvider).getStringList(_key) ?? const [];

  void add(String q) {
    final t = q.trim();
    if (t.length < 2) return;
    final next = [t, ...state.where((e) => e.toLowerCase() != t.toLowerCase())].take(10).toList();
    state = next;
    ref.read(sharedPrefsProvider).setStringList(_key, next);
  }

  void remove(String q) {
    state = state.where((e) => e != q).toList();
    ref.read(sharedPrefsProvider).setStringList(_key, state);
  }

  void clear() {
    state = const [];
    ref.read(sharedPrefsProvider).remove(_key);
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

/// Product ids the user opened recently (device-local).
class RecentlyViewedNotifier extends Notifier<List<String>> {
  static const _key = 'viewed.recent';
  @override
  List<String> build() => ref.read(sharedPrefsProvider).getStringList(_key) ?? const [];

  void view(String productId) {
    final next = [productId, ...state.where((e) => e != productId)].take(12).toList();
    state = next;
    ref.read(sharedPrefsProvider).setStringList(_key, next);
  }
}

final recentlyViewedProvider = NotifierProvider<RecentlyViewedNotifier, List<String>>(RecentlyViewedNotifier.new);

/// Favorites: synced with the server for signed-in users; kept on the device for guests and merged on sign-in.
class FavoritesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorites.guest';

  @override
  Set<String> build() {
    ref.listen(authProvider, (prev, next) {
      if (next.isAuthenticated && !(prev?.isAuthenticated ?? false)) {
        _onSignedIn();
      } else if (!next.isAuthenticated && (prev?.isAuthenticated ?? false)) {
        state = ref.read(sharedPrefsProvider).getStringList(_key)?.toSet() ?? {};
      }
    });
    if (ref.read(authProvider).isAuthenticated) {
      Future.microtask(_loadRemote);
    }
    return ref.read(sharedPrefsProvider).getStringList(_key)?.toSet() ?? {};
  }

  Future<void> _loadRemote() async {
    try {
      final remote = await ref.read(userRepositoryProvider).favorites();
      state = remote.map((e) => e.id).toSet();
    } catch (_) {}
  }

  Future<void> _onSignedIn() async {
    final prefs = ref.read(sharedPrefsProvider);
    final guest = prefs.getStringList(_key) ?? const [];
    final repo = ref.read(userRepositoryProvider);
    for (final id in guest) {
      try {
        await repo.addFavorite(id);
      } catch (_) {}
    }
    await prefs.remove(_key);
    await _loadRemote();
  }

  bool isFavorite(String productId) => state.contains(productId);

  Future<void> toggle(String productId) async {
    final was = state.contains(productId);
    state = was ? ({...state}..remove(productId)) : {...state, productId};
    if (ref.read(authProvider).isAuthenticated) {
      try {
        final repo = ref.read(userRepositoryProvider);
        was ? await repo.removeFavorite(productId) : await repo.addFavorite(productId);
      } catch (_) {
        state = was ? {...state, productId} : ({...state}..remove(productId)); // roll back
        rethrow;
      }
    } else {
      await ref.read(sharedPrefsProvider).setStringList(_key, state.toList());
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
