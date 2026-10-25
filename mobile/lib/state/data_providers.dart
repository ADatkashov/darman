import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/catalog_models.dart';
import '../data/models/order_models.dart';
import '../data/models/prescription_models.dart';
import '../data/models/user_models.dart';
import 'auth_state.dart';
import 'core_providers.dart';

/// Providers that require a signed-in user watch [authProvider] so they reset when the session changes.
final addressesProvider = FutureProvider.autoDispose<List<Address>>((ref) {
  ref.watch(authProvider.select((a) => a.user?.id));
  return ref.watch(userRepositoryProvider).addresses();
});

final slotsProvider = FutureProvider.autoDispose.family<SlotsInfo, String>(
  (ref, branchId) => ref.watch(catalogRepositoryProvider).slots(branchId),
);

final ordersProvider = FutureProvider.autoDispose.family<List<OrderSummary>, String>((ref, scope) {
  ref.watch(authProvider.select((a) => a.user?.id));
  return ref.watch(orderRepositoryProvider).list(scope);
});

final orderDetailProvider = FutureProvider.autoDispose.family<OrderDetail, String>((ref, id) => ref.watch(orderRepositoryProvider).get(id));

final prescriptionsProvider = FutureProvider.autoDispose<List<Prescription>>((ref) {
  ref.watch(authProvider.select((a) => a.user?.id));
  return ref.watch(prescriptionRepositoryProvider).list();
});

final prescriptionDetailProvider = FutureProvider.autoDispose.family<Prescription, String>(
  (ref, id) => ref.watch(prescriptionRepositoryProvider).get(id),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) {
  ref.watch(authProvider.select((a) => a.user?.id));
  return ref.watch(userRepositoryProvider).notifications();
});

/// Favorites as full cards (server for signed-in users, by-ids lookup of the local set for guests).
final favoriteCardsProvider = FutureProvider.autoDispose<List<ProductCard>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.isAuthenticated) return ref.watch(userRepositoryProvider).favorites();
  final ids = ref.read(sharedPrefsProvider).getStringList('favorites.guest') ?? const [];
  return ref.watch(catalogRepositoryProvider).byIds(ids);
});
