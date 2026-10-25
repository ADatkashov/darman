import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../design/logo.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';

const onboardingDoneKey = 'onboarding.done';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 1100));
    await Future.wait([ref.read(authProvider.notifier).restore(), minDelay]);
    if (!mounted) return;
    final done = ref.read(sharedPrefsProvider).getBool(onboardingDoneKey) ?? false;
    context.go(done ? Routes.home : Routes.onboarding);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return Scaffold(
      backgroundColor: context.dm.paleAqua,
      body: Stack(
        children: [
          const Positioned.fill(child: BotanicalDecor(size: 260, opacity: 0.18)),
          const Positioned.fill(child: BotanicalDecor(size: 200, alignment: Alignment.bottomLeft, opacity: 0.12)),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(fade),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DarmanSymbol(size: 96),
                    const SizedBox(height: 20),
                    Text('DARMAN', style: context.text.displaySmall?.copyWith(color: DmPalette.deepGreen, letterSpacing: 6)),
                    const SizedBox(height: 8),
                    Text(
                      l.slogan,
                      style: context.text.titleMedium?.copyWith(color: context.dm.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3))),
          ),
        ],
      ),
    );
  }
}
