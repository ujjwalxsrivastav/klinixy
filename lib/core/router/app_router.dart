import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:klinixy/features/auth/presentation/screens/login_screen.dart';
import 'package:klinixy/features/auth/presentation/screens/splash_screen.dart';
import 'package:klinixy/features/cart/presentation/screens/cart_screen.dart';
import 'package:klinixy/features/home/presentation/screens/home_screen.dart';
import 'package:klinixy/features/orders/presentation/screens/checkout_screen.dart';
import 'package:klinixy/features/orders/presentation/screens/order_history_screen.dart';
import 'package:klinixy/features/orders/presentation/screens/order_success_screen.dart';
import 'package:klinixy/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:klinixy/features/product/presentation/screens/product_detail_screen.dart';
import 'package:klinixy/features/profile/presentation/screens/address_management_screen.dart';
import 'package:klinixy/features/search/presentation/screens/search_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final authState = authBloc.state;
        final isOnSplash = state.matchedLocation == '/splash';
        final isOnLogin = state.matchedLocation == '/login';

        if (isOnSplash) return null;

        if (authState is AuthUnauthenticated && !isOnLogin) return '/login';
        if (authState is AuthAuthenticated && isOnLogin) return '/home';

        return null;
      },
      refreshListenable: _BlocListenable(authBloc),
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (_, state) => SearchScreen(
            initialQuery: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product',
          builder: (_, state) => ProductDetailScreen(
            productId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (_, __) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (_, __) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/order/:id/success',
          name: 'orderSuccess',
          builder: (_, state) => OrderSuccessScreen(
            orderId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/order/:id/track',
          name: 'orderTrack',
          builder: (_, state) => OrderTrackingScreen(
            orderId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (_, __) => const OrderHistoryScreen(),
        ),
        GoRoute(
          path: '/profile/addresses',
          name: 'addresses',
          builder: (_, __) => const AddressManagementScreen(),
        ),
      ],
    );
  }
}

class _BlocListenable extends ChangeNotifier {
  _BlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
