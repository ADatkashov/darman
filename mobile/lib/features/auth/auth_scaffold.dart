import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import '../../design/logo.dart';

/// Shared chrome for login / register / OTP: botanical backdrop, logo and a scrollable form area (keyboard safe).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, this.subtitle, required this.child, this.showBack = true});
  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showBack ? AppBar(backgroundColor: Colors.transparent) : null,
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        const Positioned.fill(child: BotanicalDecor(size: 220, opacity: 0.12)),
        SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(Sp.x6, showBack ? Sp.x12 : Sp.x6, Sp.x6, MediaQuery.viewInsetsOf(context).bottom + Sp.x6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DarmanLogo(height: 40),
                const SizedBox(height: Sp.x8),
                Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
                if (subtitle != null) ...[
                  const SizedBox(height: Sp.x2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: Sp.x8),
                child,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
