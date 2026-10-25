import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_models.dart';
import '../../data/repositories/user_repository.dart';
import '../../design/form_fields.dart';
import '../../l10n/l10n_ext.dart';
import '../../state/core_providers.dart';

class AddressEditScreen extends ConsumerStatefulWidget {
  const AddressEditScreen({super.key, this.address});
  final Address? address;
  @override
  ConsumerState<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends ConsumerState<AddressEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.address?.label ?? '');
  late final _city = TextEditingController(text: widget.address?.city ?? 'Алматы');
  late final _street = TextEditingController(text: widget.address?.street ?? '');
  late final _house = TextEditingController(text: widget.address?.house ?? '');
  late final _apartment = TextEditingController(text: widget.address?.apartment ?? '');
  late final _entrance = TextEditingController(text: widget.address?.entrance ?? '');
  late final _floor = TextEditingController(text: widget.address?.floor ?? '');
  late final _comment = TextEditingController(text: widget.address?.comment ?? '');
  late bool _default = widget.address?.defaultAddress ?? false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_label, _city, _street, _house, _apartment, _entrance, _floor, _comment]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final input = AddressInput(
      label: _label.text.trim(),
      city: _city.text.trim(),
      street: _street.text.trim(),
      house: _house.text.trim(),
      apartment: _apartment.text.trim(),
      entrance: _entrance.text.trim(),
      floor: _floor.text.trim(),
      comment: _comment.text.trim(),
      makeDefault: _default,
    );
    try {
      final repo = ref.read(userRepositoryProvider);
      if (widget.address == null) {
        await repo.createAddress(input);
      } else {
        await repo.updateAddress(widget.address!.id, input);
      }
      if (mounted) context.pop();
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _req(String? v) => fieldErrorText(context.l10n, Validators.required(v));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget f(TextEditingController c, String label, {String? Function(String?)? validator, TextInputType? type}) => Padding(
      padding: const EdgeInsets.only(bottom: Sp.x3),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.address == null ? l.addressAdd : l.addressEdit)),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, MediaQuery.viewInsetsOf(context).bottom + Sp.x8),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Sp.x3),
                child: InlineError(_error!),
              ),
            f(_label, l.addressLabel),
            f(_city, l.addressCity, validator: _req),
            f(_street, l.addressStreet, validator: _req),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: f(_house, l.addressHouse, validator: _req)),
                const SizedBox(width: Sp.x3),
                Expanded(child: f(_apartment, l.addressApartment)),
              ],
            ),
            Row(
              children: [
                Expanded(child: f(_entrance, l.addressEntrance)),
                const SizedBox(width: Sp.x3),
                Expanded(child: f(_floor, l.addressFloor)),
              ],
            ),
            f(_comment, l.addressComment),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.addressDefault),
              value: _default,
              onChanged: (v) => setState(() => _default = v),
            ),
            const SizedBox(height: Sp.x4),
            FilledButton(onPressed: _busy ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
