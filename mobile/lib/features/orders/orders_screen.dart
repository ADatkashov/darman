import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/data_providers.dart';
import 'order_widgets.dart';
import '../../core/theme/colors.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final authed = ref.watch(authProvider.select((a) => a.isAuthenticated));
    if (!authed) {
      return Scaffold(
        appBar: AppBar(title: Text(l.ordersTitle)),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: l.ordersGuestTitle,
          body: l.ordersGuestBody,
          actionLabel: l.profileLoginRegister,
          onAction: () => context.push('${Routes.login}?from=${Uri.encodeComponent(Routes.orders)}'),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.ordersTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.ordersActive),
              Tab(text: l.ordersHistory),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(scope: 'active', emptyText: l.ordersEmptyActive),
            _OrderList(scope: 'history', emptyText: l.ordersEmptyHistory),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({required this.scope, required this.emptyText});
  final String scope;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final orders = ref.watch(ordersProvider(scope));
    return orders.when(
      loading: () => const ListSkeleton(count: 4),
      error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(ordersProvider(scope))),
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider(scope));
          await ref.read(ordersProvider(scope).future);
        },
        child: list.isEmpty
            ? LayoutBuilder(
                builder: (_, c) => ListView(
                  children: [
                    SizedBox(
                      height: c.maxHeight,
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: emptyText,
                        actionLabel: l.goToCatalog,
                        onAction: () => context.go(Routes.home),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(Sp.gutter),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
                itemBuilder: (_, i) => _OrderCard(order: list[i], loc: loc),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.loc});
  final OrderSummary order;
  final String loc;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DmCard(
      onTap: () => context.push(Routes.order(order.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.orderNumber(order.number), style: context.text.titleSmall)),
              StatusPill(status: order.status, pickup: order.pickup),
            ],
          ),
          const SizedBox(height: Sp.x2),
          if (order.firstItemName != null)
            Text(
              order.itemCount > 1 ? '${order.firstItemName} + ${order.itemCount - 1}' : order.firstItemName!,
              style: context.text.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (order.pharmacyName != null) Text(order.pharmacyName!, style: context.text.bodySmall),
          const SizedBox(height: Sp.x3),
          Row(
            children: [
              Icon(order.pickup ? Icons.storefront_outlined : Icons.local_shipping_outlined, size: 16, color: context.dm.textSecondary),
              const SizedBox(width: 6),
              Text(formatDateTime(order.createdAt, loc), style: context.text.bodySmall),
              const Spacer(),
              Text(formatMoney(order.total, loc), style: context.text.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
