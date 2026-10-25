import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../design/form_fields.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';
import 'auth_scaffold.dart';
import '../../core/theme/colors.dart';

class OtpArgs {
  const OtpArgs({required this.phone, this.devOtp});
  final String phone;

  /// Only present when the server runs the demo OTP provider; real deployments never return a code.
  final String? devOtp;
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args, this.from});
  final OtpArgs args;
  final String? from;
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  Timer? _timer;
  int _cooldown = 30;
  bool _busy = false;
  String? _error;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _devOtp = widget.args.devOtp;
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _cooldown = _cooldown > 0 ? _cooldown - 1 : 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = context.l10n;
    try {
      final tokens = await ref.read(authRepositoryProvider).verifyOtp(widget.args.phone, _code.text.trim());
      await ref.read(authProvider.notifier).signedIn(tokens);
      if (!mounted) return;
      context.go(widget.from != null && widget.from!.isNotEmpty ? Uri.decodeComponent(widget.from!) : Routes.home);
    } on ApiFailure catch (e) {
      setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final l = context.l10n;
    try {
      final c = await ref.read(authRepositoryProvider).resendOtp(widget.args.phone);
      setState(() {
        _devOtp = c.devOtp;
        _error = null;
      });
      _startCooldown();
    } on ApiFailure catch (e) {
      setState(() => _error = errorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.otpTitle,
      subtitle: l.otpBody(Validators.prettyPhone(widget.args.phone)),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_devOtp != null) ...[
              InfoPanel(icon: Icons.science_outlined, text: l.otpDemoNote(_devOtp!), tint: const Color(0x22E5A23C)),
              const SizedBox(height: Sp.x4),
            ],
            if (_error != null) ...[InlineError(_error!), const SizedBox(height: Sp.x4)],
            TextFormField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: context.text.headlineMedium?.copyWith(letterSpacing: 10),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: InputDecoration(labelText: l.otpCode),
              validator: (v) => fieldErrorText(l, Validators.otp(v)),
              onFieldSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: Sp.x6),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(l.otpVerify),
            ),
            const SizedBox(height: Sp.x3),
            TextButton(onPressed: _cooldown > 0 ? null : _resend, child: Text(_cooldown > 0 ? l.otpResendIn(_cooldown) : l.otpResend)),
          ],
        ),
      ),
    );
  }
}
