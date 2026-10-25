import 'package:darman/core/network/api_failure.dart';
import 'package:darman/core/utils/file_kind.dart';
import 'package:darman/core/utils/formatters.dart';
import 'package:darman/core/utils/validators.dart';
import 'package:darman/data/models/cart_models.dart';
import 'package:darman/data/models/order_models.dart';
import 'package:darman/data/models/prescription_models.dart';
import 'package:darman/features/cart/checkout_math.dart';
import 'package:darman/state/cart_state.dart';
import 'package:darman/state/core_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  group('cart calculations', () {
    Future<ProviderContainer> container() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final c = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(sp)]);
      addTearDown(c.dispose);
      return c;
    }

    test('adds, merges duplicate offers and computes totals', () async {
      final c = await container();
      final n = c.read(cartProvider.notifier);
      expect(n.add(sampleLine(qty: 2)), AddResult.added);
      expect(n.add(sampleLine(qty: 1)), AddResult.added);
      final cart = c.read(cartProvider);
      expect(cart.lines, hasLength(1));
      expect(cart.itemCount, 3);
      expect(cart.subtotal, 1470);
    });

    test('refuses to mix pharmacy branches unless replaced', () async {
      final c = await container();
      final n = c.read(cartProvider.notifier);
      n.add(sampleLine());
      expect(n.add(sampleLine(offer: 'o2', branch: 'b2')), AddResult.branchMismatch);
      expect(c.read(cartProvider).lines.single.offerId, 'o1');
      expect(n.add(sampleLine(offer: 'o2', branch: 'b2'), replace: true), AddResult.added);
      expect(c.read(cartProvider).lines.single.offerId, 'o2');
    });

    test('quantity is bounded by stock and removal works', () async {
      final c = await container();
      final n = c.read(cartProvider.notifier);
      n.add(sampleLine());
      n.setQuantity('o1', 50);
      expect(c.read(cartProvider).lines.single.quantity, 10); // maxQuantity 10
      expect(n.add(sampleLine(qty: 1)), AddResult.limitReached);
      n.setQuantity('o1', 0);
      expect(c.read(cartProvider).isEmpty, isTrue);
    });

    test('cart persists across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final a = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(sp)]);
      a.read(cartProvider.notifier).add(sampleLine(qty: 3));
      a.dispose();
      final b = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(sp)]);
      addTearDown(b.dispose);
      expect(b.read(cartProvider).itemCount, 3);
    });

    test('server price change is applied to the line', () async {
      final c = await container();
      final n = c.read(cartProvider.notifier);
      n.add(sampleLine(qty: 2));
      n.applyServerLine('o1', unitPrice: 550, availableQuantity: 1);
      final l = c.read(cartProvider).lines.single;
      expect(l.unitPrice, 550);
      expect(l.quantity, 1);
    });
  });

  group('checkout validation & totals', () {
    const terms = DeliveryTerms(deliveryAvailable: true, pickupAvailable: true, fee: 500, freeFrom: 8000);

    test('delivery fee, free threshold and pickup', () {
      expect(computeTotals(subtotal: 3000, pickup: false, terms: terms).total, 3500);
      expect(computeTotals(subtotal: 8000, pickup: false, terms: terms).deliveryFee, 0);
      expect(computeTotals(subtotal: 3000, pickup: true, terms: terms).total, 3000);
    });

    test('discount reduces total but never below zero', () {
      expect(computeTotals(subtotal: 5000, discount: 500, pickup: true).total, 4500);
      expect(computeTotals(subtotal: 100, discount: 500, pickup: true).total, 0);
    });

    test('phone and password validators', () {
      expect(Validators.normalizePhone('8 (701) 123-45-67'), '+77011234567');
      expect(Validators.normalizePhone('123'), isNull);
      expect(Validators.phone(''), FieldError.required);
      expect(Validators.phone('12'), FieldError.phone);
      expect(Validators.phone('+7 701 123 45 67'), isNull);
      expect(Validators.password('abc'), FieldError.password);
      expect(Validators.password('abcdefgh'), FieldError.password);
      expect(Validators.password('abcdefg1'), isNull);
      expect(Validators.optionalEmail('bad'), FieldError.email);
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.prettyPhone('+77011234567'), '+7 701 123 45 67');
    });
  });

  group('misc', () {
    test('KZT formatting is locale aware', () {
      expect(formatMoney(1290, 'en'), contains('1,290'));
      expect(formatMoney(1290, 'ru'), endsWith('₸'));
      expect(formatMoney(99.5, 'en'), contains('99.50'));
    });

    test('file kind comes from magic bytes, not names', () {
      expect(detectFileKind([0xFF, 0xD8, 0xFF, 0xE0]), FileKind.jpeg);
      expect(detectFileKind([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]), FileKind.png);
      expect(detectFileKind('%PDF-1.4'.codeUnits), FileKind.pdf);
      expect(detectFileKind('<script>'.codeUnits), isNull);
    });

    test('order & prescription status parsing', () {
      expect(parseOrderStatus('IN_TRANSIT'), OrderStatus.inTransit);
      expect(parseOrderStatus('???'), OrderStatus.placed);
      expect(timelineFor(true), contains(OrderStatus.readyForPickup));
      expect(timelineFor(false), contains(OrderStatus.inTransit));
      expect(parsePrescriptionStatus('UNDER_REVIEW'), PrescriptionStatus.underReview);
    });

    test('ApiFailure maps backend envelopes and transport errors', () {
      final req = RequestOptions(path: '/x');
      final f = ApiFailure.fromDio(
        DioException(
          requestOptions: req,
          response: Response(requestOptions: req, statusCode: 409, data: {'code': 'INSUFFICIENT_STOCK', 'message': 'm'}),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(f.code, 'INSUFFICIENT_STOCK');
      expect(f.status, 409);
      expect(ApiFailure.fromDio(DioException(requestOptions: req, type: DioExceptionType.connectionError)).isNetwork, isTrue);
      expect(ApiFailure.fromDio(DioException(requestOptions: req, type: DioExceptionType.connectionTimeout)).code, 'TIMEOUT');
    });

    test('validated line parsing', () {
      final v = CartValidation.fromJson({
        'items': [
          {'offerId': 'o', 'status': 'PRICE_CHANGED', 'unitPrice': 500, 'previousPrice': 450, 'availableQuantity': 3},
        ],
        'subtotal': 500,
        'checkoutBlocked': false,
      });
      expect(v.lineFor('o')!.status, LineStatus.priceChanged);
      expect(v.lineFor('o')!.previousPrice, 450);
    });
  });
}
