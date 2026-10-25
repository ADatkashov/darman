import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/user_models.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/checkout/order_done_screen.dart';
import '../features/home/home_screen.dart';
import '../features/legal/legal_screens.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/pharmacies/pharmacies_screen.dart';
import '../features/prescriptions/prescription_detail_screen.dart';
import '../features/prescriptions/prescription_new_screen.dart';
import '../features/prescriptions/prescriptions_screen.dart';
import '../features/product/product_screen.dart';
import '../features/profile/address_edit_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/profile/favorites_screen.dart';
import '../features/profile/notifications_screen.dart';
import '../features/profile/profile_edit_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/splash/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';
import '../state/auth_state.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const home = '/home';
  static const search = '/search';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';
  static const checkout = '/checkout';
  static const prescriptions = '/prescriptions';
  static const prescriptionNew = '/prescription/new';
  static const addresses = '/addresses';
  static const addressEdit = '/address/edit';
  static const favorites = '/favorites';
  static const notifications = '/notifications';
  static const profileEdit = '/profile/edit';
  static const pharmacies = '/pharmacies';
  static const help = '/help';
  static String product(String id) => '/product/$id';
  static String order(String id) => '/order/$id';
  static String orderDone(String id) => '/order-done/$id';
  static String prescription(String id) => '/prescription/$id';
  static String legal(String kind) => '/legal/$kind';
  static String searchCategory(String slug) => '$search?category=$slug';

  /// Routes that need a signed-in user. Guests are redirected to login and returned here afterwards.
  static const protectedPrefixes = [
    checkout,
    prescriptions,
    prescriptionNew,
    '/prescription/',
    addresses,
    addressEdit,
    notifications,
    profileEdit,
    '/order/',
    '/order-done/',
  ];
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Bridges Riverpod auth state to go_router's refreshListenable.
class _AuthListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable();
  ref.listen<AuthState>(authProvider, (_, _) => listenable.ping());
  ref.onDispose(listenable.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      if (!auth.isResolved) return loc == Routes.splash ? null : Routes.splash;
      if (auth.isAuthenticated && (loc == Routes.login || loc == Routes.register || loc == Routes.otp)) return Routes.home;
      final needsAuth = Routes.protectedPrefixes.any((p) => p.endsWith('/') ? loc.startsWith(p) : loc == p);
      if (!auth.isAuthenticated && needsAuth) {
        return '${Routes.login}?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: Routes.login,
        builder: (_, s) => LoginScreen(from: s.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, s) => RegisterScreen(from: s.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (_, s) {
          final extra = s.extra as OtpArgs?;
          return OtpScreen(
            args: extra ?? const OtpArgs(phone: ''),
            from: s.uri.queryParameters['from'],
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (_, s) => SearchScreen(
                  initialCategory: s.uri.queryParameters['category'],
                  initialQuery: s.uri.queryParameters['q'],
                  onSale: s.uri.queryParameters['sale'] == '1',
                  key: ValueKey('search-${s.uri.query}'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.cart, builder: (_, _) => const CartScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.orders, builder: (_, _) => const OrdersScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => ProductScreen(productId: s.pathParameters['id']!),
      ),
      GoRoute(path: Routes.checkout, parentNavigatorKey: _rootKey, builder: (_, _) => const CheckoutScreen()),
      GoRoute(
        path: '/order/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/order-done/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => OrderDoneScreen(orderId: s.pathParameters['id']!),
      ),
      GoRoute(path: Routes.prescriptions, parentNavigatorKey: _rootKey, builder: (_, _) => const PrescriptionsScreen()),
      GoRoute(path: Routes.prescriptionNew, parentNavigatorKey: _rootKey, builder: (_, _) => const PrescriptionNewScreen()),
      GoRoute(
        path: '/prescription/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => PrescriptionDetailScreen(prescriptionId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.addresses,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => AddressesScreen(selectMode: s.uri.queryParameters['select'] == '1'),
      ),
      GoRoute(
        path: Routes.addressEdit,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => AddressEditScreen(address: s.extra as Address?),
      ),
      GoRoute(path: Routes.favorites, parentNavigatorKey: _rootKey, builder: (_, _) => const FavoritesScreen()),
      GoRoute(path: Routes.notifications, parentNavigatorKey: _rootKey, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: Routes.profileEdit, parentNavigatorKey: _rootKey, builder: (_, _) => const ProfileEditScreen()),
      GoRoute(path: Routes.pharmacies, parentNavigatorKey: _rootKey, builder: (_, _) => const PharmaciesScreen()),
      GoRoute(
        path: '/legal/:kind',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => LegalScreen(kind: s.pathParameters['kind']!),
      ),
      GoRoute(path: Routes.help, parentNavigatorKey: _rootKey, builder: (_, _) => const HelpScreen()),
    ],
  );
});
