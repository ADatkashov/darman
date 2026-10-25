import 'package:darman/data/models/cart_models.dart';
import 'package:darman/data/models/catalog_models.dart';
import 'package:darman/data/models/order_models.dart';
import 'package:darman/data/repositories/catalog_repository.dart';
import 'package:darman/data/repositories/order_repository.dart';
import 'package:darman/core/storage/token_store.dart';
import 'package:darman/state/core_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

const sampleCard = ProductCard(
  id: 'p1',
  slug: 'paradem',
  name: 'ПараДем 500 мг, 20 таблеток',
  brand: 'ПараДем',
  strength: '500 мг',
  dosageForm: 'таблетки',
  packageSize: '20 шт',
  categorySlug: 'pain-relief',
  rxRequired: false,
  price: 490,
  bestOfferId: 'o1',
  pharmacyName: 'Аптека «Тау» (демо)',
  branchName: 'Тау — Достык',
  availableOffers: 2,
  inStock: true,
  demo: true,
);

CartLine sampleLine({String offer = 'o1', String branch = 'b1', int qty = 1, double price = 490}) => CartLine(
  offerId: offer,
  productId: 'p1',
  name: 'ПараДем',
  rxRequired: false,
  branchId: branch,
  branchName: 'Филиал',
  pharmacyName: 'Аптека',
  unitPrice: price,
  quantity: qty,
  maxQuantity: 10,
);

class FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<Category>> categories() async => const [
    Category(id: 'c1', slug: 'pain-relief', name: 'Обезболивающие', icon: 'pain', productCount: 5),
  ];
  @override
  Future<SearchResult> search(SearchQuery q, {int page = 0, int size = 20}) async {
    final hit = q.q.trim().isEmpty || sampleCard.name.toLowerCase().contains(q.q.trim().toLowerCase());
    return SearchResult(items: hit ? [sampleCard] : const [], page: 0, totalItems: hit ? 1 : 0, hasNext: false, manufacturers: const []);
  }

  @override
  Future<List<Suggestion>> suggestions(String q) async => const [];
  @override
  Future<ProductDetail> product(String id) async =>
      const ProductDetail(card: sampleCard, saleClass: 'OTC', images: [], officialInfo: [], favorite: false);
  @override
  Future<List<Offer>> offers(String productId, {String sort = 'price_asc'}) async => [
    Offer(
      id: 'o1',
      productId: 'p1',
      branchId: 'b1',
      branchName: 'Тау — Достык',
      pharmacyName: 'Аптека «Тау» (демо)',
      address: 'пр. Достык',
      price: 490,
      availability: Availability.inStock,
      availableQuantity: 10,
      pickupAvailable: true,
      deliveryAvailable: true,
      deliveryFee: 500,
      updatedAt: DateTime(2026, 1, 1),
      demoPharmacy: true,
    ),
  ];
  @override
  Future<List<ProductCard>> byIds(List<String> ids) async => [];
  @override
  Future<List<PromoBanner>> banners() async => const [PromoBanner(id: 'x', title: 'Забота о здоровье каждый день')];
  @override
  Future<List<Branch>> branches({bool? deliveryOnly}) async => const [];
  @override
  Future<RuntimeConfig> config() async => RuntimeConfig.fallback;
  @override
  Future<SlotsInfo> slots(String branchId) async => const SlotsInfo(asapAvailable: true, slots: []);
  @override
  Future<PromoCheck> checkPromo(String code, double subtotal) async => const PromoCheck(valid: false, discountAmount: 0);
}

class FakeOrderRepository implements OrderRepository {
  @override
  Future<CartValidation> validateCart(List<CartLine> lines) async => CartValidation(
    lines: [for (final l in lines) ValidatedLine(offerId: l.offerId, status: LineStatus.ok, unitPrice: l.unitPrice, availableQuantity: 10)],
    subtotal: lines.fold(0.0, (a, l) => a + l.lineTotal),
    prescriptionRequired: false,
    checkoutBlocked: false,
    mixedBranches: false,
  );
  @override
  Future<OrderDetail> place(PlaceOrderInput input, String idempotencyKey) => throw UnimplementedError();
  @override
  Future<List<OrderSummary>> list(String scope) async => [];
  @override
  Future<OrderDetail> get(String id) => throw UnimplementedError();
  @override
  Future<OrderDetail> cancel(String id, {String? reason}) => throw UnimplementedError();
  @override
  Future<CartValidation> reorder(String id) => throw UnimplementedError();
}

Future<List<Override>> testOverrides({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({'onboarding.done': true, ...prefs});
  final sp = await SharedPreferences.getInstance();
  return [
    sharedPrefsProvider.overrideWithValue(sp),
    tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
    orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
  ];
}
