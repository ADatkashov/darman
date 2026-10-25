import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/user_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import '../../core/theme/colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _title(AppL10n l, AppNotification n) => switch (n.title) {
    'RX_APPROVED' => l.notifRxApproved,
    'RX_REJECTED' => l.notifRxRejected,
    'RX_UNDER_REVIEW' => l.notifRxReview,
    'ORDER_PLACED' => l.notifOrderPlaced,
    'ORDER_CANCELLED' => l.notifOrderCancelled,
    _ => l.notifOrderUpdate,
  };

  Future<void> _toggle(BuildContext context, WidgetRef ref, {bool? orders, bool? prescriptions, bool? promotions}) async {
    try {
      final u = await ref
          .read(userRepositoryProvider)
          .update(notifyOrders: orders, notifyPrescriptions: prescriptions, notifyPromotions: promotions);
      ref.read(authProvider.notifier).updateUser(u);
    } on ApiFailure catch (e) {
      if (context.mounted) showSnack(context, errorText(context.l10n, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final user = ref.watch(authProvider).user;
    final list = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.profileNotifications)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          await ref.read(notificationsProvider.future);
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, 0),
              child: Text(l.notifSettings, style: context.text.titleMedium),
            ),
            if (user != null) ...[
              SwitchListTile(
                title: Text(l.notifOrders),
                value: user.notifyOrders,
                onChanged: (v) => _toggle(context, ref, orders: v),
              ),
              SwitchListTile(
                title: Text(l.notifPrescriptions),
                value: user.notifyPrescriptions,
                onChanged: (v) => _toggle(context, ref, prescriptions: v),
              ),
              SwitchListTile(
                title: Text(l.notifPromotions),
                value: user.notifyPromotions,
                onChanged: (v) => _toggle(context, ref, promotions: v),
              ),
            ],
            const Divider(height: Sp.x6),
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x2),
              child: Text(l.notifInbox, style: context.text.titleMedium),
            ),
            list.when(
              loading: () => const Padding(padding: EdgeInsets.all(Sp.gutter), child: Skeleton(height: 64, radius: 16)),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(notificationsProvider)),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(Sp.x8),
                      child: Center(child: Text(l.notifEmpty, style: context.text.bodyMedium)),
                    )
                  : Column(
                      children: [
                        for (final n in items)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: context.dm.softMint,
                              child: Icon(
                                n.type == 'PRESCRIPTION' ? Icons.description_outlined : Icons.local_shipping_outlined,
                                color: context.scheme.primary,
                              ),
                            ),
                            title: Text(
                              _title(l, n),
                              style: context.text.titleSmall?.copyWith(fontWeight: n.read ? FontWeight.w500 : FontWeight.w800),
                            ),
                            subtitle: Text(formatDateTime(n.createdAt, loc)),
                            trailing: n.read ? null : Icon(Icons.circle, size: 10, color: context.scheme.primary),
                            onTap: () async {
                              if (!n.read) {
                                try {
                                  await ref.read(userRepositoryProvider).markNotificationRead(n.id);
                                } catch (_) {}
                                ref.invalidate(notificationsProvider);
                              }
                              if (n.refId != null && context.mounted) {
                                context.push(n.type == 'PRESCRIPTION' ? Routes.prescription(n.refId!) : Routes.order(n.refId!));
                              }
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
