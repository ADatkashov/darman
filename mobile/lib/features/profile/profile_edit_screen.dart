import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../design/form_fields.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/auth_state.dart';
import '../../state/core_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(authProvider).user?.fullName ?? '');
  late final _email = TextEditingController(text: ref.read(authProvider).user?.email ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      final u = await ref.read(userRepositoryProvider).update(fullName: _name.text.trim(), email: _email.text.trim());
      ref.read(authProvider.notifier).updateUser(u);
      if (mounted) showSnack(context, l.profileSaved);
    } on ApiFailure catch (e) {
      if (mounted) showSnack(context, errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: Text(l.profileEdit)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Sp.gutter),
          children: [
            TextFormField(
              initialValue: user == null ? '' : Validators.prettyPhone(user.phone),
              enabled: false,
              decoration: InputDecoration(labelText: l.authPhone, prefixIcon: const Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: Sp.x4),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l.profileFullName, prefixIcon: const Icon(Icons.person_outline_rounded)),
            ),
            const SizedBox(height: Sp.x4),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l.profileEmail, prefixIcon: const Icon(Icons.mail_outline_rounded)),
              validator: (v) => fieldErrorText(l, Validators.optionalEmail(v)),
            ),
            const SizedBox(height: Sp.x6),
            FilledButton(onPressed: _busy ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
