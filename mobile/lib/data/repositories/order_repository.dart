import '../../core/network/api_client.dart';
import '../models/cart_models.dart';
import '../models/order_models.dart';

class PlaceOrderInput {
  const PlaceOrderInput({
    required this.lines,
    required this.pickup,
    this.addressId,
    required this.contactName,
    required this.contactPhone,
    this.notes,
    this.slotStart,
    required this.cardPayment,
    this.promoCode,
    this.prescriptionId,
    this.expectedTotal,
  });
  final List<CartLine> lines;
  final bool pickup;
  final String? addressId;
  final String contactName;
  final String contactPhone;
  final String? notes;
  final DateTime? slotStart;
  final bool cardPayment;
  final String? promoCode;
  final String? prescriptionId;
  final double? expectedTotal;

  Map<String, dynamic> toJson() => {
    'items': [
      for (final l in lines) {'offerId': l.offerId, 'quantity': l.quantity, 'expectedPrice': l.unitPrice},
    ],
    'fulfillment': pickup ? 'PICKUP' : 'DELIVERY',
    if (addressId != null && !pickup) 'addressId': addressId,
    'contactName': contactName,
    'contactPhone': contactPhone,
    if (notes != null && notes!.trim().isNotEmpty) 'deliveryNotes': notes!.trim(),
    if (slotStart != null && !pickup) 'slotStart': slotStart!.toUtc().toIso8601String(),
    'paymentMethod': cardPayment ? 'CARD_ONLINE' : 'CASH',
    if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
    'prescriptionId': ?prescriptionId,
    'expectedTotal': ?expectedTotal,
    'consent': true,
  };
}

class OrderRepository {
  OrderRepository(this._api);
  final ApiClient _api;

  Future<CartValidation> validateCart(List<CartLine> lines) async => CartValidation.fromJson(
    await _api.postMap(
      '/cart/validate',
      auth: false,
      body: {
        'items': [
          for (final l in lines) {'offerId': l.offerId, 'quantity': l.quantity, 'expectedPrice': l.unitPrice},
        ],
      },
    ),
  );

  /// [idempotencyKey] must stay the same across retries of the *same* checkout attempt so a retry can never create a duplicate order.
  Future<OrderDetail> place(PlaceOrderInput input, String idempotencyKey) async =>
      OrderDetail.fromJson(await _api.postMap('/orders', body: input.toJson(), headers: {'Idempotency-Key': idempotencyKey}));

  Future<List<OrderSummary>> list(String scope) async {
    final page = await _api.getMap('/orders', query: {'scope': scope, 'size': 50});
    return (page['items'] as List).map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderDetail> get(String id) async => OrderDetail.fromJson(await _api.getMap('/orders/$id'));

  Future<OrderDetail> cancel(String id, {String? reason}) async =>
      OrderDetail.fromJson(await _api.postMap('/orders/$id/cancel', body: {'reason': reason}));

  /// Server-side re-validation of a previous order's lines against current availability and prices.
  Future<CartValidation> reorder(String id) async => CartValidation.fromJson(await _api.postMap('/orders/$id/reorder'));
}
