import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../data/models/catalog_models.dart';
import '../../design/logo.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import '../../state/local_lists.dart';
import '../cart/cart_actions.dart';

final recentProductsProvider = FutureProvider.autoDispose<List<ProductCard>>((ref) {
  final ids = ref.watch(recentlyViewedProvider);
  return ref.watch(catalogRepositoryProvider).byIds(ids.take(10).toList());
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(bannersProvider);
    ref.invalidate(popularProductsProvider);
    ref.invalidate(frequentProductsProvider);
    ref.invalidate(saleProductsProvider);
    ref.invalidate(branchesProvider);
    ref.invalidate(recentProductsProvider);
    try {
      await ref.read(popularProductsProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final categories = ref.watch(categoriesProvider);
    final branches = ref.watch(branchesProvider);
    final recent = ref.watch(recentlyViewedProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(child: _SearchBar()),
              const SliverToBoxAdapter(child: _BannerCarousel()),
              SliverToBoxAdapter(child: SectionHeader(title: l.homeCategories)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 108,
                  child: categories.when(
                    data: (list) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Sp.x3),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(width: Sp.x1),
                      itemBuilder: (_, i) => CategoryTile(category: list[i], onTap: () => context.go(Routes.searchCategory(list[i].slug))),
                    ),
                    loading: () => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(width: Sp.x4),
                      itemBuilder: (_, _) => const Column(
                        children: [Skeleton(width: 60, height: 60, radius: 20), SizedBox(height: 8), Skeleton(width: 56, height: 10)],
                      ),
                    ),
                    error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(categoriesProvider)),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _RxEntry()),
              SliverToBoxAdapter(
                child: branches.maybeWhen(
                  data: (bs) {
                    final delivering = bs.where((b) => b.deliveryAvailable && b.etaMin != null && b.etaMax != null).toList();
                    if (delivering.isEmpty) return const SizedBox.shrink();
                    final min = delivering.map((b) => b.etaMin!).reduce((a, b) => a < b ? a : b);
                    final max = delivering.map((b) => b.etaMax!).reduce((a, b) => a > b ? a : b);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x4, Sp.gutter, 0),
                      child: InfoPanel(icon: Icons.local_shipping_outlined, text: l.homeDeliveryInfo(min, max)),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              _Shelf(
                title: l.homePopular,
                provider: popularProductsProvider,
                retry: (r) => r.invalidate(popularProductsProvider),
                onSeeAll: () => context.go('${Routes.search}?q='),
              ),
              _Shelf(
                title: l.homeOffers,
                provider: saleProductsProvider,
                retry: (r) => r.invalidate(saleProductsProvider),
                onSeeAll: () => context.go('${Routes.search}?sale=1'),
                hideWhenEmpty: true,
              ),
              _Shelf(title: l.homeFrequent, provider: frequentProductsProvider, retry: (r) => r.invalidate(frequentProductsProvider)),
              SliverToBoxAdapter(
                child: SectionHeader(title: l.homeNearby, onSeeAll: () => context.push(Routes.pharmacies)),
              ),
              SliverToBoxAdapter(
                child: branches.when(
                  data: (bs) => Column(
                    children: [
                      for (final b in bs.take(3))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x3),
                          child: _BranchCard(branch: b),
                        ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Sp.gutter),
                    child: Skeleton(height: 88, radius: 20),
                  ),
                  error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(branchesProvider)),
                ),
              ),
              if (recent.isNotEmpty)
                _Shelf(title: l.homeRecent, provider: recentProductsProvider, retry: (r) => r.invalidate(recentProductsProvider)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Sp.gutter),
                  child: Text(l.medicalDisclaimer, style: context.text.bodySmall),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: Sp.x6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final authed = ref.watch(authProvider.select((a) => a.isAuthenticated));
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x3, Sp.x2, 0),
      child: Row(
        children: [
          const DarmanLogo(height: 34),
          const Spacer(),
          ActionChip(
            avatar: Icon(Icons.location_on_outlined, size: 18, color: context.scheme.primary),
            label: const Text('Алматы'),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.x4, 0, Sp.x4, Sp.x6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.homeCity, style: context.text.titleMedium),
                      const SizedBox(height: Sp.x3),
                      const ListTile(
                        leading: Icon(Icons.radio_button_checked, color: DmPalette.emerald),
                        title: Text('Алматы'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                        child: Text(l.homeCitySoon, style: context.text.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.profileNotifications,
            onPressed: () =>
                context.push(authed ? Routes.notifications : '${Routes.login}?from=${Uri.encodeComponent(Routes.notifications)}'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x3, Sp.gutter, 0),
      child: Semantics(
        button: true,
        label: l.homeSearchHint,
        child: InkWell(
          borderRadius: BorderRadius.circular(Sp.radiusPill),
          onTap: () => context.go('${Routes.search}?q=&focus=${DateTime.now().millisecondsSinceEpoch}'),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
            decoration: BoxDecoration(
              color: context.dm.paleAqua,
              borderRadius: BorderRadius.circular(Sp.radiusPill),
              border: Border.all(color: context.dm.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: context.scheme.primary),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: Text(l.homeSearchHint, style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerCarousel extends ConsumerStatefulWidget {
  const _BannerCarousel();
  @override
  ConsumerState<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<_BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(bannersProvider);
    return banners.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Sp.x4),
          child: Column(
            children: [
              SizedBox(
                height: 148,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: list.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BannerCard(banner: list[i], index: i),
                  ),
                ),
              ),
              if (list.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.x2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < list.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? context.scheme.primary : context.dm.divider,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.fromLTRB(Sp.gutter, Sp.x4, Sp.gutter, 0), child: Skeleton(height: 148, radius: 20)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.index});
  final PromoBanner banner;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = index.isEven ? const [DmPalette.emerald, DmPalette.mint] : const [DmPalette.deepGreen, DmPalette.emerald];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sp.radiusLg + 4),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: BotanicalDecor(size: 170, opacity: 0.25)),
          Padding(
            padding: const EdgeInsets.all(Sp.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title,
                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.subtitle != null) ...[
                  const SizedBox(height: Sp.x2),
                  Text(
                    banner.subtitle!,
                    style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (banner.code != null) ...[
                  const SizedBox(height: Sp.x3),
                  Pill(label: l.promoCodeBanner(banner.code!), color: DmPalette.deepGreen, background: Colors.white),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RxEntry extends StatelessWidget {
  const _RxEntry();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x4, Sp.gutter, 0),
      child: DmCard(
        color: context.dm.softMint,
        onTap: () => context.push(Routes.prescriptionNew),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.description_outlined, color: context.scheme.primary),
            ),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.homeRxTitle, style: context.text.titleSmall),
                  Text(l.homeRxBody, style: context.text.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.scheme.primary),
          ],
        ),
      ),
    );
  }
}

class _Shelf extends ConsumerWidget {
  const _Shelf({required this.title, required this.provider, required this.retry, this.onSeeAll, this.hideWhenEmpty = false});
  final String title;
  final FutureProvider<List<ProductCard>> provider;
  final void Function(WidgetRef ref)? retry;
  final VoidCallback? onSeeAll;
  final bool hideWhenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    if (hideWhenEmpty && (value.value?.isEmpty ?? false)) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onSeeAll: onSeeAll),
          SizedBox(
            height: 244,
            child: value.when(
              data: (items) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: Sp.x3),
                itemBuilder: (_, i) => ProductTile(
                  product: items[i],
                  onTap: () => context.push(Routes.product(items[i].id)),
                  onAdd: () => quickAdd(context, ref, items[i]),
                ),
              ),
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: Sp.x3),
                itemBuilder: (_, _) => const ProductCardSkeleton(),
              ),
              error: (e, _) => ErrorState(error: e, onRetry: () => retry?.call(ref)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});
  final Branch branch;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DmCard(
      onTap: () => context.push(Routes.pharmacies),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: context.dm.softMint, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.local_pharmacy_outlined, color: context.scheme.primary),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(branch.address, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(
                  spacing: Sp.x2,
                  children: [
                    Pill(label: branch.deliveryAvailable ? l.pharmacyDelivers : l.pharmacyPickupOnly, color: context.scheme.primary),
                    if (branch.distanceKm != null)
                      Pill(label: l.pharmacyDistance(branch.distanceKm!.toStringAsFixed(1)), color: context.dm.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
