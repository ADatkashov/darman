import '../../core/network/api_client.dart';
import '../models/catalog_models.dart';
import '../models/order_models.dart';

class SearchQuery {
  const SearchQuery({
    this.q = '',
    this.categorySlug,
    this.manufacturer,
    this.inStock = false,
    this.minPrice,
    this.maxPrice,
    this.rxRequired,
    this.onSale = false,
    this.sort = 'relevance',
  });
  final String q;
  final String? categorySlug;
  final String? manufacturer;
  final bool inStock;
  final double? minPrice;
  final double? maxPrice;
  final bool? rxRequired;
  final bool onSale;
  final String sort;

  SearchQuery copyWith({
    String? q,
    Object? categorySlug = _keep,
    Object? manufacturer = _keep,
    bool? inStock,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    Object? rxRequired = _keep,
    bool? onSale,
    String? sort,
  }) => SearchQuery(
    q: q ?? this.q,
    categorySlug: identical(categorySlug, _keep) ? this.categorySlug : categorySlug as String?,
    manufacturer: identical(manufacturer, _keep) ? this.manufacturer : manufacturer as String?,
    inStock: inStock ?? this.inStock,
    minPrice: identical(minPrice, _keep) ? this.minPrice : minPrice as double?,
    maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as double?,
    rxRequired: identical(rxRequired, _keep) ? this.rxRequired : rxRequired as bool?,
    onSale: onSale ?? this.onSale,
    sort: sort ?? this.sort,
  );

  static const _keep = Object();

  int get activeFilterCount =>
      (categorySlug != null ? 1 : 0) +
      (manufacturer != null ? 1 : 0) +
      (inStock ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (rxRequired != null ? 1 : 0);

  Map<String, dynamic> toParams(int page, int size) => {
    if (q.trim().isNotEmpty) 'q': q.trim(),
    'categorySlug': ?categorySlug,
    'manufacturer': ?manufacturer,
    if (inStock) 'inStock': true,
    'minPrice': ?minPrice,
    'maxPrice': ?maxPrice,
    'rxRequired': ?rxRequired,
    if (onSale) 'onSale': true,
    'sort': sort,
    'page': page,
    'size': size,
  };

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.q == q &&
      other.categorySlug == categorySlug &&
      other.manufacturer == manufacturer &&
      other.inStock == inStock &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.rxRequired == rxRequired &&
      other.onSale == onSale &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(q, categorySlug, manufacturer, inStock, minPrice, maxPrice, rxRequired, onSale, sort);
}

class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<Category>> categories() async =>
      (await _api.getList('/categories', auth: false)).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();

  Future<SearchResult> search(SearchQuery q, {int page = 0, int size = 20}) async =>
      SearchResult.fromJson(await _api.getMap('/products', query: q.toParams(page, size), auth: false));

  Future<List<Suggestion>> suggestions(String q) async => (await _api.getList(
    '/search/suggestions',
    query: {'q': q},
    auth: false,
  )).map((e) => Suggestion.fromJson(e as Map<String, dynamic>)).toList();

  Future<ProductDetail> product(String id) async => ProductDetail.fromJson(await _api.getMap('/products/$id'));

  Future<List<Offer>> offers(String productId, {String sort = 'price_asc'}) async => (await _api.getList(
    '/products/$productId/offers',
    query: {'sort': sort},
    auth: false,
  )).map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<ProductCard>> byIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final data = await _api.getList('/products/by-ids', query: {'ids': ids.take(50).join(',')}, auth: false);
    return data.map((e) => ProductCard.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PromoBanner>> banners() async =>
      (await _api.getList('/promotions', auth: false)).map((e) => PromoBanner.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<Branch>> branches({bool? deliveryOnly}) async => (await _api.getList(
    '/pharmacies',
    query: {'city': 'Алматы', 'lat': 43.238, 'lon': 76.945, 'deliveryOnly': ?deliveryOnly},
    auth: false,
  )).map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();

  Future<RuntimeConfig> config() async => RuntimeConfig.fromJson(await _api.getMap('/config', auth: false));

  Future<SlotsInfo> slots(String branchId) async =>
      SlotsInfo.fromJson(await _api.getMap('/delivery/slots', query: {'branchId': branchId}, auth: false));

  Future<PromoCheck> checkPromo(String code, double subtotal) async =>
      PromoCheck.fromJson(await _api.postMap('/promotions/validate', body: {'code': code, 'subtotal': subtotal}, auth: false));
}
