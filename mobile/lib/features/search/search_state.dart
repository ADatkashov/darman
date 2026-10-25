import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/catalog_models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../state/core_providers.dart';
import '../../state/local_lists.dart';

class SearchState {
  const SearchState({
    this.query = const SearchQuery(),
    this.items = const [],
    this.page = 0,
    this.hasNext = false,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.total = 0,
    this.manufacturers = const [],
    this.loadedOnce = false,
  });

  final SearchQuery query;
  final List<ProductCard> items;
  final int page;
  final bool hasNext;
  final bool loading;
  final bool loadingMore;
  final Object? error;
  final int total;
  final List<String> manufacturers;
  final bool loadedOnce;

  /// Results are shown once there is text or any filter; otherwise the idle screen (recents, categories) is shown.
  bool get active => query.q.trim().length >= 2 || query.activeFilterCount > 0 || query.onSale;

  SearchState copyWith({
    SearchQuery? query,
    List<ProductCard>? items,
    int? page,
    bool? hasNext,
    bool? loading,
    bool? loadingMore,
    Object? error = _keep,
    int? total,
    List<String>? manufacturers,
    bool? loadedOnce,
  }) => SearchState(
    query: query ?? this.query,
    items: items ?? this.items,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: identical(error, _keep) ? this.error : error,
    total: total ?? this.total,
    manufacturers: manufacturers ?? this.manufacturers,
    loadedOnce: loadedOnce ?? this.loadedOnce,
  );

  static const _keep = Object();
}

class SearchNotifier extends Notifier<SearchState> {
  static const pageSize = 20;
  static const debounce = Duration(milliseconds: 350);
  Timer? _timer;
  int _seq = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SearchState();
  }

  /// Applies deep-link parameters (category / sale / initial text) and loads.
  void configure({String? category, String? text, bool sale = false}) {
    _timer?.cancel();
    final q = SearchQuery(q: text ?? '', categorySlug: category, onSale: sale);
    state = SearchState(query: q);
    if (state.active) _load(reset: true);
  }

  /// Debounced text input: one request per pause in typing.
  void setText(String text) {
    _timer?.cancel();
    state = state.copyWith(query: state.query.copyWith(q: text));
    if (!state.active) {
      _seq++;
      state = state.copyWith(items: const [], loading: false, error: null, total: 0, hasNext: false, loadedOnce: false);
      return;
    }
    _timer = Timer(debounce, () => _load(reset: true));
  }

  void submit(String text) {
    _timer?.cancel();
    state = state.copyWith(query: state.query.copyWith(q: text));
    if (text.trim().length >= 2) ref.read(recentSearchesProvider.notifier).add(text);
    if (state.active) _load(reset: true);
  }

  void setSort(String sort) {
    state = state.copyWith(query: state.query.copyWith(sort: sort));
    if (state.active) _load(reset: true);
  }

  void applyFilters(SearchQuery q) {
    _timer?.cancel();
    state = state.copyWith(
      query: q.copyWith(q: state.query.q, sort: state.query.sort),
    );
    if (state.active) {
      _load(reset: true);
    } else {
      state = state.copyWith(items: const [], total: 0, hasNext: false, loadedOnce: false);
    }
  }

  void clear() {
    _timer?.cancel();
    _seq++;
    state = SearchState(
      query: SearchQuery(sort: state.query.sort),
      manufacturers: state.manufacturers,
    );
  }

  void retry() => _load(reset: state.items.isEmpty);

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasNext) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    final seq = ++_seq;
    final page = reset ? 0 : state.page + 1;
    state = state.copyWith(loading: reset, loadingMore: !reset, error: null);
    try {
      final res = await ref.read(catalogRepositoryProvider).search(state.query, page: page, size: pageSize);
      if (seq != _seq) return; // a newer request superseded this one
      state = state.copyWith(
        items: reset ? res.items : [...state.items, ...res.items],
        page: res.page,
        hasNext: res.hasNext,
        total: res.totalItems,
        loading: false,
        loadingMore: false,
        loadedOnce: true,
        manufacturers: res.manufacturers ?? state.manufacturers,
      );
    } catch (e) {
      if (seq != _seq) return;
      state = state.copyWith(loading: false, loadingMore: false, error: e, loadedOnce: true);
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
