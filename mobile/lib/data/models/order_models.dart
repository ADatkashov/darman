import 'json_util.dart';

enum OrderStatus { placed, confirmed, preparing, readyForPickup, inTransit, delivered, cancelled }

OrderStatus parseOrderStatus(String s) => switch (s) {
  'CONFIRMED' => OrderStatus.confirmed,
  'PREPARING' => OrderStatus.preparing,
  'READY_FOR_PICKUP' => OrderStatus.readyForPickup,
  'IN_TRANSIT' => OrderStatus.inTransit,
  'DELIVERED' => OrderStatus.delivered,
  'CANCELLED' => OrderStatus.cancelled,
  _ => OrderStatus.placed,
};

/// The ordered steps of the happy path for a fulfillment type, as shown on the tracking timeline.
List<OrderStatus> timelineFor(bool pickup) => [
  OrderStatus.placed,
  OrderStatus.confirmed,
  OrderStatus.preparing,
  pickup ? OrderStatus.readyForPickup : OrderStatus.inTransit,
  OrderStatus.delivered,
];

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.number,
    required this.status,
    required this.pickup,
    required this.createdAt,
    required this.total,
    required this.itemCount,
    this.firstItemName,
    this.pharmacyName,
    required this.canCancel,
  });
  final String id;
  final String number;
  final OrderStatus status;
  final bool pickup;
  final DateTime createdAt;
  final double total;
  final int itemCount;
  final String? firstItemName;
  final String? pharmacyName;
  final bool canCancel;

  bool get isActive => status != OrderStatus.delivered && status != OrderStatus.cancelled;

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
    id: j['id'] as String,
    number: j['number'] as String,
    status: parseOrderStatus(j['status'] as String),
    pickup: j['fulfillment'] == 'PICKUP',
    createdAt: date(j['createdAt']),
    total: dbl(j['total']),
    itemCount: intOr(j['itemCount']),
    firstItemName: j['firstItemName'] as String?,
    pharmacyName: j['pharmacyName'] as String?,
    canCancel: (j['canCancel'] as bool?) ?? false,
  );
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.offerId,
    required this.name,
    this.strength,
    this.dosageForm,
    this.packageSize,
    required this.rxRequired,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });
  final String productId;
  final String offerId;
  final String name;
  final String? strength;
  final String? dosageForm;
  final String? packageSize;
  final bool rxRequired;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: j['productId'] as String,
    offerId: j['offerId'] as String,
    name: j['productName'] as String,
    strength: j['strength'] as String?,
    dosageForm: j['dosageForm'] as String?,
    packageSize: j['packageSize'] as String?,
    rxRequired: (j['rxRequired'] as bool?) ?? false,
    unitPrice: dbl(j['unitPrice']),
    quantity: intOr(j['quantity'], 1),
    lineTotal: dbl(j['lineTotal']),
  );
}

class HistoryEntry {
  const HistoryEntry({required this.status, this.comment, required this.createdAt});
  final OrderStatus status;
  final String? comment;
  final DateTime createdAt;
  factory HistoryEntry.fromJson(Map<String, dynamic> j) =>
      HistoryEntry(status: parseOrderStatus(j['status'] as String), comment: j['comment'] as String?, createdAt: date(j['createdAt']));
}

class Courier {
  const Courier({required this.name, this.phone, required this.demo});
  final String name;
  final String? phone;
  final bool demo;
  factory Courier.fromJson(Map<String, dynamic> j) =>
      Courier(name: j['name'] as String, phone: j['phone'] as String?, demo: (j['demo'] as bool?) ?? false);
}

class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.number,
    required this.status,
    required this.pickup,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.promoCode,
    this.deliveryAddress,
    this.slotStart,
    this.slotEnd,
    this.etaFrom,
    this.etaTo,
    required this.paymentMethod,
    required this.paymentStatus,
    this.branchName,
    this.pharmacyName,
    this.branchAddress,
    this.branchPhone,
    required this.history,
    this.courier,
    required this.canCancel,
    required this.demo,
  });
  final String id;
  final String number;
  final OrderStatus status;
  final bool pickup;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? promoCode;
  final String? deliveryAddress;
  final DateTime? slotStart;
  final DateTime? slotEnd;
  final DateTime? etaFrom;
  final DateTime? etaTo;
  final String paymentMethod;
  final String paymentStatus;
  final String? branchName;
  final String? pharmacyName;
  final String? branchAddress;
  final String? branchPhone;
  final List<HistoryEntry> history;
  final Courier? courier;
  final bool canCancel;
  final bool demo;

  bool get isActive => status != OrderStatus.delivered && status != OrderStatus.cancelled;

  DateTime? timeOf(OrderStatus s) {
    for (final h in history.reversed) {
      if (h.status == s) return h.createdAt;
    }
    return null;
  }

  factory OrderDetail.fromJson(Map<String, dynamic> j) => OrderDetail(
    id: j['id'] as String,
    number: j['number'] as String,
    status: parseOrderStatus(j['status'] as String),
    pickup: j['fulfillment'] == 'PICKUP',
    createdAt: date(j['createdAt']),
    items: list(j['items'], OrderItem.fromJson),
    subtotal: dbl(j['subtotal']),
    deliveryFee: dbl(j['deliveryFee']),
    discount: dbl(j['discount']),
    total: dbl(j['total']),
    promoCode: j['promoCode'] as String?,
    deliveryAddress: j['deliveryAddress'] as String?,
    slotStart: dateOrNull(j['slotStart']),
    slotEnd: dateOrNull(j['slotEnd']),
    etaFrom: dateOrNull(j['etaFrom']),
    etaTo: dateOrNull(j['etaTo']),
    paymentMethod: j['paymentMethod'] as String,
    paymentStatus: j['paymentStatus'] as String,
    branchName: j['branchName'] as String?,
    pharmacyName: j['pharmacyName'] as String?,
    branchAddress: j['branchAddress'] as String?,
    branchPhone: j['branchPhone'] as String?,
    history: list(j['history'], HistoryEntry.fromJson),
    courier: j['courier'] == null ? null : Courier.fromJson(j['courier'] as Map<String, dynamic>),
    canCancel: (j['canCancel'] as bool?) ?? false,
    demo: (j['demo'] as bool?) ?? false,
  );
}

class DeliverySlot {
  const DeliverySlot(this.start, this.end);
  final DateTime start;
  final DateTime end;
  factory DeliverySlot.fromJson(Map<String, dynamic> j) => DeliverySlot(date(j['start']), date(j['end']));
}

class SlotsInfo {
  const SlotsInfo({required this.asapAvailable, this.etaMin, this.etaMax, required this.slots});
  final bool asapAvailable;
  final int? etaMin;
  final int? etaMax;
  final List<DeliverySlot> slots;
  factory SlotsInfo.fromJson(Map<String, dynamic> j) => SlotsInfo(
    asapAvailable: (j['asapAvailable'] as bool?) ?? false,
    etaMin: (j['etaMinMinutes'] as num?)?.toInt(),
    etaMax: (j['etaMaxMinutes'] as num?)?.toInt(),
    slots: list(j['slots'], DeliverySlot.fromJson),
  );
}

class PromoCheck {
  const PromoCheck({required this.valid, required this.discountAmount, this.reason});
  final bool valid;
  final double discountAmount;
  final String? reason;
  factory PromoCheck.fromJson(Map<String, dynamic> j) =>
      PromoCheck(valid: (j['valid'] as bool?) ?? false, discountAmount: dbl(j['discountAmount']), reason: j['reason'] as String?);
}
