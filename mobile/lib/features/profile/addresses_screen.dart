import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import '../../core/theme/colors.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key, this.selectMode = false});
  final bool selectMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final list = ref.watch(addressesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.addressesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(Routes.addressEdit);
          ref.invalidate(addressesProvider);
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l.addressAdd),
      ),
      body: list.when(
        loading: () => const ListSkeleton(count: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(addressesProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.location_off_outlined, title: l.addressesEmpty)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
                itemBuilder: (_, i) {
                  final a = items[i];
                  return DmCard(
                    onTap: () async {
                      await context.push(Routes.addressEdit, extra: a);
                      ref.invalidate(addressesProvider);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: context.scheme.primary),
                        const SizedBox(width: Sp.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(a.label ?? a.street, style: context.text.titleSmall)),
                                  if (a.defaultAddress) ...[const SizedBox(width: Sp.x2), Pill(label: l.addressDefaultBadge)],
                                ],
                              ),
                              Text(a.formatted, style: context.text.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.delete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                content: Text(l.addressDeleteConfirm),
                                actions: [
                                  TextButton(onPressed: () => ctx.pop(false), child: Text(l.cancel)),
                                  FilledButton(
                                    onPressed: () => ctx.pop(true),
                                    style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
                                    child: Text(l.delete),
                                  ),
                                ],
                              ),
                            );
                            if (ok != true) return;
                            try {
                              await ref.read(userRepositoryProvider).deleteAddress(a.id);
                              ref.invalidate(addressesProvider);
                            } on ApiFailure catch (e) {
                              if (context.mounted) showSnack(context, errorText(l, e));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
