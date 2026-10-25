import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/core_providers.dart';
import '../../core/theme/colors.dart';

class PharmaciesScreen extends ConsumerWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final branches = ref.watch(branchesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pharmaciesTitle)),
      body: branches.when(
        loading: () => const ListSkeleton(count: 4),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(branchesProvider)),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(Sp.gutter),
          itemCount: list.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
          itemBuilder: (_, i) {
            if (i == list.length) return Text(l.demoDataNote, style: context.text.bodySmall);
            final b = list[i];
            return DmCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_pharmacy_outlined, color: context.scheme.primary),
                      const SizedBox(width: Sp.x3),
                      Expanded(child: Text(b.name, style: context.text.titleSmall)),
                      if (b.distanceKm != null) Text(l.pharmacyDistance(b.distanceKm!.toStringAsFixed(1)), style: context.text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: Sp.x2),
                  Text(b.address, style: context.text.bodyMedium),
                  if (b.openingHours != null) Text(l.pharmacyHours(b.openingHours!), style: context.text.bodySmall),
                  const SizedBox(height: Sp.x2),
                  Wrap(
                    spacing: Sp.x2,
                    runSpacing: 4,
                    children: [
                      Pill(
                        label: b.deliveryAvailable
                            ? '${l.pharmacyDelivers}${b.deliveryFee > 0 ? ' · ${formatMoney(b.deliveryFee, loc)}' : ''}'
                            : l.pharmacyPickupOnly,
                        color: context.scheme.primary,
                      ),
                      if (b.demo) Pill(label: l.pharmacyDemoNote, color: const Color(0xFF8A5A00)),
                      if (!b.licenseVerified) Pill(label: l.licenseNotVerified, color: context.dm.textSecondary),
                    ],
                  ),
                  if (b.phone != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => launchUrl(Uri(scheme: 'tel', path: b.phone!.replaceAll(' ', ''))),
                        icon: const Icon(Icons.call_outlined, size: 18),
                        label: Text(l.pharmacyCall),
                      ),
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
