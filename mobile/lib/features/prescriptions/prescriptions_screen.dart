import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/data_providers.dart';
import 'prescription_widgets.dart';
import '../../core/theme/colors.dart';

class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final list = ref.watch(prescriptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.rxHistory)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(Routes.prescriptionNew);
          ref.invalidate(prescriptionsProvider);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l.rxNewShort),
      ),
      body: list.when(
        loading: () => const ListSkeleton(count: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(prescriptionsProvider)),
        data: (items) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(prescriptionsProvider);
            await ref.read(prescriptionsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, 96),
            children: [
              InfoPanel(icon: Icons.verified_user_outlined, text: l.rxLegal),
              const SizedBox(height: Sp.x4),
              if (items.isEmpty)
                SizedBox(
                  height: 320,
                  child: EmptyState(icon: Icons.description_outlined, title: l.rxEmpty),
                )
              else
                for (final p in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: DmCard(
                      onTap: () async {
                        await context.push(Routes.prescription(p.id));
                        ref.invalidate(prescriptionsProvider);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_outlined, color: context.scheme.primary),
                              const SizedBox(width: Sp.x3),
                              Expanded(child: Text(formatDate(p.createdAt, loc), style: context.text.titleSmall)),
                              RxStatusPill(status: p.status),
                            ],
                          ),
                          const SizedBox(height: Sp.x2),
                          Text(l.rxFilesCount(p.files.length), style: context.text.bodySmall),
                          if (p.rejectionReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                l.rxRejectionReason(p.rejectionReason!),
                                style: context.text.bodySmall?.copyWith(color: context.scheme.error),
                              ),
                            ),
                          if (p.expiresAt != null && p.usableForOrder)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(l.rxValidUntil(formatDate(p.expiresAt!, loc)), style: context.text.bodySmall),
                            ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
