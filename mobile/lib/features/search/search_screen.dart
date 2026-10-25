import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/spacing.dart';
import '../../data/models/catalog_models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../design/category_icons.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/core_providers.dart';
import '../../state/local_lists.dart';
import '../cart/cart_actions.dart';
import 'search_state.dart';
import '../../core/theme/colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialCategory, this.initialQuery, this.onSale = false});
  final String? initialCategory;
  final String? initialQuery;
  final bool onSale;
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  List<Suggestion> _suggestions = const [];
  Timer? _suggestTimer;
  int _suggestSeq = 0;

  @override
  void initState() {
    super.initState();
    _text.text = widget.initialQuery ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchProvider.notifier).configure(category: widget.initialCategory, text: widget.initialQuery, sale: widget.onSale);
      if (widget.initialCategory == null && !widget.onSale && (widget.initialQuery ?? '').isEmpty) _focus.requestFocus();
    });
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _suggestTimer?.cancel();
    _text.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    ref.read(searchProvider.notifier).setText(v);
    _suggestTimer?.cancel();
    if (v.trim().length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _suggestTimer = Timer(const Duration(milliseconds: 250), () async {
      final seq = ++_suggestSeq;
      try {
        final s = await ref.read(catalogRepositoryProvider).suggestions(v.trim());
        if (mounted && seq == _suggestSeq) setState(() => _suggestions = s);
      } catch (_) {
        // Suggestions are a convenience; failures are silent (results show the real error).
      }
    });
  }

  void _pick(String text) {
    _text.text = text;
    _text.selection = TextSelection.collapsed(offset: text.length);
    setState(() => _suggestions = const []);
    ref.read(searchProvider.notifier).submit(text);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x3, Sp.x2, Sp.x2),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      onChanged: _onChanged,
                      onSubmitted: _pick,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _text.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l.searchClearSemantic,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _text.clear();
                                  setState(() => _suggestions = const []);
                                  notifier.clear();
                                  _focus.requestFocus();
                                },
                              ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sp.radiusPill),
                          borderSide: BorderSide(color: context.dm.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sp.radiusPill),
                          borderSide: BorderSide(color: context.dm.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sp.radiusPill),
                          borderSide: BorderSide(color: context.scheme.primary, width: 1.6),
                        ),
                      ),
                    ),
                  ),
                  Badge(
                    isLabelVisible: s.query.activeFilterCount > 0,
                    label: Text('${s.query.activeFilterCount}'),
                    offset: const Offset(-6, 6),
                    child: IconButton(tooltip: l.filters, icon: const Icon(Icons.tune_rounded), onPressed: () => _openFilters(context)),
                  ),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty && _focus.hasFocus)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Sp.x2),
                  itemBuilder: (_, i) => ActionChip(
                    avatar: Icon(
                      _suggestions[i].type == 'ingredient'
                          ? Icons.science_outlined
                          : _suggestions[i].type == 'brand'
                          ? Icons.sell_outlined
                          : Icons.medication_outlined,
                      size: 16,
                    ),
                    label: Text(_suggestions[i].text),
                    onPressed: () => _pick(_suggestions[i].text),
                  ),
                ),
              ),
            Expanded(
              child: s.active ? _Results(scroll: _scroll, state: s) : _Idle(onPick: _pick),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final current = ref.read(searchProvider);
    final result = await showModalBottomSheet<SearchQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: current.query, manufacturers: current.manufacturers),
    );
    if (result != null) ref.read(searchProvider.notifier).applyFilters(result);
  }
}

