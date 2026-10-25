import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../design/logo.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/data_providers.dart';
import '../orders/order_widgets.dart';
import '../../core/theme/colors.dart';

class OrderDoneScreen extends ConsumerWidget {
  const OrderDoneScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final order = ref.watch(orderDetailProvider(orderId));
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BotanicalDecor(size: 240, opacity: 0.12)),
          SafeArea(
            child: order.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(orderDetailProvider(orderId))),
              data: (o) => Padding(
                padding: const EdgeInsets.all(Sp.x6),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(color: context.dm.softMint, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: 64, color: context.scheme.primary),
                    ),
                    const SizedBox(height: Sp.x6),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(l.coDoneTitle, style: context.text.headlineMedium, textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: Sp.x2),
                    Text(l.coDoneBody(o.number), style: context.text.titleMedium?.copyWith(color: context.scheme.primary)),
                    const SizedBox(height: Sp.x2),
                    Text(formatMoney(o.total, context.localeCode), style: context.text.titleLarge),
                    const SizedBox(height: Sp.x3),
                    PaymentStatusPill(status: o.paymentStatus),
                    if (o.demo)
                      Padding(
                        padding: const EdgeInsets.only(top: Sp.x4),
                        child: InfoPanel(icon: Icons.science_outlined, text: l.coDoneDemo),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        context.go(Routes.orders);
                        context.push(Routes.order(o.id));
                      },
                      child: Text(l.coViewOrder),
                    ),
                    const SizedBox(height: Sp.x3),
                    TextButton(onPressed: () => context.go(Routes.home), child: Text(l.coBackHome)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
