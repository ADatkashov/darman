import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/data_providers.dart';
import '../../state/local_lists.dart';
import '../cart/cart_actions.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final authed = ref.watch(authProvider.select((a) => a.isAuthenticated));
    ref.watch(favoritesProvider); // rebuild list when the set changes
    final cards = ref.watch(favoriteCardsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.favoritesTitle)),
      body: cards.when(
        loading: () => const ListSkeleton(count: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(favoriteCardsProvider)),
        data: (items) {
          final favs = ref.watch(favoritesProvider);
          final visible = items.where((p) => favs.contains(p.id)).toList();
          if (visible.isEmpty)
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: l.favoritesEmpty,
              body: l.favoritesEmptyBody,
              actionLabel: l.goToCatalog,
              onAction: () => context.go(Routes.home),
            );
          return ListView(
            padding: const EdgeInsets.all(Sp.gutter),
            children: [
              if (!authed)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: InfoPanel(icon: Icons.info_outline, text: l.favoritesGuestNote),
                ),
              for (final p in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: ProductRow(
                    product: p,
                    onTap: () => context.push(Routes.product(p.id)),
                    onAdd: () => quickAdd(context, ref, p),
                    trailing: FavoriteButton(
                      active: true,
                      onPressed: () async {
                        try {
                          await ref.read(favoritesProvider.notifier).toggle(p.id);
                        } on ApiFailure catch (e) {
                          if (context.mounted) showSnack(context, errorText(l, e));
                        }
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
