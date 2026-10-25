import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/utils/error_text.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/catalog_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/cart_state.dart';
import '../../state/core_providers.dart';

CartLine lineFromOffer(Offer offer, {required String productId, required String name, String? spec, required bool rx, int quantity = 1}) =>
    CartLine(
      offerId: offer.id,
      productId: productId,
      name: name,
      spec: spec,
      rxRequired: rx,
      branchId: offer.branchId,
      branchName: offer.branchName,
      pharmacyName: offer.pharmacyName,
      unitPrice: offer.price,
      quantity: quantity,
      maxQuantity: offer.availableQuantity,
    );

/// Adds a line to the device cart. If the cart already holds another pharmacy's items, asks before replacing —
/// the selected offer is never switched silently. Returns true when the line ended up in the cart.
Future<bool> addLineToCart(BuildContext context, WidgetRef ref, CartLine line) async {
  final l = context.l10n;
  final notifier = ref.read(cartProvider.notifier);
  var result = notifier.add(line);
  if (result == AddResult.branchMismatch) {
    final current = ref.read(cartProvider).lines.first;
    final replace = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cartBranchMismatchTitle),
        content: Text(l.cartBranchMismatchBody(current.pharmacyName)),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(l.cartKeep)),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            child: Text(l.cartReplace),
          ),
        ],
      ),
    );
    if (replace != true) return false;
    result = notifier.add(line, replace: true);
  }
  if (!context.mounted) return false;
  switch (result) {
    case AddResult.added:
      showSnack(context, l.addedToCart, actionLabel: l.viewCart, onAction: () => context.go(Routes.cart));
      return true;
    case AddResult.limitReached:
      showSnack(context, l.errInsufficientStock);
      return false;
    case AddResult.branchMismatch:
      return false;
  }
}

/// Quick add from a list card: resolves the cheapest in-stock offer (a single request) and adds it.
Future<void> quickAdd(BuildContext context, WidgetRef ref, ProductCard p) async {
  final l = context.l10n;
  final offerId = p.bestOfferId;
  if (offerId == null) return;
  try {
    final offers = await ref.read(catalogRepositoryProvider).offers(p.id);
    final offer = offers.firstWhere((o) => o.id == offerId && o.canBuy, orElse: () => offers.firstWhere((o) => o.canBuy));
    if (!context.mounted) return;
    await addLineToCart(context, ref, lineFromOffer(offer, productId: p.id, name: p.name, spec: p.specLine, rx: p.rxRequired));
  } on StateError {
    if (context.mounted) showSnack(context, l.errOfferUnavailable);
  } on ApiFailure catch (e) {
    if (context.mounted) showSnack(context, errorText(l, e));
  }
}
