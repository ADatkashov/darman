import 'package:darman/app.dart';
import 'package:darman/core/utils/validators.dart';
import 'package:darman/data/models/user_models.dart';
import 'package:darman/design/form_fields.dart';
import 'package:darman/features/auth/login_screen.dart';
import 'package:darman/l10n/app_localizations.dart';
import 'package:darman/state/auth_state.dart';
import 'package:darman/state/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> pumpApp(WidgetTester t, {Map<String, Object> prefs = const {}}) async {
  final overrides = await testOverrides(prefs: prefs);
  await t.pumpWidget(ProviderScope(overrides: overrides, retry: (_, _) => null, child: const DarmanApp()));
  await t.pump(const Duration(milliseconds: 1500));
  await t.pump(const Duration(milliseconds: 500));
}

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('boots to home with five navigation destinations (Russian default)', (t) async {
    await pumpApp(t);
    for (final label in ['Главная', 'Поиск', 'Корзина', 'Заказы', 'Профиль']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Поиск лекарств и товаров'), findsOneWidget);
    expect(find.text('Забота о здоровье каждый день'), findsOneWidget);
  });

  testWidgets('navigation: tabs switch and guests see a sign-in prompt for orders', (t) async {
    await pumpApp(t);
    await t.tap(find.text('Заказы').last);
    await t.pumpAndSettle();
    expect(find.text('Войдите, чтобы видеть заказы'), findsOneWidget);
    await t.tap(find.text('Корзина').last);
    await t.pumpAndSettle();
    expect(find.text('В корзине пока пусто'), findsOneWidget);
  });

  testWidgets('locale persists and switches labels (kk, en)', (t) async {
    await pumpApp(t, prefs: {'pref.locale': 'kk'});
    expect(find.text('Басты бет'), findsWidgets);
    expect(find.text('Себет'), findsWidgets);
  });

  testWidgets('English locale shows English navigation', (t) async {
    await pumpApp(t, prefs: {'pref.locale': 'en'});
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
  });

  testWidgets('cart badge reflects item count and the cart screen lists the line', (t) async {
    await pumpApp(t);
    final container = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    container.read(cartProvider.notifier).add(sampleLine(qty: 2));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('2'), findsWidgets); // badge
    await t.tap(find.text('Корзина').last);
    await t.pumpAndSettle();
    expect(find.text('ПараДем'), findsOneWidget);
    expect(find.text('Оформить заказ'), findsOneWidget);
  });

  testWidgets('checkout from the cart sends guests to login', (t) async {
    await pumpApp(t);
    final container = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    container.read(cartProvider.notifier).add(sampleLine());
    await t.tap(find.text('Корзина').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Оформить заказ'));
    await t.pumpAndSettle();
    expect(find.text('Вход'), findsWidgets);
  });

  testWidgets('login form validates phone and shows localized errors', (t) async {
    final overrides = await testOverrides();
    await t.pumpWidget(
      ProviderScope(
        overrides: overrides,
        retry: (_, _) => null,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: [AppL10n.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          home: LoginScreen(),
        ),
      ),
    );
    await t.tap(find.text('Sign in').last);
    await t.pump();
    expect(find.text('Enter a number like +7 XXX XXX XX XX'), findsOneWidget);
  });

  testWidgets('field error mapping covers every kind in all locales', (t) async {
    for (final loc in AppL10n.supportedLocales) {
      final l = await AppL10n.delegate.load(loc);
      for (final e in [null, ...FieldError.values]) {
        final text = fieldErrorText(l, e);
        if (e != null) expect(text, isNotEmpty);
      }
    }
  });

  testWidgets('session-expired state is surfaced for the user', (t) async {
    await pumpApp(t);
    final container = ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
    container
        .read(authProvider.notifier)
        .signedIn(
          const AuthTokens(
            access: 'a',
            refresh: 'r',
            user: UserProfile(
              id: 'u',
              phone: '+77011234567',
              locale: 'ru',
              notifyOrders: true,
              notifyPromotions: false,
              notifyPrescriptions: true,
              role: 'CUSTOMER',
            ),
          ),
        );
    await t.pump();
    container.read(authProvider.notifier).sessionExpired();
    await t.pump();
    expect(container.read(authProvider).sessionExpired, isTrue);
  });
}
