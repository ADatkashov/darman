import 'json_util.dart';

/// A line in the device-local cart. Stores display snapshots so the cart renders offline; truth is re-validated server-side.
class CartLine {
  const CartLine({
    required this.offerId,
    required this.productId,
    required this.name,
    this.spec,
    required this.rxRequired,
    required this.branchId,
    required this.branchName,
    required this.pharmacyName,
    required this.unitPrice,
    required this.quantity,
    required this.maxQuantity,
  });
  final String offerId;
  final String productId;
  final String name;
  final String? spec;
  final bool rxRequired;
  final String branchId;
  final String branchName;
  final String pharmacyName;
  final double unitPrice;
  final int quantity;
  final int maxQuantity;

  double get lineTotal => (unitPrice * quantity * 100).round() / 100;

  CartLine copyWith({int? quantity, double? unitPrice, int? maxQuantity}) => CartLine(
    offerId: offerId,
    productId: productId,
    name: name,
    spec: spec,
    rxRequired: rxRequired,
    branchId: branchId,
    branchName: branchName,
    pharmacyName: pharmacyName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    maxQuantity: maxQuantity ?? this.maxQuantity,
  );

  Map<String, dynamic> toJson() => {
    'offerId': offerId,
    'productId': productId,
    'name': name,
    'spec': spec,
    'rx': rxRequired,
    'branchId': branchId,
    'branchName': branchName,
    'pharmacyName': pharmacyName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'maxQuantity': maxQuantity,
  };

  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
    offerId: j['offerId'] as String,
    productId: j['productId'] as String,
    name: j['name'] as String,
    spec: j['spec'] as String?,
    rxRequired: (j['rx'] as bool?) ?? false,
    branchId: j['branchId'] as String,
    branchName: j['branchName'] as String,
    pharmacyName: j['pharmacyName'] as String,
    unitPrice: dbl(j['unitPrice']),
    quantity: intOr(j['quantity'], 1),
    maxQuantity: intOr(j['maxQuantity'], 99),
  );
}

enum LineStatus { ok, priceChanged, lowStock, outOfStock, unavailable }

LineStatus parseLineStatus(String s) => switch (s) {
  'PRICE_CHANGED' => LineStatus.priceChanged,
  'LOW_STOCK_ADJUSTMENT_NEEDED' => LineStatus.lowStock,
  'OUT_OF_STOCK' => LineStatus.outOfStock,
  'UNAVAILABLE' => LineStatus.unavailable,
  _ => LineStatus.ok,
};

class ValidatedLine {
  const ValidatedLine({
    required this.offerId,
    required this.status,
    required this.unitPrice,
    this.previousPrice,
    required this.availableQuantity,
    this.productId,
    this.productName,
    this.spec,
    this.rxRequired = false,
    this.branchId,
    this.branchName,
    this.pharmacyName,
    this.quantity = 1,
  });
  final String offerId;
  final LineStatus status;
  final double unitPrice;
  final double? previousPrice;
  final int availableQuantity;
  final String? productId;
  final String? productName;
  final String? spec;
  final bool rxRequired;
  final String? branchId;
  final String? branchName;
  final String? pharmacyName;
  final int quantity;

  factory ValidatedLine.fromJson(Map<String, dynamic> j) => ValidatedLine(
    offerId: j['offerId'] as String,
    status: parseLineStatus(j['status'] as String),
    unitPrice: dbl(j['unitPrice']),
    previousPrice: dblOrNull(j['previousPrice']),
    availableQuantity: intOr(j['availableQuantity']),
    productId: j['productId'] as String?,
    productName: j['productName'] as String?,
    spec: [j['strength'], j['dosageForm'], j['packageSize']].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
    rxRequired: (j['rxRequired'] as bool?) ?? false,
    branchId: j['branchId'] as String?,
    branchName: j['branchName'] as String?,
    pharmacyName: j['pharmacyName'] as String?,
    quantity: intOr(j['quantity'], 1),
  );
}

class DeliveryTerms {
  const DeliveryTerms({
    required this.deliveryAvailable,
    required this.pickupAvailable,
    required this.fee,
    this.freeFrom,
    this.etaMin,
    this.etaMax,
  });
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final double fee;
  final double? freeFrom;
  final int? etaMin;
  final int? etaMax;
  factory DeliveryTerms.fromJson(Map<String, dynamic> j) => DeliveryTerms(
    deliveryAvailable: (j['deliveryAvailable'] as bool?) ?? false,
    pickupAvailable: (j['pickupAvailable'] as bool?) ?? true,
    fee: dbl(j['fee']),
    freeFrom: dblOrNull(j['freeFrom']),
    etaMin: (j['etaMinMinutes'] as num?)?.toInt(),
    etaMax: (j['etaMaxMinutes'] as num?)?.toInt(),
  );
}

/// Server's verdict on the device cart.
class CartValidation {
  const CartValidation({
    required this.lines,
    required this.subtotal,
    this.delivery,
    required this.prescriptionRequired,
    required this.checkoutBlocked,
    required this.mixedBranches,
  });
  final List<ValidatedLine> lines;
  final double subtotal;
  final DeliveryTerms? delivery;
  final bool prescriptionRequired;
  final bool checkoutBlocked;
  final bool mixedBranches;

  ValidatedLine? lineFor(String offerId) {
    for (final l in lines) {
      if (l.offerId == offerId) return l;
    }
    return null;
  }

  factory CartValidation.fromJson(Map<String, dynamic> j) => CartValidation(
    lines: list(j['items'], ValidatedLine.fromJson),
    subtotal: dbl(j['subtotal']),
    delivery: j['delivery'] == null ? null : DeliveryTerms.fromJson(j['delivery'] as Map<String, dynamic>),
    prescriptionRequired: (j['prescriptionRequired'] as bool?) ?? false,
    checkoutBlocked: (j['checkoutBlocked'] as bool?) ?? false,
    mixedBranches: (j['mixedBranches'] as bool?) ?? false,
  );
}
