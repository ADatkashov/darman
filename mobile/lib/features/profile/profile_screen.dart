import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config_version.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../core/network/api_failure.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import '../../core/theme/colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    Widget item(IconData icon, String label, VoidCallback onTap, {Widget? trailing, Color? color}) => ListTile(
      leading: Icon(icon, color: color ?? context.scheme.primary),
      title: Text(label, style: context.text.bodyLarge?.copyWith(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        children: [
          if (auth.isAuthenticated && user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, Sp.x4),
              child: DmCard(
                onTap: () => context.push(Routes.profileEdit),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.dm.softMint,
                      child: Text(
                        _initials(user.fullName, user.phone),
                        style: context.text.titleMedium?.copyWith(color: context.scheme.primary),
                      ),
                    ),
                    const SizedBox(width: Sp.x4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName ?? l.profileFullName, style: context.text.titleMedium),
                          Text(
                            Validators.prettyPhone(user.phone),
                            style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, Sp.x4),
              child: DmCard(
                color: context.dm.softMint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.profileGuestTitle, style: context.text.titleMedium),
                    const SizedBox(height: Sp.x1),
                    Text(l.profileGuestBody, style: context.text.bodyMedium),
                    const SizedBox(height: Sp.x4),
                    FilledButton(onPressed: () => context.push(Routes.login), child: Text(l.profileLoginRegister)),
                  ],
                ),
              ),
            ),
          if (auth.sessionExpired)
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, 0, Sp.gutter, Sp.x3),
              child: InfoPanel(icon: Icons.lock_clock_outlined, text: l.errSessionExpired),
            ),
          if (auth.isAuthenticated) ...[
            item(Icons.receipt_long_outlined, l.profileMyOrders, () => context.go(Routes.orders)),
            item(Icons.description_outlined, l.profileRx, () => context.push(Routes.prescriptions)),
            item(Icons.location_on_outlined, l.profileAddresses, () => context.push(Routes.addresses)),
          ],
          item(Icons.favorite_border_rounded, l.profileFavorites, () => context.push(Routes.favorites)),
          if (auth.isAuthenticated)
            item(Icons.notifications_none_rounded, l.profileNotifications, () => context.push(Routes.notifications)),
          const Divider(height: Sp.x6),
          item(
            Icons.language_rounded,
            l.profileLanguage,
            () => _languageSheet(context, ref),
            trailing: Text(_langName(locale.languageCode), style: context.text.bodyMedium),
          ),
          item(
            Icons.brightness_6_outlined,
            l.themeTitle,
            () => _themeSheet(context, ref),
            trailing: Text(switch (themeMode) {
              ThemeMode.dark => l.themeDark,
              ThemeMode.system => l.themeSystem,
              _ => l.themeLight,
            }, style: context.text.bodyMedium),
          ),
          item(Icons.storefront_outlined, l.pharmaciesTitle, () => context.push(Routes.pharmacies)),
          item(Icons.help_outline_rounded, l.profileHelp, () => context.push(Routes.help)),
          item(Icons.privacy_tip_outlined, l.profilePrivacy, () => context.push(Routes.legal('privacy'))),
          item(Icons.gavel_outlined, l.profileTerms, () => context.push(Routes.legal('terms'))),
          if (auth.isAuthenticated) ...[
            const Divider(height: Sp.x6),
            item(Icons.logout_rounded, l.profileLogout, () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text(l.profileLogoutConfirm),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: Text(l.cancel)),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
                      child: Text(l.profileLogout),
                    ),
                  ],
                ),
              );
              if (ok == true) await ref.read(authProvider.notifier).logout();
            }),
            item(
              Icons.delete_outline_rounded,
              user?.deletionRequestedAt != null ? l.profileDeleteCancel : l.profileDelete,
              () => _deletion(context, ref),
              color: context.scheme.error,
            ),
            if (user?.deletionRequestedAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.gutter),
                child: Text(l.profileDeletePending, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
              ),
          ],
          Padding(
            padding: const EdgeInsets.all(Sp.x6),
            child: Center(child: Text(l.appVersion(appVersionLabel), style: context.text.bodySmall)),
          ),
        ],
      ),
    );
  }

  String _initials(String? name, String phone) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return phone.length >= 2 ? phone.substring(phone.length - 2) : '?';
    final parts = n.split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
  }

  String _langName(String code) => switch (code) {
    'kk' => 'Қазақша',
    'en' => 'English',
    _ => 'Русский',
  };

  Future<void> _languageSheet(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Sp.x4),
              child: Text(l.languageTitle, style: context.text.titleMedium),
            ),
            RadioGroup<String>(
              groupValue: ref.read(localeProvider).languageCode,
              onChanged: (v) {
                final loc = supportedLocales.firstWhere((x) => x.languageCode == v, orElse: () => const Locale('ru'));
                ref.read(localeProvider.notifier).set(loc);
                Navigator.pop(ctx);
              },
              child: Column(
                children: [
                  for (final loc in supportedLocales)
                    RadioListTile<String>(value: loc.languageCode, title: Text(_langName(loc.languageCode))),
                ],
              ),
            ),
            const SizedBox(height: Sp.x2),
          ],
        ),
      ),
    );
  }

  Future<void> _themeSheet(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Sp.x4),
              child: Text(l.themeTitle, style: context.text.titleMedium),
            ),
            RadioGroup<ThemeMode>(
              groupValue: ref.read(themeModeProvider),
              onChanged: (m) {
                if (m != null) ref.read(themeModeProvider.notifier).set(m);
                Navigator.pop(ctx);
              },
              child: Column(
                children: [
                  for (final (mode, label) in [
                    (ThemeMode.light, l.themeLight),
                    (ThemeMode.dark, l.themeDark),
                    (ThemeMode.system, l.themeSystem),
                  ])
                    RadioListTile<ThemeMode>(value: mode, title: Text(label)),
                ],
              ),
            ),
            const SizedBox(height: Sp.x2),
          ],
        ),
      ),
    );
  }

  Future<void> _deletion(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final user = ref.read(authProvider).user;
    final cancelling = user?.deletionRequestedAt != null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(cancelling ? l.profileDeleteCancel : l.profileDelete),
        content: cancelling ? null : Text(l.profileDeleteBody),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(l.cancel)),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44), backgroundColor: cancelling ? null : context.scheme.error),
            child: Text(cancelling ? l.confirm : l.profileDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final repo = ref.read(userRepositoryProvider);
      final updated = cancelling ? await repo.cancelDeletion() : await repo.requestDeletion();
      ref.read(authProvider.notifier).updateUser(updated);
      if (context.mounted && !cancelling) showSnack(context, l.profileDeleteRequested);
    } on ApiFailure catch (e) {
      if (context.mounted) showSnack(context, errorText(l, e));
    }
  }
}
