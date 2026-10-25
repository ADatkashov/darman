import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/cart_models.dart';
import 'core_providers.dart';

class CartState {
  const CartState([this.lines = const []]);
  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (a, l) => a + l.quantity);
  double get subtotal => lines.fold(0.0, (a, l) => a + l.lineTotal);
  bool get hasRx => lines.any((l) => l.rxRequired);
  String? get branchId => lines.isEmpty ? null : lines.first.branchId;
  String? get pharmacyLabel => lines.isEmpty ? null : '${lines.first.pharmacyName} · ${lines.first.branchName}';
}

enum AddResult { added, branchMismatch, limitReached }

/// Device-local cart persisted in SharedPreferences, so it survives restarts and works for guests.
/// Prices and stock stored here are display snapshots; the server re-validates everything at checkout.
class CartNotifier extends Notifier<CartState> {
  static const _key = 'cart.v1';
  static const maxPerLine = 99;

  @override
  CartState build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const CartState();
    try {
      final list = (jsonDecode(raw) as List).map((e) => CartLine.fromJson(e as Map<String, dynamic>)).toList();
      return CartState(list);
    } catch (_) {
      return const CartState();
    }
  }

  void _commit(List<CartLine> lines) {
    state = CartState(List.unmodifiable(lines));
    ref.read(sharedPrefsProvider).setString(_key, jsonEncode([for (final l in lines) l.toJson()]));
  }

  /// Adds a line. A cart can only hold items of one pharmacy branch; the caller decides whether to [replace].
  AddResult add(CartLine line, {bool replace = false}) {
    var lines = [...state.lines];
    if (lines.isNotEmpty && lines.first.branchId != line.branchId) {
      if (!replace) return AddResult.branchMismatch;
      lines = [];
    }
    final i = lines.indexWhere((l) => l.offerId == line.offerId);
    if (i >= 0) {
      final cap = [maxPerLine, if (line.maxQuantity > 0) line.maxQuantity].reduce((a, b) => a < b ? a : b);
      final q = lines[i].quantity + line.quantity;
      if (q > cap) {
        _commit(lines);
        return AddResult.limitReached;
      }
      lines[i] = lines[i].copyWith(quantity: q, unitPrice: line.unitPrice, maxQuantity: line.maxQuantity);
    } else {
      lines.add(line);
    }
    _commit(lines);
    return AddResult.added;
  }

  void setQuantity(String offerId, int quantity) {
    if (quantity <= 0) return remove(offerId);
    _commit([
      for (final l in state.lines)
        if (l.offerId == offerId)
          l.copyWith(
            quantity: quantity > maxPerLine ? maxPerLine : (l.maxQuantity > 0 && quantity > l.maxQuantity ? l.maxQuantity : quantity),
          )
        else
          l,
    ]);
  }

  void remove(String offerId) => _commit([
    for (final l in state.lines)
      if (l.offerId != offerId) l,
  ]);

  void clear() => _commit(const []);

  /// Accepts the server's current price/stock for a line (user acknowledged a change).
  void applyServerLine(String offerId, {required double unitPrice, required int availableQuantity}) {
    _commit([
      for (final l in state.lines)
        if (l.offerId == offerId)
          l.copyWith(
            unitPrice: unitPrice,
            maxQuantity: availableQuantity,
            quantity: availableQuantity > 0 && l.quantity > availableQuantity ? availableQuantity : l.quantity,
          )
        else
          l,
    ]);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
