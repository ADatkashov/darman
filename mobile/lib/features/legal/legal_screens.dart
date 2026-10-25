import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/core_providers.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final privacy = kind == 'privacy';
    return Scaffold(
      appBar: AppBar(title: Text(privacy ? l.profilePrivacy : l.profileTerms)),
      body: ListView(
        padding: const EdgeInsets.all(Sp.gutter),
        children: [
          InfoPanel(icon: Icons.gavel_outlined, text: l.legalDraftNote, tint: DmPalette.warning.withValues(alpha: 0.14)),
          const SizedBox(height: Sp.x4),
          Text(privacy ? l.privacyBody : l.termsBody, style: context.text.bodyLarge),
          const SizedBox(height: Sp.x4),
          Text(l.medicalDisclaimer, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final phone = ref.watch(runtimeConfigProvider).value?.supportPhone ?? '';
    Widget faq(String q, String a) => ExpansionTile(
      title: Text(q, style: context.text.titleSmall),
      childrenPadding: const EdgeInsets.fromLTRB(Sp.x4, 0, Sp.x4, Sp.x4),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(a, style: context.text.bodyMedium)],
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Sp.x2),
        children: [
          faq(l.helpFaqRxQ, l.helpFaqRxA),
          faq(l.helpFaqDeliveryQ, l.helpFaqDeliveryA),
          faq(l.helpFaqPayQ, l.helpFaqPayA),
          const SizedBox(height: Sp.x4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
            child: phone.isEmpty
                ? InfoPanel(icon: Icons.support_agent_outlined, text: l.helpNoPhone)
                : FilledButton.icon(
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                    icon: const Icon(Icons.call_outlined),
                    label: Text('${l.helpContact}: $phone'),
                  ),
          ),
          const SizedBox(height: Sp.x4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
            child: InfoPanel(icon: Icons.emergency_outlined, text: l.helpEmergency, tint: context.scheme.error.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(Sp.gutter),
            child: Text(l.medicalDisclaimer, style: context.text.bodySmall),
          ),
        ],
      ),
    );
  }
}
