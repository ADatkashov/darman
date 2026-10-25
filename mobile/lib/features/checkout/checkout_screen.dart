import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/order_models.dart';
import '../../data/models/prescription_models.dart';
import '../../data/repositories/order_repository.dart';
import '../../design/form_fields.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/auth_state.dart';
import '../../state/cart_state.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import '../cart/checkout_math.dart';
import '../cart/quote_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _notes = TextEditingController();

  bool? _pickup; // null until terms are known
  String? _addressId;
  DeliverySlot? _slot;
  bool _card = false;
  String? _prescriptionId;
  bool _consent = false;
  bool _showErrors = false;
  bool _busy = false;
  String? _error;

  // Idempotency: the same key is reused for retries of an identical payload so a retry can never create a second order.
  String? _lastPayload;
  String? _key;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user == null ? '+7 ' : Validators.prettyPhone(user.phone));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _newKey() {
    final r = Random.secure();
    return List.generate(24, (_) => r.nextInt(36).toRadixString(36)).join();
  }

  Future<void> _place(Quote quote, DeliveryTerms? terms, bool pickup, Totals totals, bool needsRx) async {
    final l = context.l10n;
    setState(() => _showErrors = true);
    if (!_form.currentState!.validate()) return;
    if (!pickup && _addressId == null) {
      setState(() => _error = l.errAddressRequired);
      return;
    }
    if (needsRx && _prescriptionId == null) {
      setState(() => _error = l.errPrescriptionRequired);
      return;
    }
    if (!_consent) return;
    final cart = ref.read(cartProvider);
    final input = PlaceOrderInput(
      lines: cart.lines,
      pickup: pickup,
      addressId: _addressId,
      contactName: _name.text.trim(),
      contactPhone: Validators.normalizePhone(_phone.text)!,
      notes: _notes.text,
      slotStart: _slot?.start,
      cardPayment: _card,
      promoCode: quote.promoApplied ? quote.promoCode : null,
      prescriptionId: needsRx ? _prescriptionId : null,
      expectedTotal: totals.total,
    );
    final payload = input.toJson().toString();
    if (payload != _lastPayload || _key == null) {
      _lastPayload = payload;
      _key = _newKey();
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await ref.read(orderRepositoryProvider).place(input, _key!);
      ref.read(cartProvider.notifier).clear();
      ref.read(promoCodeProvider.notifier).set(null);
      ref.invalidate(ordersProvider);
      ref.invalidate(prescriptionsProvider);
      if (!mounted) return;
      context.go(Routes.orderDone(order.id));
    } on ApiFailure catch (e) {
      if (!mounted) return;
      if (e.code == 'PRICE_CHANGED' || e.code == 'OFFER_UNAVAILABLE' || e.code == 'INSUFFICIENT_STOCK') {
        ref.invalidate(quoteProvider);
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.coPriceChangedTitle),
            content: Text(e.code == 'PRICE_CHANGED' ? l.coPriceChangedBody : errorText(l, e)),
            actions: [
              FilledButton(
                onPressed: () => ctx.pop(),
                style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
                child: Text(l.ok),
              ),
            ],
          ),
        );
        if (mounted) context.pop(); // back to the cart to review
        return;
      }
      setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeCode;
    final cart = ref.watch(cartProvider);
    final quoteAsync = ref.watch(quoteProvider);
    final config = ref.watch(runtimeConfigProvider).value;
    final addresses = ref.watch(addressesProvider);
    final prescriptions = ref.watch(prescriptionsProvider);

    if (cart.isEmpty && !_busy) {
      return Scaffold(
        appBar: AppBar(title: Text(l.checkoutTitle)),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: l.cartEmptyTitle,
          actionLabel: l.goToCatalog,
          onAction: () => context.go(Routes.home),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.checkoutTitle)),
      body: quoteAsync.when(
        loading: () => const ListSkeleton(count: 4),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(quoteProvider)),
        data: (quote) {
          final terms = quote.validation.delivery;
          if (quote.validation.checkoutBlocked) {
            return EmptyState(
              icon: Icons.warning_amber_rounded,
              title: l.cartFixIssues,
              actionLabel: l.back,
              onAction: () => context.pop(),
            );
          }
          final canDeliver = terms?.deliveryAvailable ?? false;
          final pickup = _pickup ?? !canDeliver;
          final totals = computeTotals(subtotal: quote.subtotal, discount: quote.discount, pickup: pickup, terms: terms);
          final needsRx = quote.validation.prescriptionRequired || cart.hasRx;
          final cardAllowed = config?.onlinePaymentAvailable ?? false;
          final usableRx = (prescriptions.value ?? const <Prescription>[]).where((p) => p.usableForOrder).toList();
          if (needsRx && _prescriptionId == null && usableRx.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _prescriptionId == null) setState(() => _prescriptionId = usableRx.first.id);
            });
          }
          final branchId = cart.branchId;

          return Form(
            key: _form,
            autovalidateMode: _showErrors ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, Sp.x8),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x4),
                    child: InlineError(_error!),
                  ),
                _Section(
                  title: l.coContact,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(labelText: l.coName, prefixIcon: const Icon(Icons.person_outline_rounded)),
                        validator: (v) => fieldErrorText(l, Validators.required(v)),
                      ),
                      const SizedBox(height: Sp.x3),
                      PhoneField(controller: _phone),
                    ],
                  ),
                ),
                _Section(
                  title: l.coFulfillment,
                  child: Column(
                    children: [
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        segments: [
                          ButtonSegment(
                            value: false,
                            enabled: canDeliver,
                            icon: const Icon(Icons.local_shipping_outlined),
                            label: Text(l.coDelivery),
                          ),
                          ButtonSegment(value: true, icon: const Icon(Icons.storefront_outlined), label: Text(l.coPickup)),
                        ],
                        selected: {pickup},
                        onSelectionChanged: (s) => setState(() {
                          _pickup = s.first;
                          _error = null;
                        }),
                      ),
                      if (!canDeliver)
                        Padding(
                          padding: const EdgeInsets.only(top: Sp.x3),
                          child: InfoPanel(icon: Icons.info_outline, text: l.cartDeliveryUnavailable),
                        ),
                      if (pickup)
                        Padding(
                          padding: const EdgeInsets.only(top: Sp.x3),
                          child: InfoPanel(icon: Icons.storefront_outlined, text: l.coPickupFrom(cart.pharmacyLabel ?? '')),
                        ),
                    ],
                  ),
                ),
                if (!pickup) ...[
                  _Section(
                    title: l.coAddress,
                    child: addresses.when(
                      loading: () => const Skeleton(height: 72, radius: 16),
                      error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(addressesProvider)),
                      data: (list) {
                        final selectedId = _addressId ?? (list.where((a) => a.defaultAddress).firstOrNull ?? list.firstOrNull)?.id;
                        if (_addressId == null && selectedId != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _addressId == null) setState(() => _addressId = selectedId);
                          });
                        }
                        return Column(
                          children: [
                            for (final a in list)
                              Padding(
                                padding: const EdgeInsets.only(bottom: Sp.x2),
                                child: _ChoiceTile(
                                  selected: a.id == selectedId,
                                  title: a.label ?? a.street,
                                  subtitle: a.formatted,
                                  icon: Icons.location_on_outlined,
                                  onTap: () => setState(() => _addressId = a.id),
                                ),
                              ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await context.push(Routes.addressEdit);
                                ref.invalidate(addressesProvider);
                              },
                              icon: const Icon(Icons.add_location_alt_outlined),
                              label: Text(list.isEmpty ? l.coAddAddress : l.addressAdd),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (branchId != null)
                    _Section(
                      title: l.coSlot,
                      child: ref
                          .watch(slotsProvider(branchId))
                          .when(
                            loading: () => const Skeleton(height: 56, radius: 16),
                            error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(slotsProvider(branchId))),
                            data: (info) => Column(
                              children: [
                                _ChoiceTile(
                                  selected: _slot == null,
                                  title: info.etaMin != null && info.etaMax != null ? l.coAsap(info.etaMin!, info.etaMax!) : l.coDelivery,
                                  icon: Icons.bolt_outlined,
                                  onTap: () => setState(() => _slot = null),
                                ),
                                for (final s in info.slots.take(8))
                                  Padding(
                                    padding: const EdgeInsets.only(top: Sp.x2),
                                    child: _ChoiceTile(
                                      selected: _slot?.start == s.start,
                                      title: '${_dayLabel(context, s.start)}, ${formatTime(s.start, loc)}–${formatTime(s.end, loc)}',
                                      icon: Icons.schedule_outlined,
                                      onTap: () => setState(() => _slot = s),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ),
                  _Section(
                    title: l.coNotes,
                    child: TextFormField(
                      controller: _notes,
                      maxLength: 300,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(hintText: l.optional),
                    ),
                  ),
                ],
                if (needsRx)
                  _Section(
                    title: l.coRxSection,
                    child: prescriptions.when(
                      loading: () => const Skeleton(height: 56, radius: 16),
                      error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(prescriptionsProvider)),
                      data: (_) => usableRx.isEmpty
                          ? Column(
                              children: [
                                InfoPanel(
                                  icon: Icons.description_outlined,
                                  text: l.coRxNone,
                                  tint: DmPalette.warning.withValues(alpha: 0.14),
                                ),
                                const SizedBox(height: Sp.x3),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    await context.push(Routes.prescriptionNew);
                                    ref.invalidate(prescriptionsProvider);
                                  },
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: Text(l.coRxUpload),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                for (final p in usableRx)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: Sp.x2),
                                    child: _ChoiceTile(
                                      selected: _prescriptionId == p.id,
                                      title: l.coRxLine(formatDate(p.createdAt, loc)),
                                      subtitle: p.expiresAt == null ? null : l.rxValidUntil(formatDate(p.expiresAt!, loc)),
                                      icon: Icons.description_outlined,
                                      onTap: () => setState(() => _prescriptionId = p.id),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                _Section(
                  title: l.coPayment,
                  child: Column(
                    children: [
                      _ChoiceTile(
                        selected: !_card,
                        title: l.coPayCash,
                        icon: Icons.payments_outlined,
                        onTap: () => setState(() => _card = false),
                      ),
                      const SizedBox(height: Sp.x2),
                      _ChoiceTile(
                        selected: _card && cardAllowed,
                        title: !cardAllowed
                            ? l.coPayCardUnavailable
                            : (config?.onlinePaymentIsDemo ?? false)
                            ? l.coPayCardDemo
                            : l.coPayCard,
                        icon: Icons.credit_card_outlined,
                        enabled: cardAllowed,
                        onTap: () => setState(() => _card = true),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: l.coSummary,
                  child: DmCard(
                    child: Column(
                      children: [
                        for (final line in cart.lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Sp.x2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text('${line.name} × ${line.quantity}', style: context.text.bodyMedium)),
                                Text(
                                  formatMoney(
                                    quote.validation.lineFor(line.offerId)?.unitPrice == null
                                        ? line.lineTotal
                                        : quote.validation.lineFor(line.offerId)!.unitPrice * line.quantity,
                                    loc,
                                  ),
                                  style: context.text.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                        const SizedBox(height: Sp.x2),
                        _Row(l.cartSubtotal, formatMoney(totals.subtotal, loc)),
                        if (totals.discount > 0) _Row(l.cartDiscount, '−${formatMoney(totals.discount, loc)}', color: context.dm.success),
                        _Row(l.cartDelivery, totals.deliveryFee == 0 ? l.free : formatMoney(totals.deliveryFee, loc)),
                        const SizedBox(height: Sp.x2),
                        Row(
                          children: [
                            Expanded(child: Text(l.cartTotal, style: context.text.titleMedium)),
                            Text(formatMoney(totals.total, loc), style: context.text.headlineSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (config?.demoMode ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: InfoPanel(icon: Icons.science_outlined, text: l.coDoneDemo, tint: DmPalette.warning.withValues(alpha: 0.14)),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                  title: Text(l.coConsent, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurface)),
                  subtitle: _showErrors && !_consent
                      ? Text(l.coConsentRequired, style: TextStyle(color: context.scheme.error, fontSize: 12))
                      : null,
                ),
                Row(
                  children: [
                    TextButton(onPressed: () => context.push(Routes.legal('privacy')), child: Text(l.profilePrivacy)),
                    TextButton(onPressed: () => context.push(Routes.legal('terms')), child: Text(l.profileTerms)),
                  ],
                ),
                const SizedBox(height: Sp.x2),
                FilledButton(
                  onPressed: _busy ? null : () => _place(quote, terms, pickup, totals, needsRx),
                  child: _busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(l.coPlaceOrder(formatMoney(totals.total, loc))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dayLabel(BuildContext context, DateTime d) {
    final l = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return l.coSlotToday;
    if (day == today.add(const Duration(days: 1))) return l.coSlotTomorrow;
    return formatDate(d, context.localeCode);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Sp.x5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: context.text.titleMedium)),
        const SizedBox(height: Sp.x3),
        child,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary)),
        ),
        Text(
          value,
          style: context.text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });
  final bool selected;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    enabled: enabled,
    child: Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? context.dm.paleAqua : null,
          borderRadius: BorderRadius.circular(Sp.radiusMd),
          border: Border.all(color: selected ? context.scheme.primary : context.dm.cardBorder, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Sp.radiusMd),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.x3 + 2, vertical: Sp.x3),
            child: Row(
              children: [
                Icon(icon, color: context.scheme.primary),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      if (subtitle != null) Text(subtitle!, style: context.text.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? context.scheme.primary : context.dm.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
