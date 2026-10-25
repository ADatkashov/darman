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
import '../../state/core_providers.dart';
import 'auth_scaffold.dart';
import 'otp_screen.dart';
import '../../core/theme/colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.from});
  final String? from;
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController(text: '+7 ');
  final _password = TextEditingController();
  bool _consent = false;
  bool _consentError = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    setState(() => _consentError = !_consent);
    if (!valid || !_consent || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = context.l10n;
    final phone = Validators.normalizePhone(_phone.text)!;
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .register(
            phone: phone,
            password: _password.text,
            fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
            locale: ref.read(localeProvider).languageCode,
          );
      if (!mounted) return;
      context.push(
        '${Routes.otp}${widget.from != null ? '?from=${Uri.encodeComponent(widget.from!)}' : ''}',
        extra: OtpArgs(phone: phone, devOtp: challenge.devOtp),
      );
    } on ApiFailure catch (e) {
      setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.registerTitle,
      subtitle: l.registerSubtitle,
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[InlineError(_error!), const SizedBox(height: Sp.x4)],
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: '${l.authFullName} (${l.optional})',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: Sp.x4),
              PhoneField(controller: _phone),
              const SizedBox(height: Sp.x4),
              PasswordField(controller: _password, helper: l.authPasswordHint, newPassword: true, onSubmitted: _submit),
              const SizedBox(height: Sp.x4),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _consent,
                onChanged: (v) => setState(() {
                  _consent = v ?? false;
                  _consentError = false;
                }),
                title: Text(l.authConsent, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurface)),
                subtitle: _consentError ? Text(l.authConsentRequired, style: TextStyle(color: context.scheme.error, fontSize: 12)) : null,
              ),
              TextButton(onPressed: () => context.push(Routes.legal('privacy')), child: Text(l.profilePrivacy)),
              const SizedBox(height: Sp.x2),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(l.authRegisterAction),
              ),
              const SizedBox(height: Sp.x3),
              TextButton(
                onPressed: () =>
                    context.pushReplacement('${Routes.login}${widget.from != null ? '?from=${Uri.encodeComponent(widget.from!)}' : ''}'),
                child: Text(l.authHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
