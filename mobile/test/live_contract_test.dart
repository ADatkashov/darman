@TestOn('vm')
library;

import 'dart:io';

import 'package:darman/core/network/api_client.dart';
import 'package:darman/core/storage/token_store.dart';
import 'package:darman/data/models/cart_models.dart';
import 'package:darman/data/repositories/auth_repository.dart';
import 'package:darman/data/repositories/catalog_repository.dart';
import 'package:darman/data/repositories/order_repository.dart';
import 'package:darman/data/repositories/prescription_repository.dart';
import 'package:darman/data/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract test against a running demo backend. Skipped unless DARMAN_API_URL and DARMAN_DEMO_PASSWORD are set, e.g.
/// DARMAN_API_URL=http://localhost:8080 DARMAN_DEMO_PASSWORD=... flutter test test/live_contract_test.dart
void main() {
  final url = Platform.environment['DARMAN_API_URL'];
  final password = Platform.environment['DARMAN_DEMO_PASSWORD'];
  final skip = url == null || password == null ? 'set DARMAN_API_URL and DARMAN_DEMO_PASSWORD' : false;

  test('mobile models parse the real backend responses end to end', skip: skip, () async {
    final tokens = MemoryTokenStore();
    final api = ApiClient(tokens: tokens, locale: () => 'ru', baseUrl: url);
    final catalog = CatalogRepository(api);

    final categories = await catalog.categories();
    expect(categories, hasLength(10));
    final found = await catalog.search(const SearchQuery(q: 'ибупрофен'));
    expect(found.totalItems, 3);
    final card = found.items.first;
    final detail = await catalog.product(card.id);
    expect(detail.card.name, card.name);
    final offers = await catalog.offers(card.id);
    expect(offers, isNotEmpty);
    expect((await catalog.banners()), isNotEmpty);
    expect((await catalog.branches()), hasLength(6));
    expect((await catalog.config()).demoMode, isTrue);
    expect((await catalog.byIds([card.id])).single.id, card.id);
    final sale = await catalog.search(const SearchQuery(onSale: true));
    expect(sale.items.every((p) => p.oldPrice != null), isTrue);

    final orders = OrderRepository(api);
    final offer = offers.firstWhere((o) => o.canBuy && o.deliveryAvailable);
    final line = CartLine(
      offerId: offer.id,
      productId: card.id,
      name: card.name,
      rxRequired: false,
      branchId: offer.branchId,
      branchName: offer.branchName,
      pharmacyName: offer.pharmacyName,
      unitPrice: offer.price,
      quantity: 2,
      maxQuantity: offer.availableQuantity,
    );
    final validation = await orders.validateCart([line]);
    expect(validation.checkoutBlocked, isFalse);
    expect(validation.delivery!.deliveryAvailable, isTrue);
    final slots = await catalog.slots(offer.branchId);
    expect(slots.slots, isNotEmpty);

    // sign in as the seeded demo customer and place a demo order
    final auth = await AuthRepository(api).login('+77000000010', password!);
    await tokens.write(access: auth.access, refresh: auth.refresh);
    final users = UserRepository(api);
    final addresses = await users.addresses();
    expect(addresses, isNotEmpty);
    final order = await orders.place(
      PlaceOrderInput(
        lines: [line],
        pickup: false,
        addressId: addresses.first.id,
        contactName: 'Тест',
        contactPhone: '+77011234567',
        cardPayment: true,
        slotStart: slots.slots.first.start,
      ),
      'contract-${DateTime.now().microsecondsSinceEpoch}',
    );
    expect(order.paymentStatus, 'DEMO_PAID');
    expect(order.demo, isTrue);
    final fetched = await orders.get(order.id);
    expect(fetched.history, isNotEmpty);
    expect((await orders.list('all')).any((o) => o.id == order.id), isTrue);
    expect((await orders.reorder(order.id)).lines, isNotEmpty);
    expect((await users.notifications()), isNotEmpty);
    await users.addFavorite(card.id);
    expect((await users.favorites()).any((f) => f.id == card.id), isTrue);
    await users.removeFavorite(card.id);
    expect((await users.favorites()).any((f) => f.id == card.id), isFalse);

    // prescription upload round trip
    final rx = PrescriptionRepository(api);
    final jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 0, 16, 0x4A, 0x46, 0x49, 0x46, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0xFF, 0xD9];
    final created = await rx.create([UploadFile(name: 'rx.jpg', bytes: jpeg)], note: 'contract');
    expect(created.files, hasLength(1));
    final submitted = await rx.submit(created.id);
    expect(submitted.status.name, 'submitted');
    expect((await rx.fileBytes(created.id, created.files.first.id)).length, jpeg.length);
    expect((await rx.list()), isNotEmpty);
  });
}