class _Idle extends ConsumerWidget {
  const _Idle({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final recent = ref.watch(recentSearchesProvider);
    final categories = ref.watch(categoriesProvider);
    return ListView(
      padding: const EdgeInsets.all(Sp.gutter),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text(l.searchRecent, style: context.text.titleSmall)),
              TextButton(onPressed: () => ref.read(recentSearchesProvider.notifier).clear(), child: Text(l.searchClearHistory)),
            ],
          ),
          Wrap(
            spacing: Sp.x2,
            runSpacing: Sp.x2,
            children: [
              for (final r in recent)
                InputChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(r),
                  onPressed: () => onPick(r),
                  onDeleted: () => ref.read(recentSearchesProvider.notifier).remove(r),
                ),
            ],
          ),
          const SizedBox(height: Sp.x6),
        ],
        Text(l.homeCategories, style: context.text.titleSmall),
        const SizedBox(height: Sp.x3),
        categories.when(
          data: (list) => Wrap(
            spacing: Sp.x2,
            runSpacing: Sp.x2,
            children: [
              for (final c in list)
                ActionChip(
                  avatar: Icon(categoryIcon(c.icon), size: 18, color: context.scheme.primary),
                  label: Text(c.name),
                  onPressed: () => context.go(Routes.searchCategory(c.slug)),
                ),
            ],
          ),
          loading: () => const Skeleton(height: 80, radius: 16),
          error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(categoriesProvider)),
        ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.scroll, required this.state});
  final ScrollController scroll;
  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final notifier = ref.read(searchProvider.notifier);
    if (state.loading && state.items.isEmpty) return const ListSkeleton();
    if (state.error != null && state.items.isEmpty) return ErrorState(error: state.error!, onRetry: notifier.retry);
    if (state.loadedOnce && state.items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l.searchNoResultsTitle,
        body: l.searchNoResultsBody,
        actionLabel: l.searchBrowseCategories,
        onAction: notifier.clear,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.x2, Sp.x2),
          child: Row(
            children: [
              Expanded(child: Text(l.searchFoundCount(state.total), style: context.text.bodySmall)),
              PopupMenuButton<String>(
                tooltip: l.sortLabel,
                initialValue: state.query.sort,
                onSelected: notifier.setSort,
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'relevance', child: Text(l.sortRelevance)),
                  PopupMenuItem(value: 'price_asc', child: Text(l.sortPriceAsc)),
                  PopupMenuItem(value: 'price_desc', child: Text(l.sortPriceDesc)),
                  PopupMenuItem(value: 'popularity', child: Text(l.sortPopularity)),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.x2, vertical: Sp.x2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_vert_rounded, size: 18, color: context.scheme.primary),
                      const SizedBox(width: 4),
                      Text(switch (state.query.sort) {
                        'price_asc' => l.sortPriceAsc,
                        'price_desc' => l.sortPriceDesc,
                        'popularity' => l.sortPopularity,
                        _ => l.sortRelevance,
                      }, style: context.text.labelMedium?.copyWith(color: context.scheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.separated(
                controller: scroll,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x6),
                itemCount: state.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
                itemBuilder: (_, i) {
                  if (i == state.items.length) {
                    if (state.loadingMore)
                      return const Padding(
                        padding: EdgeInsets.all(Sp.x4),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    if (state.error != null)
                      return Center(
                        child: TextButton(onPressed: notifier.retry, child: Text(l.retry)),
                      );
                    return state.hasNext
                        ? Center(
                            child: TextButton(onPressed: notifier.loadMore, child: Text(l.loadMore)),
                          )
                        : const SizedBox.shrink();
                  }
                  final p = state.items[i];
                  return ProductRow(product: p, onTap: () => context.push(Routes.product(p.id)), onAdd: () => quickAdd(context, ref, p));
                },
              ),
              if (state.loading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial, required this.manufacturers});
  final SearchQuery initial;
  final List<String> manufacturers;
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late SearchQuery _q = widget.initial;
  late final _min = TextEditingController(text: widget.initial.minPrice?.round().toString() ?? '');
  late final _max = TextEditingController(text: widget.initial.maxPrice?.round().toString() ?? '');

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Sp.x4, 0, Sp.x4, Sp.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.filters, style: context.text.titleLarge),
              const SizedBox(height: Sp.x4),
              Text(l.filterCategory, style: context.text.titleSmall),
              const SizedBox(height: Sp.x2),
              Wrap(
                spacing: Sp.x2,
                runSpacing: Sp.x2,
                children: [
                  ChoiceChip(
                    label: Text(l.filterAll),
                    selected: _q.categorySlug == null,
                    onSelected: (_) => setState(() => _q = _q.copyWith(categorySlug: null)),
                  ),
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: _q.categorySlug == c.slug,
                      onSelected: (_) => setState(() => _q = _q.copyWith(categorySlug: c.slug)),
                    ),
                ],
              ),
              if (widget.manufacturers.isNotEmpty) ...[
                const SizedBox(height: Sp.x4),
                DropdownButtonFormField<String?>(
                  initialValue: _q.manufacturer,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.filterManufacturer),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(l.filterAll)),
                    for (final m in widget.manufacturers)
                      DropdownMenuItem<String?>(
                        value: m,
                        child: Text(m, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _q = _q.copyWith(manufacturer: v)),
                ),
              ],
              const SizedBox(height: Sp.x4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.filterInStock),
                value: _q.inStock,
                onChanged: (v) => setState(() => _q = _q.copyWith(inStock: v)),
              ),
              Text(l.filterRx, style: context.text.titleSmall),
              const SizedBox(height: Sp.x2),
              SegmentedButton<bool?>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: null, label: Text(l.filterRxAny)),
                  ButtonSegment(value: true, label: Text(l.filterRxOnly)),
                  ButtonSegment(value: false, label: Text(l.filterRxNone)),
                ],
                selected: {_q.rxRequired},
                onSelectionChanged: (s) => setState(() => _q = _q.copyWith(rxRequired: s.first)),
              ),
              const SizedBox(height: Sp.x4),
              Text(l.filterPrice, style: context.text.titleSmall),
              const SizedBox(height: Sp.x2),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _min,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l.filterPriceFrom),
                    ),
                  ),
                  const SizedBox(width: Sp.x3),
                  Expanded(
                    child: TextField(
                      controller: _max,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l.filterPriceTo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.x6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.pop(context, const SearchQuery()), child: Text(l.reset)),
                  ),
                  const SizedBox(width: Sp.x3),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, _q.copyWith(minPrice: double.tryParse(_min.text), maxPrice: double.tryParse(_max.text))),
                      child: Text(l.apply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
