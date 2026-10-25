import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/validators.dart';
import '../core/theme/colors.dart';
import '../l10n/l10n_ext.dart';

String? fieldErrorText(AppL10n l, FieldError? e) => switch (e) {
  null => null,
  FieldError.required => l.required,
  FieldError.phone => l.errPhoneInvalid,
  FieldError.password => l.errWeakPassword,
  FieldError.email => l.profileEmailInvalid,
  FieldError.otp => l.errOtpInvalid,
};

class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final bool autofocus;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')), LengthLimitingTextInputFormatter(20)],
      decoration: InputDecoration(labelText: l.authPhone, hintText: '+7 7XX XXX XX XX', prefixIcon: const Icon(Icons.phone_outlined)),
      validator: (v) => fieldErrorText(l, Validators.phone(v)),
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.helper,
    this.validate = true,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.newPassword = false,
  });
  final TextEditingController controller;
  final String? label;
  final String? helper;
  final bool validate;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool newPassword;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      autofillHints: [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label ?? l.authPassword,
        helperText: widget.helper,
        helperMaxLines: 2,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _hidden ? l.passwordShow : l.passwordHide,
          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
      validator: (v) => widget.validate ? fieldErrorText(l, Validators.password(v)) : fieldErrorText(l, Validators.required(v)),
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    );
  }
}

class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: context.scheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: context.scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
          ),
        ],
      ),
    ),
  );
}
