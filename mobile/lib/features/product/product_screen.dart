import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/catalog_models.dart';
import '../../design/product_image.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import '../../state/local_lists.dart';
import '../cart/cart_actions.dart';

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetail, String>((ref, id) {
  ref.watch(localeProvider);
  ref.watch(authProvider.select((a) => a.isAuthenticated)); // re-fetch on sign-in/out so the favorite flag is right
  return ref.watch(catalogRepositoryProvider).product(id);
});

final productOffersProvider = FutureProvider.autoDispose.family<List<Offer>, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).offers(id),
);

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});
  final String productId;
  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String? _selectedOfferId;
  int _qty = 1;
  bool _priceDesc = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(recentlyViewedProvider.notifier).view(widget.productId);
    });
  }

  Offer? _selected(List<Offer> offers) {
    if (offers.isEmpty) return null;
    final byId = offers.where((o) => o.id == _selectedOfferId && o.canBuy);
    if (byId.isNotEmpty) return byId.first;
    final buyable = offers.where((o) => o.canBuy).toList()..sort((a, b) => a.price.compareTo(b.price));
    return buyable.isEmpty ? null : buyable.first;
  }

  Future<void> _toggleFavorite() async {
    try {
      await ref.read(favoritesProvider.notifier).toggle(widget.productId);
    } on ApiFailure catch (e) {
      if (mounted) showSnack(context, errorText(context.l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final detail = ref.watch(productDetailProvider(widget.productId));
    final offersAsync = ref.watch(productOffersProvider(widget.productId));
    final fav = ref.watch(favoritesProvider).contains(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.productTitle),
        actions: [FavoriteButton(active: fav, onPressed: _toggleFavorite)],
      ),
      body: detail.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Sp.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Skeleton(width: 220, height: 220, radius: 24)),
              SizedBox(height: Sp.x6),
              Skeleton(height: 22),
              SizedBox(height: Sp.x3),
              Skeleton(width: 180, height: 14),
              SizedBox(height: Sp.x6),
              Skeleton(height: 100, radius: 16),
            ],
          ),
        ),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () {
            ref.invalidate(productDetailProvider(widget.productId));
            ref.invalidate(productOffersProvider(widget.productId));
          },
        ),
        data: (d) {
          final offers = offersAsync.value ?? const <Offer>[];
          final selected = _selected(offers);
          final maxQty = selected == null ? 1 : (selected.availableQuantity.clamp(1, 99));
          if (_qty > maxQty) _qty = maxQty;
          final sorted = [...offers]
            ..sort((a, b) {
              if (a.canBuy != b.canBuy) return a.canBuy ? -1 : 1;
              return _priceDesc ? b.price.compareTo(a.price) : a.price.compareTo(b.price);
            });
          final bestPrice = offers.where((o) => o.canBuy).map((o) => o.price).fold<double?>(null, (m, p) => m == null || p < m ? p : m);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x6),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          ProductImage(
                            categorySlug: d.card.categorySlug,
                            form: d.card.dosageForm,
                            label: d.card.brand,
                            imageUrl: d.images.isNotEmpty ? d.images.first : null,
                            size: 220,
                            radius: 28,
                            semanticLabel: d.card.name,
                          ),
                          if (d.card.rxRequired)
                            Positioned(
                              left: 10,
                              top: 10,
                              child: Pill(label: l.badgeRx, color: Colors.white, background: context.scheme.primary),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.x5),
                    Wrap(
                      spacing: Sp.x2,
                      runSpacing: 4,
                      children: [
                        if (d.card.brand != null) Pill(label: d.card.brand!, color: context.dm.textSecondary),
                        if (d.card.demo)
                          Pill(label: l.demoBadge, color: const Color(0xFF8A5A00), background: DmPalette.warning.withValues(alpha: 0.2)),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    Semantics(header: true, child: Text(d.card.name, style: context.text.headlineSmall)),
                    if (d.card.specLine.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(d.card.specLine, style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary)),
                      ),
                    const SizedBox(height: Sp.x3),
                    if (selected != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PriceText(price: selected.price, oldPrice: selected.oldPrice, style: context.text.headlineMedium),
                          const SizedBox(width: Sp.x3),
                          StockPill(
                            availability: selected.availability,
                            count: selected.availability == Availability.lowStock ? selected.availableQuantity : null,
                          ),
                        ],
                      )
                    else if (offersAsync.isLoading)
                      const Skeleton(width: 140, height: 28)
                    else
                      Row(
                        children: [Text(l.stockOut, style: context.text.titleMedium?.copyWith(color: context.scheme.error))],
                      ),
                    if (d.card.rxRequired) ...[
                      const SizedBox(height: Sp.x3),
                      InfoPanel(icon: Icons.description_outlined, text: l.rxNeededNote),
                    ],
                    const SizedBox(height: Sp.x6),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(header: true, child: Text(l.offersTitle, style: context.text.titleMedium)),
                        ),
                        if (offers.length > 1)
                          TextButton.icon(
                            onPressed: () => setState(() => _priceDesc = !_priceDesc),
                            icon: Icon(_priceDesc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 18),
                            label: Text(_priceDesc ? l.sortPriceDesc : l.sortPriceAsc),
                          ),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    offersAsync.when(
                      loading: () => const Column(
                        children: [Skeleton(height: 96, radius: 20), SizedBox(height: 12), Skeleton(height: 96, radius: 20)],
                      ),
                      error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(productOffersProvider(widget.productId))),
                      data: (_) => offers.isEmpty
                          ? EmptyState(icon: Icons.storefront_outlined, title: l.offersNone)
                          : Column(
                              children: [
                                for (final o in sorted)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: Sp.x3),
                                    child: _OfferTile(
                                      offer: o,
                                      selected: selected?.id == o.id,
                                      best: bestPrice != null && o.canBuy && o.price == bestPrice,
                                      onSelect: o.canBuy ? () => setState(() => _selectedOfferId = o.id) : null,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: Sp.x4),
                    _InfoTable(card: d.card),
                    if (d.description != null && d.description!.isNotEmpty) ...[
                      const SizedBox(height: Sp.x6),
                      Text(l.prodDescription, style: context.text.titleMedium),
                      const SizedBox(height: Sp.x2),
                      Text(d.description!, style: context.text.bodyMedium),
                    ],
                    const SizedBox(height: Sp.x5),
                    if (d.officialInfo.isEmpty)
                      InfoPanel(icon: Icons.info_outline_rounded, text: l.prodInfoUnavailable)
                    else
                      for (final s in d.officialInfo) _OfficialSection(section: s),
                    const SizedBox(height: Sp.x4),
                    if (d.card.demo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Sp.x3),
                        child: InfoPanel(
                          icon: Icons.science_outlined,
                          text: l.demoDataNote,
                          tint: DmPalette.warning.withValues(alpha: 0.12),
                        ),
                      ),
                    Text(l.medicalDisclaimer, style: context.text.bodySmall),
                  ],
                ),
              ),
              _BottomBar(
                enabled: selected != null,
                quantity: _qty,
                maxQty: maxQty,
                onQty: (q) => setState(() => _qty = q),
                total: selected == null ? null : selected.price * _qty,
                onAdd: selected == null
                    ? null
                    : () => addLineToCart(
                        context,
                        ref,
                        lineFromOffer(
                          selected,
                          productId: d.card.id,
                          name: d.card.name,
                          spec: d.card.specLine,
                          rx: d.card.rxRequired,
                          quantity: _qty,
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.enabled,
    required this.quantity,
    required this.maxQty,
    required this.onQty,
    required this.total,
    required this.onAdd,
  });
  final bool enabled;
  final int quantity;
  final int maxQty;
  final ValueChanged<int> onQty;
  final double? total;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Material(
      elevation: 8,
      color: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x3, Sp.gutter, Sp.x3),
          child: Row(
            children: [
              QuantityStepper(quantity: quantity, max: maxQty, onChanged: enabled ? onQty : (_) {}),
              const SizedBox(width: Sp.x3),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(
                    total == null ? l.addToCart : '${l.addToCart} · ${formatMoney(total!, context.localeCode)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.selected, required this.best, required this.onSelect});
  final Offer offer;
  final bool selected;
  final bool best;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeCode;
    final fee = offer.deliveryFee;
    return Opacity(
      opacity: offer.canBuy ? 1 : 0.6,
      child: Semantics(
        selected: selected,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Sp.radiusLg),
            border: Border.all(color: selected ? context.scheme.primary : context.dm.cardBorder, width: selected ? 2 : 1),
          ),
          child: Material(
            color: selected ? context.dm.paleAqua : Colors.transparent,
            borderRadius: BorderRadius.circular(Sp.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(Sp.radiusLg),
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.all(Sp.x3 + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.pharmacyName, style: context.text.titleSmall),
                              Text(offer.address, style: context.text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PriceText(price: offer.price, oldPrice: offer.oldPrice, style: context.text.titleMedium),
                            if (best)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Pill(label: l.offersBestPrice, color: context.dm.success),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    Wrap(
                      spacing: Sp.x2,
                      runSpacing: 4,
                      children: [
                        StockPill(
                          availability: offer.availability,
                          count: offer.availability == Availability.lowStock ? offer.availableQuantity : null,
                        ),
                        if (offer.pickupAvailable)
                          Pill(label: l.offerPickup, color: context.dm.textSecondary, icon: Icons.storefront_outlined),
                        Pill(
                          label: offer.deliveryAvailable
                              ? l.offerDeliveryFee(fee == 0 ? l.free.toLowerCase() : formatMoney(fee, loc))
                              : l.offerNoDelivery,
                          color: context.dm.textSecondary,
                          icon: Icons.local_shipping_outlined,
                        ),
                      ],
                    ),
                    if (offer.deliveryAvailable && offer.etaMin != null && offer.etaMax != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Sp.x2),
                        child: Text(
                          '${l.offerEta(offer.etaMin!, offer.etaMax!)}${offer.freeDeliveryFrom != null ? ' · ${l.offerFreeFrom(formatMoney(offer.freeDeliveryFrom!, loc))}' : ''}',
                          style: context.text.bodySmall,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(l.offerUpdated(formatDateTime(offer.updatedAt, loc)), style: context.text.bodySmall)),
                          if (offer.demoPharmacy) Text(l.pharmacyDemoNote, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    if (onSelect != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Sp.x2),
                        child: Row(
                          children: [
                            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: context.scheme.primary),
                            const SizedBox(width: Sp.x2),
                            Text(
                              selected ? l.offerSelected : l.selectOffer,
                              style: context.text.labelMedium?.copyWith(color: context.scheme.primary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.card});
  final ProductCard card;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(String, String?)>[
      (l.prodBrand, card.brand),
      (l.prodIngredient, card.activeIngredient),
      (l.prodStrength, card.strength),
      (l.prodForm, card.dosageForm),
      (l.prodPackage, card.packageSize),
      (l.prodManufacturer, card.manufacturer),
    ].where((r) => r.$2 != null && r.$2!.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return DmCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sp.x2 + 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: Text(rows[i].$1, style: context.text.bodySmall)),
                  Expanded(
                    flex: 6,
                    child: Text(rows[i].$2!, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _OfficialSection extends StatelessWidget {
  const _OfficialSection({required this.section});
  final InfoSection section;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = switch (section.section) {
      'USAGE' => l.prodUsage,
      'STORAGE' => l.prodStorage,
      'WARNINGS' => l.prodWarnings,
      'CONTRAINDICATIONS' => l.prodContraindications,
      'COMPOSITION' => l.prodComposition,
      _ => section.section,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: Sp.x2),
          Text(section.body, style: context.text.bodyMedium),
          const SizedBox(height: 4),
          Text(l.prodInfoSource(section.source), style: context.text.bodySmall),
        ],
      ),
    );
  }
}
