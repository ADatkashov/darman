import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/order_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import '../cart/cart_actions.dart';
import 'order_widgets.dart';
import '../../core/theme/colors.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  Timer? _poll;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // While the order is in progress, refresh its status periodically (no push channel is connected yet).
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      final o = ref.read(orderDetailProvider(widget.orderId)).value;
      if (mounted && (o == null || o.isActive)) ref.invalidate(orderDetailProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _cancel(OrderDetail o) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.orderCancelConfirm),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(l.no)),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            child: Text(l.orderCancel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(orderRepositoryProvider).cancel(o.id);
      ref.invalidate(orderDetailProvider(o.id));
      ref.invalidate(ordersProvider);
      if (mounted) showSnack(context, l.orderCancelled);
    } on ApiFailure catch (e) {
      ref.invalidate(orderDetailProvider(o.id));
      if (mounted) showSnack(context, errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reorder(OrderDetail o) async {
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      final v = await ref.read(orderRepositoryProvider).reorder(o.id);
      var added = 0, skipped = 0, changed = 0;
      for (final line in v.lines) {
        final canAdd =
            line.status == LineStatus.ok ||
            line.status == LineStatus.priceChanged ||
            (line.status == LineStatus.lowStock && line.availableQuantity > 0);
        if (!canAdd || line.productId == null) {
          skipped++;
          continue;
        }
        if (line.status != LineStatus.ok) changed++;
        final qty = line.status == LineStatus.lowStock ? line.availableQuantity : line.quantity;
        if (!mounted) return;
        final ok = await addLineToCart(
          context,
          ref,
          CartLine(
            offerId: line.offerId,
            productId: line.productId!,
            name: line.productName ?? '',
            spec: line.spec,
            rxRequired: line.rxRequired,
            branchId: line.branchId ?? '',
            branchName: line.branchName ?? '',
            pharmacyName: line.pharmacyName ?? '',
            unitPrice: line.unitPrice,
            quantity: qty,
            maxQuantity: line.availableQuantity,
          ),
        );
        if (ok) {
          added++;
        } else {
          skipped++;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final msg = [
        if (added > 0) l.orderReorderDone(added),
        if (skipped > 0) l.orderReorderSkipped(skipped),
        if (changed > 0) l.orderReorderChanged,
      ].join('\n');
      if (msg.isNotEmpty) showSnack(context, msg);
      if (added > 0) context.go(Routes.cart);
    } on ApiFailure catch (e) {
      if (mounted) showSnack(context, errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showReceipt(OrderDetail o) {
    final l = context.l10n;
    final loc = context.localeCode;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Sp.x5, 0, Sp.x5, Sp.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.orderReceipt, style: context.text.titleLarge),
              Text(l.orderNumber(o.number), style: context.text.bodyMedium),
              if (o.pharmacyName != null) Text('${o.pharmacyName} · ${o.branchName ?? ''}', style: context.text.bodySmall),
              const SizedBox(height: Sp.x4),
              for (final i in o.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text('${i.name} × ${i.quantity}')),
                      Text(formatMoney(i.lineTotal, loc)),
                    ],
                  ),
                ),
              const Divider(),
              _kv(context, l.cartSubtotal, formatMoney(o.subtotal, loc)),
              if (o.discount > 0) _kv(context, l.cartDiscount, '−${formatMoney(o.discount, loc)}'),
              _kv(context, l.cartDelivery, o.deliveryFee == 0 ? l.free : formatMoney(o.deliveryFee, loc)),
              _kv(context, l.cartTotal, formatMoney(o.total, loc), bold: true),
              const SizedBox(height: Sp.x3),
              PaymentStatusPill(status: o.paymentStatus),
              const SizedBox(height: Sp.x4),
              InfoPanel(icon: Icons.info_outline, text: l.orderReceiptNotice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(k)),
        Text(v, style: bold ? context.text.titleMedium : null),
      ],
    ),
  );

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (!await launchUrl(uri) && mounted) showSnack(context, context.l10n.errUnknown);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeCode;
    final order = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l.orderDetails)),
      body: order.when(
        loading: () => const ListSkeleton(count: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId))),
        data: (o) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orderDetailProvider(o.id));
            await ref.read(orderDetailProvider(o.id).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(Sp.gutter),
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.orderNumber(o.number), style: context.text.headlineSmall)),
                  StatusPill(status: o.status, pickup: o.pickup),
                ],
              ),
              const SizedBox(height: Sp.x1),
              Text(formatDateTime(o.createdAt, loc), style: context.text.bodySmall),
              const SizedBox(height: Sp.x5),
              DmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.orderTracking, style: context.text.titleMedium),
                    const SizedBox(height: Sp.x4),
                    OrderTimeline(order: o),
                    if (!o.pickup && o.isActive && (o.slotStart != null || o.etaFrom != null)) ...[
                      const Divider(),
                      const SizedBox(height: Sp.x3),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, size: 18, color: context.scheme.primary),
                          const SizedBox(width: Sp.x2),
                          Expanded(
                            child: Text(
                              o.slotStart != null
                                  ? '${l.orderWindow}: ${formatDate(o.slotStart!, loc)}, ${formatTime(o.slotStart!, loc)}–${formatTime(o.slotEnd!, loc)}'
                                  : '${l.orderWindow}: ${l.orderEtaEstimate(formatTime(o.etaFrom!, loc), formatTime(o.etaTo!, loc))}',
                              style: context.text.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (o.courier != null) ...[
                const SizedBox(height: Sp.x3),
                DmCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: context.dm.softMint,
                        child: Icon(Icons.delivery_dining_outlined, color: context.scheme.primary),
                      ),
                      const SizedBox(width: Sp.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.orderCourier, style: context.text.bodySmall),
                            Text(o.courier!.demo ? l.orderCourierDemo : o.courier!.name, style: context.text.titleSmall),
                          ],
                        ),
                      ),
                      if (o.courier!.phone != null && !o.courier!.demo)
                        IconButton.filledTonal(
                          tooltip: l.orderCall,
                          onPressed: () => _call(o.courier!.phone!),
                          icon: const Icon(Icons.call_outlined),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Sp.x3),
              DmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(o.pickup ? Icons.storefront_outlined : Icons.location_on_outlined, color: context.scheme.primary, size: 20),
                        const SizedBox(width: Sp.x2),
                        Text(o.pickup ? l.orderPickupAddress : l.orderAddress, style: context.text.titleSmall),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    Text(
                      o.pickup ? '${o.pharmacyName ?? ''} · ${o.branchName ?? ''}\n${o.branchAddress ?? ''}' : (o.deliveryAddress ?? ''),
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sp.x3),
              DmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.orderItems, style: context.text.titleSmall),
                    const SizedBox(height: Sp.x3),
                    for (final i in o.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Sp.x3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(i.name, style: context.text.bodyMedium),
                                  Text('${formatMoney(i.unitPrice, loc)} × ${i.quantity}', style: context.text.bodySmall),
                                ],
                              ),
                            ),
                            Text(formatMoney(i.lineTotal, loc), style: context.text.bodyMedium),
                          ],
                        ),
                      ),
                    const Divider(),
                    const SizedBox(height: Sp.x2),
                    _kv(context, l.cartSubtotal, formatMoney(o.subtotal, loc)),
                    if (o.discount > 0) _kv(context, l.cartDiscount, '−${formatMoney(o.discount, loc)}'),
                    _kv(context, l.cartDelivery, o.deliveryFee == 0 ? l.free : formatMoney(o.deliveryFee, loc)),
                    _kv(context, l.cartTotal, formatMoney(o.total, loc), bold: true),
                    const SizedBox(height: Sp.x3),
                    Row(
                      children: [
                        Text('${l.orderPayment}: ', style: context.text.bodySmall),
                        PaymentStatusPill(status: o.paymentStatus),
                      ],
                    ),
                  ],
                ),
              ),
              if (o.demo && o.isActive)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.x3),
                  child: InfoPanel(icon: Icons.science_outlined, text: l.orderSimulatedNote),
                ),
              const SizedBox(height: Sp.x5),
              if (o.canCancel)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _cancel(o),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l.orderCancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.scheme.error,
                    side: BorderSide(color: context.scheme.error.withValues(alpha: 0.5)),
                  ),
                ),
              if (o.canCancel) const SizedBox(height: Sp.x3),
              FilledButton.icon(
                onPressed: _busy ? null : () => _reorder(o),
                icon: const Icon(Icons.replay_rounded),
                label: Text(l.orderReorder),
              ),
              const SizedBox(height: Sp.x3),
              if (o.status != OrderStatus.cancelled)
                OutlinedButton.icon(
                  onPressed: () => _showReceipt(o),
                  icon: const Icon(Icons.receipt_outlined),
                  label: Text(l.orderReceipt),
                ),
              const SizedBox(height: Sp.x5),
              Text(l.orderSupport, style: context.text.titleSmall),
              const SizedBox(height: Sp.x1),
              Text(l.orderSupportBody, style: context.text.bodySmall),
              const SizedBox(height: Sp.x2),
              Wrap(
                spacing: Sp.x2,
                children: [
                  if (o.branchPhone != null)
                    ActionChip(
                      avatar: const Icon(Icons.call_outlined, size: 18),
                      label: Text(l.orderContactPharmacy),
                      onPressed: () => _call(o.branchPhone!),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.support_agent_outlined, size: 18),
                    label: Text(l.profileHelp),
                    onPressed: () => context.push(Routes.help),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
