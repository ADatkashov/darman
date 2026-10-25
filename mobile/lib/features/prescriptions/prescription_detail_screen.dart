import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/prescription_models.dart';
import '../../design/form_fields.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/cart_state.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import 'prescription_widgets.dart';
import '../../core/theme/colors.dart';

class PrescriptionDetailScreen extends ConsumerWidget {
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});
  final String prescriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = context.localeCode;
    final rx = ref.watch(prescriptionDetailProvider(prescriptionId));
    return Scaffold(
      appBar: AppBar(title: Text(l.rxTitle)),
      body: rx.when(
        loading: () => const ListSkeleton(count: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(prescriptionDetailProvider(prescriptionId))),
        data: (p) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(prescriptionDetailProvider(prescriptionId));
            await ref.read(prescriptionDetailProvider(prescriptionId).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(Sp.gutter),
            children: [
              Row(
                children: [
                  Expanded(child: Text(formatDate(p.createdAt, loc), style: context.text.headlineSmall)),
                  RxStatusPill(status: p.status),
                ],
              ),
              const SizedBox(height: Sp.x4),
              if (p.status == PrescriptionStatus.rejected && p.rejectionReason != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: InlineError(l.rxRejectionReason(p.rejectionReason!)),
                ),
              if (p.status == PrescriptionStatus.approved && p.expiresAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: InfoPanel(icon: Icons.verified_outlined, text: '${l.rxUsable}. ${l.rxValidUntil(formatDate(p.expiresAt!, loc))}'),
                ),
              if (p.demoReview)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: InfoPanel(icon: Icons.science_outlined, text: l.rxDemoReview, tint: rxWarn(context)),
                ),
              InfoPanel(icon: Icons.verified_user_outlined, text: l.rxLegal),
              const SizedBox(height: Sp.x5),
              Text(l.rxFilesCount(p.files.length), style: context.text.titleMedium),
              const SizedBox(height: Sp.x2),
              for (final f in p.files)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x2),
                  child: DmCard(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
                    onTap: f.isPdf ? null : () => _preview(context, ref, p.id, f),
                    child: Row(
                      children: [
                        Icon(f.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined, color: context.scheme.primary),
                        const SizedBox(width: Sp.x3),
                        Expanded(child: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text('${(f.sizeBytes / 1024).round()} KB', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ),
              if (p.note != null)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.x2),
                  child: Text(p.note!, style: context.text.bodyMedium),
                ),
              const SizedBox(height: Sp.x5),
              Text(l.rxTimeline, style: context.text.titleMedium),
              const SizedBox(height: Sp.x3),
              for (final e in p.events)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.x3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 10, color: context.scheme.primary),
                      const SizedBox(width: Sp.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rxEventLabel(l, e.type), style: context.text.titleSmall),
                            Text(formatDateTime(e.createdAt, loc), style: context.text.bodySmall),
                            if (e.comment != null && e.type != 'CREATED')
                              Text(e.comment!, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurface)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Sp.x4),
              if (p.status == PrescriptionStatus.draft) ...[
                FilledButton(
                  onPressed: () async {
                    try {
                      await ref.read(prescriptionRepositoryProvider).submit(p.id);
                      ref.invalidate(prescriptionDetailProvider(p.id));
                      ref.invalidate(prescriptionsProvider);
                      if (context.mounted) showSnack(context, l.rxSubmittedOk);
                    } on ApiFailure catch (e) {
                      if (context.mounted) showSnack(context, errorText(l, e));
                    }
                  },
                  child: Text(l.rxSubmit),
                ),
                const SizedBox(height: Sp.x2),
                TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(prescriptionRepositoryProvider).deleteDraft(p.id);
                      ref.invalidate(prescriptionsProvider);
                      if (context.mounted) context.pop();
                    } on ApiFailure catch (e) {
                      if (context.mounted) showSnack(context, errorText(l, e));
                    }
                  },
                  child: Text(l.rxDeleteDraft),
                ),
              ],
              if (p.usableForOrder)
                FilledButton.icon(
                  onPressed: () => context.go(ref.read(cartProvider).isEmpty ? Routes.home : Routes.cart),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text(ref.read(cartProvider).isEmpty ? l.goToCatalog : l.cartCheckout),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preview(BuildContext context, WidgetRef ref, String id, PrescriptionFile f) async {
    final l = context.l10n;
    try {
      final bytes = Uint8List.fromList(await ref.read(prescriptionRepositoryProvider).fileBytes(id, f.id));
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain, semanticLabel: f.name),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: l.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      );
    } on ApiFailure catch (e) {
      if (context.mounted) showSnack(context, errorText(l, e));
    }
  }
}
