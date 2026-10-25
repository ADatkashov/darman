import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cart_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/cart_state.dart';
import 'checkout_math.dart';
import 'quote_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promo = TextEditingController();
  bool _promoBusy = false;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promo.text.trim();
    if (code.isEmpty) return;
    setState(() => _promoBusy = true);
    ref.read(promoCodeProvider.notifier).set(code);
    try {
      final q = await ref.refresh(quoteProvider.future);
      if (mounted && !q.promoApplied) {
        final reason = q.promo?.reason;
        showSnack(context, reason == 'MIN_ORDER_NOT_REACHED' ? context.l10n.cartPromoMin : context.l10n.cartPromoInvalid);
        ref.read(promoCodeProvider.notifier).set(null);
      }
    } catch (_) {
      if (mounted) {
        showSnack(context, context.l10n.cartCheckFailed);
        ref.read(promoCodeProvider.notifier).set(null);
      }
    } finally {
      if (mounted) setState(() => _promoBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cart = ref.watch(cartProvider);
    final quote = ref.watch(quoteProvider);
    final loc = context.localeCode;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.cartTitle)),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: l.cartEmptyTitle,
          body: l.cartEmptyBody,
          actionLabel: l.goToCatalog,
          onAction: () => context.go(Routes.home),
        ),
      );
    }

    final validation = quote.value?.validation;
    final blocked = validation?.checkoutBlocked ?? false;
    final totals = computeTotals(subtotal: validation?.subtotal ?? cart.subtotal, discount: quote.value?.discount ?? 0, pickup: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.cartTitle),
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text(l.cartClearConfirm),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: Text(l.cancel)),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
                      child: Text(l.delete),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                ref.read(cartProvider.notifier).clear();
                ref.read(promoCodeProvider.notifier).set(null);
              }
            },
            child: Text(l.cartClear),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: Row(
                    children: [
                      Icon(Icons.local_pharmacy_outlined, size: 18, color: context.scheme.primary),
                      const SizedBox(width: Sp.x2),
                      Expanded(child: Text(l.cartPharmacy(cart.pharmacyLabel ?? ''), style: context.text.titleSmall)),
                      Text(l.cartItems(cart.itemCount), style: context.text.bodySmall),
                    ],
                  ),
                ),
                for (final line in cart.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: _LineCard(line: line, validated: validation?.lineFor(line.offerId)),
                  ),
                if (quote.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: InfoPanel(icon: Icons.cloud_off_outlined, text: l.cartCheckFailed),
                  ),
                if (blocked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: InfoPanel(
                      icon: Icons.warning_amber_rounded,
                      text: l.cartFixIssues,
                      tint: DmPalette.warning.withValues(alpha: 0.14),
                    ),
                  ),
                if (cart.hasRx || (validation?.prescriptionRequired ?? false))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: InfoPanel(icon: Icons.description_outlined, text: l.cartRxNeeded),
                  ),
                _PromoBox(
                  controller: _promo,
                  busy: _promoBusy,
                  onApply: _applyPromo,
                  quote: quote.value,
                  onClear: () {
                    ref.read(promoCodeProvider.notifier).set(null);
                    _promo.clear();
                  },
                ),
                if (validation?.delivery != null) ...[
                  const SizedBox(height: Sp.x3),
                  _DeliveryHint(terms: validation!.delivery!, subtotal: validation.subtotal),
                ],
              ],
            ),
          ),
          Material(
            elevation: 10,
            shadowColor: Colors.black26,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x3, Sp.gutter, Sp.x3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SumRow(l.cartSubtotal, formatMoney(totals.subtotal, loc)),
                    if (totals.discount > 0) _SumRow(l.cartDiscount, '−${formatMoney(totals.discount, loc)}', color: context.dm.success),
                    const SizedBox(height: Sp.x1),
                    Row(
                      children: [
                        Expanded(child: Text(l.cartTotal, style: context.text.titleMedium)),
                        quote.isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(formatMoney(totals.total, loc), style: context.text.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: Sp.x3),
                    FilledButton(
                      onPressed: blocked || quote.isLoading ? null : () => context.push(Routes.checkout),
                      child: Text(l.cartCheckout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary)),
        ),
        Text(
          value,
          style: context.text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _LineCard extends ConsumerWidget {
  const _LineCard({required this.line, required this.validated});
  final CartLine line;
  final ValidatedLine? validated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final notifier = ref.read(cartProvider.notifier);
    final status = validated?.status ?? LineStatus.ok;
    final unavailable = status == LineStatus.outOfStock || status == LineStatus.unavailable;
    final maxQ = validated != null && validated!.availableQuantity > 0
        ? validated!.availableQuantity
        : (line.maxQuantity > 0 ? line.maxQuantity : 99);
    final shownPrice = validated != null && status != LineStatus.unavailable ? validated!.unitPrice : line.unitPrice;

    return DmCard(
      padding: const EdgeInsets.all(Sp.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: context.dm.softMint, borderRadius: BorderRadius.circular(14)),
                child: Icon(line.rxRequired ? Icons.description_outlined : Icons.medication_outlined, color: context.scheme.primary),
              ),
              const SizedBox(width: Sp.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (line.spec != null && line.spec!.isNotEmpty)
                      Text(line.spec!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${formatMoney(shownPrice, loc)} × ${line.quantity}', style: context.text.bodySmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.cartRemoveItem(line.name),
                onPressed: () => notifier.remove(line.offerId),
                icon: Icon(Icons.delete_outline_rounded, color: context.dm.textSecondary),
              ),
            ],
          ),
          if (status != LineStatus.ok) ...[const SizedBox(height: Sp.x2), _Issue(line: line, validated: validated!)],
          const SizedBox(height: Sp.x2),
          Row(
            children: [
              if (!unavailable)
                QuantityStepper(quantity: line.quantity, max: maxQ, onChanged: (q) => notifier.setQuantity(line.offerId, q)),
              const Spacer(),
              Text(formatMoney(unavailable ? 0 : shownPrice * line.quantity, loc), style: context.text.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _Issue extends ConsumerWidget {
  const _Issue({required this.line, required this.validated});
  final CartLine line;
  final ValidatedLine validated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final notifier = ref.read(cartProvider.notifier);
    final (String text, String? action, VoidCallback? onAction, Color color) = switch (validated.status) {
      LineStatus.priceChanged => (
        l.cartIssuePrice(formatMoney(validated.previousPrice ?? line.unitPrice, loc), formatMoney(validated.unitPrice, loc)),
        l.ok,
        () => notifier.applyServerLine(line.offerId, unitPrice: validated.unitPrice, availableQuantity: validated.availableQuantity),
        const Color(0xFF9A6200),
      ),
      LineStatus.lowStock => (
        l.cartIssueLow(validated.availableQuantity),
        validated.availableQuantity > 0 ? l.apply : null,
        validated.availableQuantity > 0
            ? () => notifier.applyServerLine(line.offerId, unitPrice: validated.unitPrice, availableQuantity: validated.availableQuantity)
            : null,
        const Color(0xFF9A6200),
      ),
      LineStatus.outOfStock => (l.cartIssueOut, l.remove, () => notifier.remove(line.offerId), context.scheme.error),
      LineStatus.unavailable => (l.cartIssueUnavailable, l.remove, () => notifier.remove(line.offerId), context.scheme.error),
      LineStatus.ok => ('', null, null, Colors.transparent),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: color),
            const SizedBox(width: Sp.x2),
            Expanded(
              child: Text(
                text,
                style: context.text.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(minimumSize: const Size(48, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
                child: Text(action),
              ),
          ],
        ),
      ),
    );
  }
}

class _PromoBox extends StatelessWidget {
  const _PromoBox({required this.controller, required this.busy, required this.onApply, required this.quote, required this.onClear});
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onApply;
  final Quote? quote;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final applied = quote?.promoApplied ?? false;
    return DmCard(
      padding: const EdgeInsets.all(Sp.x3),
      child: applied
          ? Row(
              children: [
                Icon(Icons.local_offer_outlined, color: context.dm.success),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: Text(
                    l.cartPromoApplied(formatMoney(quote!.discount, context.localeCode)),
                    style: context.text.bodyMedium?.copyWith(color: context.dm.success, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(onPressed: onClear, child: Text(l.remove)),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onApply(),
                    decoration: InputDecoration(
                      labelText: l.cartPromo,
                      hintText: l.cartPromoHint,
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: Sp.x2),
                FilledButton(
                  onPressed: busy ? null : onApply,
                  style: FilledButton.styleFrom(minimumSize: const Size(88, 52)),
                  child: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.apply),
                ),
              ],
            ),
    );
  }
}

class _DeliveryHint extends StatelessWidget {
  const _DeliveryHint({required this.terms, required this.subtotal});
  final DeliveryTerms terms;
  final double subtotal;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeCode;
    if (!terms.deliveryAvailable) return InfoPanel(icon: Icons.storefront_outlined, text: l.cartDeliveryUnavailable);
    final parts = <String>[
      l.offerDeliveryFee(terms.fee == 0 ? l.free.toLowerCase() : formatMoney(terms.fee, loc)),
      if (terms.freeFrom != null && subtotal < terms.freeFrom!) l.cartFreeDeliveryFrom(formatMoney(terms.freeFrom!, loc)),
      if (terms.etaMin != null && terms.etaMax != null) l.offerEta(terms.etaMin!, terms.etaMax!),
    ];
    return InfoPanel(icon: Icons.local_shipping_outlined, text: parts.join(' · '));
  }
}
