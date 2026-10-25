import '../../core/utils/formatters.dart';
import '../../data/models/cart_models.dart';

class Totals {
  const Totals({required this.subtotal, required this.discount, required this.deliveryFee, required this.total});
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
}

/// Mirrors the server's pricing rules (the server remains the authority and re-computes everything):
/// delivery is free for pickup and once the subtotal reaches the branch's free-delivery threshold.
double deliveryFeeFor({required bool pickup, required DeliveryTerms? terms, required double subtotal}) {
  if (pickup || terms == null || !terms.deliveryAvailable) return 0;
  final free = terms.freeFrom;
  if (free != null && subtotal >= free) return 0;
  return roundMoney(terms.fee);
}

Totals computeTotals({required double subtotal, double discount = 0, required bool pickup, DeliveryTerms? terms}) {
  final fee = deliveryFeeFor(pickup: pickup, terms: terms, subtotal: subtotal);
  final total = roundMoney((subtotal - discount + fee).clamp(0, double.infinity));
  return Totals(subtotal: roundMoney(subtotal), discount: roundMoney(discount), deliveryFee: fee, total: total);
}
