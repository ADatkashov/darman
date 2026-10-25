import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_store.dart';
import '../data/models/catalog_models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/prescription_repository.dart';
import '../data/repositories/user_repository.dart';
import 'auth_state.dart';

/// Overridden in `main()` once SharedPreferences has been loaded.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'));

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

const supportedLocales = [Locale('ru'), Locale('kk'), Locale('en')];

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'pref.locale';

  @override
  Locale build() {
    final code = ref.read(sharedPrefsProvider).getString(_key);
    return supportedLocales.firstWhere((l) => l.languageCode == code, orElse: () => const Locale('ru'));
  }

  Future<void> set(Locale l) async {
    state = l;
    await ref.read(sharedPrefsProvider).setString(_key, l.languageCode);
    // Best effort: keep the account's language in sync so server-side texts follow the app.
    if (ref.read(authProvider).isAuthenticated) {
      try {
        await ref.read(userRepositoryProvider).update(locale: l.languageCode);
      } catch (_) {}
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'pref.theme';
  @override
  ThemeMode build() => switch (ref.read(sharedPrefsProvider).getString(_key)) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light, // light is the initial default
  };

  Future<void> set(ThemeMode m) async {
    state = m;
    await ref.read(sharedPrefsProvider).setString(_key, m.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Whether the last network call reached the server. Drives the offline banner.
class ReachabilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool ok) {
    if (state != ok) state = ok;
  }
}

final reachabilityProvider = NotifierProvider<ReachabilityNotifier, bool>(ReachabilityNotifier.new);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokens: ref.watch(tokenStoreProvider),
    locale: () => ref.read(localeProvider).languageCode,
    onSessionExpired: () => ref.read(authProvider.notifier).sessionExpired(),
    onReachability: (ok) => ref.read(reachabilityProvider.notifier).set(ok),
  );
});

final catalogRepositoryProvider = Provider((ref) => CatalogRepository(ref.watch(apiClientProvider)));
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));
final userRepositoryProvider = Provider((ref) => UserRepository(ref.watch(apiClientProvider)));
final orderRepositoryProvider = Provider((ref) => OrderRepository(ref.watch(apiClientProvider)));
final prescriptionRepositoryProvider = Provider((ref) => PrescriptionRepository(ref.watch(apiClientProvider)));

/// Server runtime flags (demo mode, payment availability). Falls back to a conservative config when offline.
final runtimeConfigProvider = FutureProvider<RuntimeConfig>((ref) async {
  try {
    return await ref.watch(catalogRepositoryProvider).config();
  } catch (_) {
    return RuntimeConfig.fallback;
  }
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  ref.watch(localeProvider);
  return ref.watch(catalogRepositoryProvider).categories();
});

final bannersProvider = FutureProvider<List<PromoBanner>>((ref) {
  ref.watch(localeProvider);
  return ref.watch(catalogRepositoryProvider).banners();
});

final branchesProvider = FutureProvider<List<Branch>>((ref) => ref.watch(catalogRepositoryProvider).branches());

/// Home shelves, loaded independently so one failure doesn't blank the screen.
final popularProductsProvider = FutureProvider<List<ProductCard>>(
  (ref) async => (await ref.watch(catalogRepositoryProvider).search(const SearchQuery(sort: 'popularity', inStock: true), size: 10)).items,
);

final frequentProductsProvider = FutureProvider<List<ProductCard>>(
  (ref) async =>
      (await ref
              .watch(catalogRepositoryProvider)
              .search(const SearchQuery(sort: 'popularity', inStock: true, rxRequired: false), page: 1, size: 10))
          .items,
);

final saleProductsProvider = FutureProvider<List<ProductCard>>(
  (ref) async => (await ref.watch(catalogRepositoryProvider).search(const SearchQuery(onSale: true, sort: 'popularity'), size: 10)).items,
);
