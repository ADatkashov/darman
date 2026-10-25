import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/cart_state.dart';
import '../../state/core_providers.dart';

/// Persistent bottom navigation with five destinations. Tab state is preserved by the indexed stack;
/// Android back from any other tab returns to Home before leaving the app.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cartCount = ref.watch(cartProvider.select((c) => c.itemCount));
    final online = ref.watch(reachabilityProvider);
    final demo = ref.watch(runtimeConfigProvider).maybeWhen(data: (c) => c.demoMode, orElse: () => false);

    Widget cartIcon(bool selected) => Badge(
      isLabelVisible: cartCount > 0,
      label: Text(cartCount > 99 ? '99+' : '$cartCount'),
      child: Icon(selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined),
    );

    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: Column(
          children: [
            if (!online) const SafeArea(bottom: false, child: OfflineBanner()),
            if (demo && online) SafeArea(bottom: false, child: DemoBanner(compact: true)),
            Expanded(child: shell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l.navHome),
            NavigationDestination(
              icon: const Icon(Icons.search_rounded),
              selectedIcon: const Icon(Icons.search_rounded),
              label: l.navSearch,
            ),
            NavigationDestination(icon: cartIcon(false), selectedIcon: cartIcon(true), label: l.navCart),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l.navOrders,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
