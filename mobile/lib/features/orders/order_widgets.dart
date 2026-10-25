import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';

String statusLabel(AppL10n l, OrderStatus s, {bool pickup = false}) => switch (s) {
  OrderStatus.placed => l.statusPlaced,
  OrderStatus.confirmed => l.statusConfirmed,
  OrderStatus.preparing => l.statusPreparing,
  OrderStatus.readyForPickup => l.statusReadyForPickup,
  OrderStatus.inTransit => l.statusInTransit,
  OrderStatus.delivered => pickup ? l.statusDeliveredPickup : l.statusDelivered,
  OrderStatus.cancelled => l.statusCancelled,
};

Color statusColor(BuildContext context, OrderStatus s) => switch (s) {
  OrderStatus.cancelled => context.scheme.error,
  OrderStatus.delivered => context.dm.success,
  OrderStatus.inTransit || OrderStatus.readyForPickup => context.scheme.primary,
  _ => const Color(0xFF9A6200),
};

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, this.pickup = false});
  final OrderStatus status;
  final bool pickup;
  @override
  Widget build(BuildContext context) => Pill(
    label: statusLabel(context.l10n, status, pickup: pickup),
    color: statusColor(context, status),
  );
}

class PaymentStatusPill extends StatelessWidget {
  const PaymentStatusPill({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (String label, Color color) = switch (status) {
      'PAID' => (l.payPaid, context.dm.success),
      'DEMO_PAID' => (l.payDemoPaid, const Color(0xFF9A6200)),
      'PENDING' => (l.payPending, const Color(0xFF9A6200)),
      'FAILED' => (l.payFailed, context.scheme.error),
      'REFUND_PENDING' => (l.payRefundPending, const Color(0xFF9A6200)),
      'REFUNDED' => (l.payRefunded, context.dm.textSecondary),
      _ => (l.payUnpaid, context.dm.textSecondary),
    };
    return Pill(label: label, color: color, icon: Icons.payments_outlined);
  }
}

/// Vertical timeline: placed → confirmed → preparing → (ready for pickup | in transit) → delivered; cancelled replaces the tail.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeCode;
    final steps = order.status == OrderStatus.cancelled
        ? [...timelineFor(order.pickup).where((s) => order.timeOf(s) != null && s != OrderStatus.delivered), OrderStatus.cancelled]
        : timelineFor(order.pickup);
    final currentIndex = order.status == OrderStatus.cancelled ? steps.length - 1 : steps.indexOf(order.status);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            label: statusLabel(l, steps[i], pickup: order.pickup),
            time: order.timeOf(steps[i]) == null ? null : formatDateTime(order.timeOf(steps[i])!, loc),
            done: i < currentIndex || (order.status == OrderStatus.delivered && i == currentIndex),
            current: i == currentIndex && order.status != OrderStatus.delivered,
            cancelled: steps[i] == OrderStatus.cancelled,
            last: i == steps.length - 1,
            hint: i == currentIndex ? _hint(l, steps[i]) : null,
          ),
      ],
    );
  }

  String? _hint(AppL10n l, OrderStatus s) => switch (s) {
    OrderStatus.preparing => l.statusPreparingHint,
    OrderStatus.inTransit => l.statusInTransitHint,
    _ => null,
  };
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    this.time,
    required this.done,
    required this.current,
    required this.cancelled,
    required this.last,
    this.hint,
  });
  final String label;
  final String? time;
  final bool done;
  final bool current;
  final bool cancelled;
  final bool last;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final color = cancelled
        ? context.scheme.error
        : (done || current)
        ? context.scheme.primary
        : context.dm.divider;
    return Semantics(
      label: '$label${time != null ? ', $time' : ''}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || cancelled ? color : Colors.white,
                      border: Border.all(color: color, width: current ? 3 : 2),
                    ),
                    child: done || cancelled
                        ? Icon(cancelled ? Icons.close_rounded : Icons.check_rounded, size: 15, color: Colors.white)
                        : null,
                  ),
                  if (!last) Expanded(child: Container(width: 2, color: done ? context.scheme.primary : context.dm.divider)),
                ],
              ),
            ),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Sp.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.text.titleSmall?.copyWith(
                        color: (done || current || cancelled) ? null : context.dm.textSecondary,
                        fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    if (time != null) Text(time!, style: context.text.bodySmall),
                    if (hint != null) Text(hint!, style: context.text.bodySmall?.copyWith(color: context.scheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
