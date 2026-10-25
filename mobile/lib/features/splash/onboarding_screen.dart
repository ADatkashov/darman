import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../design/logo.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/core_providers.dart';
import 'splash_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _icons = [Icons.search_rounded, Icons.compare_arrows_rounded, Icons.description_outlined, Icons.local_shipping_outlined];

  Future<void> _finish() async {
    await ref.read(sharedPrefsProvider).setBool(onboardingDoneKey, true);
    if (mounted) context.go(Routes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.onb1Title, l.onb2Title, l.onb3Title, l.onb4Title];
    final bodies = [l.onb1Body, l.onb2Body, l.onb3Body, l.onb4Body];
    final last = _page == titles.length - 1;
    return Scaffold(
      backgroundColor: context.dm.paleAqua,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: BotanicalDecor(size: 240)),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.x2, 0),
                  child: Row(
                    children: [
                      const DarmanLogo(height: 32),
                      const Spacer(),
                      _LanguageMenu(),
                      TextButton(onPressed: _finish, child: Text(l.skip)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: titles.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sp.x8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 168,
                            height: 168,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: DmPalette.emerald.withValues(alpha: 0.12), blurRadius: 32, offset: const Offset(0, 12)),
                              ],
                            ),
                            child: Icon(_icons[i], size: 76, color: context.scheme.primary),
                          ),
                          const SizedBox(height: Sp.x10),
                          Text(titles[i], style: context.text.headlineMedium, textAlign: TextAlign.center),
                          const SizedBox(height: Sp.x3),
                          Text(
                            bodies[i],
                            style: context.text.bodyLarge?.copyWith(color: context.dm.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < titles.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? context.scheme.primary : context.dm.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(Sp.x6),
                  child: FilledButton(
                    onPressed: last
                        ? _finish
                        : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                    child: Text(last ? l.getStarted : l.next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    return PopupMenuButton<Locale>(
      tooltip: context.l10n.languageTitle,
      icon: const Icon(Icons.language_rounded),
      initialValue: current,
      onSelected: (l) => ref.read(localeProvider.notifier).set(l),
      itemBuilder: (_) => [
        for (final l in supportedLocales)
          PopupMenuItem(
            value: l,
            child: Text(switch (l.languageCode) {
              'kk' => 'Қазақша',
              'en' => 'English',
              _ => 'Русский',
            }),
          ),
      ],
    );
  }
}
