import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cart_models.dart';
import '../../data/models/order_models.dart';
import '../../state/cart_state.dart';
import '../../state/core_providers.dart';

/// Promo code the user applied in the cart (re-validated against the current subtotal).
class PromoCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? code) => state = code;
}

final promoCodeProvider = NotifierProvider<PromoCodeNotifier, String?>(PromoCodeNotifier.new);

class Quote {
  const Quote({required this.validation, this.promo, this.promoCode});
  final CartValidation validation;
  final PromoCheck? promo;
  final String? promoCode;

  double get subtotal => validation.subtotal;
  bool get promoApplied => promo?.valid == true;
  double get discount => promoApplied ? promo!.discountAmount : 0;
}

/// Server verdict on the device cart (availability, current prices, delivery terms) plus the promo discount.
/// Re-evaluated whenever the cart or the promo code changes.
final quoteProvider = FutureProvider.autoDispose<Quote>((ref) async {
  final cart = ref.watch(cartProvider);
  final code = ref.watch(promoCodeProvider);
  final repo = ref.watch(orderRepositoryProvider);
  final validation = await repo.validateCart(cart.lines);
  PromoCheck? promo;
  if (code != null) {
    try {
      promo = await ref.watch(catalogRepositoryProvider).checkPromo(code, validation.subtotal);
    } catch (_) {
      promo = null;
    }
  }
  return Quote(validation: validation, promo: promo, promoCode: code);
});
