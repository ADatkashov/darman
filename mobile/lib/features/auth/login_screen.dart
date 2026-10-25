import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../design/form_fields.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import 'auth_scaffold.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.from});
  final String? from;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController(text: '+7 ');
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = context.l10n;
    final phone = Validators.normalizePhone(_phone.text)!;
    try {
      final tokens = await ref.read(authRepositoryProvider).login(phone, _password.text);
      await ref.read(authProvider.notifier).signedIn(tokens);
      if (!mounted) return;
      context.go(widget.from != null && widget.from!.isNotEmpty ? Uri.decodeComponent(widget.from!) : Routes.home);
    } on ApiFailure catch (e) {
      if (e.code == 'PHONE_NOT_VERIFIED') {
        try {
          final challenge = await ref.read(authRepositoryProvider).resendOtp(phone);
          if (!mounted) return;
          context.push(
            '${Routes.otp}${widget.from != null ? '?from=${Uri.encodeComponent(widget.from!)}' : ''}',
            extra: OtpArgs(phone: phone, devOtp: challenge.devOtp),
          );
          return;
        } on ApiFailure catch (e2) {
          setState(() => _error = errorText(l, e2));
        }
      } else {
        setState(() => _error = errorText(l, e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.loginTitle,
      subtitle: l.loginSubtitle,
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[InlineError(_error!), const SizedBox(height: Sp.x4)],
              PhoneField(controller: _phone),
              const SizedBox(height: Sp.x4),
              PasswordField(controller: _password, validate: false, onSubmitted: _submit),
              const SizedBox(height: Sp.x6),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(l.authLoginAction),
              ),
              const SizedBox(height: Sp.x3),
              TextButton(
                onPressed: () =>
                    context.pushReplacement('${Routes.register}${widget.from != null ? '?from=${Uri.encodeComponent(widget.from!)}' : ''}'),
                child: Text(l.authNoAccount),
              ),
              TextButton(onPressed: () => context.go(Routes.home), child: Text(l.authContinueGuest)),
            ],
          ),
        ),
      ),
    );
  }
}
