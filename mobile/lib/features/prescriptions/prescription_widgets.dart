import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../data/models/prescription_models.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';

String rxStatusLabel(AppL10n l, PrescriptionStatus s) => switch (s) {
  PrescriptionStatus.draft => l.rxStatusDraft,
  PrescriptionStatus.submitted => l.rxStatusSubmitted,
  PrescriptionStatus.underReview => l.rxStatusUnderReview,
  PrescriptionStatus.approved => l.rxStatusApproved,
  PrescriptionStatus.rejected => l.rxStatusRejected,
  PrescriptionStatus.expired => l.rxStatusExpired,
};

class RxStatusPill extends StatelessWidget {
  const RxStatusPill({super.key, required this.status});
  final PrescriptionStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PrescriptionStatus.approved => context.dm.success,
      PrescriptionStatus.rejected => context.scheme.error,
      PrescriptionStatus.expired => context.dm.textSecondary,
      PrescriptionStatus.draft => context.dm.textSecondary,
      _ => const Color(0xFF9A6200),
    };
    final icon = switch (status) {
      PrescriptionStatus.approved => Icons.verified_outlined,
      PrescriptionStatus.rejected => Icons.cancel_outlined,
      PrescriptionStatus.expired => Icons.event_busy_outlined,
      PrescriptionStatus.draft => Icons.edit_note_outlined,
      PrescriptionStatus.underReview => Icons.hourglass_top_rounded,
      PrescriptionStatus.submitted => Icons.send_outlined,
    };
    return Pill(label: rxStatusLabel(context.l10n, status), color: color, icon: icon);
  }
}

String rxEventLabel(AppL10n l, String type) => switch (type) {
  'CREATED' => l.rxEventCreated,
  'SUBMITTED' => l.rxEventSubmitted,
  'REVIEW_STARTED' => l.rxEventReviewStarted,
  'APPROVED' => l.rxEventApproved,
  'REJECTED' => l.rxEventRejected,
  'EXPIRED' => l.rxEventExpired,
  _ => type,
};

/// Warm accent used by prescription info banners.
Color rxWarn(BuildContext context) => DmPalette.warning.withValues(alpha: 0.14);
