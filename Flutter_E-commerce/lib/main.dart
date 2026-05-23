import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'views/screens/login_screen.dart';
import 'views/screens/signup_screen.dart';
import 'views/screens/wrapper_screen.dart';
import 'views/screens/product_details_screen.dart';
import 'views/screens/cart_screen.dart';
import 'Models/CartItem.dart';
import 'Models/product_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // setup go_router
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/wrapper',
        builder: (context, state) => const WrapperScreen(),
      ),
      GoRoute(
        path: '/product-details/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final product = ProductModel.getProducts()
              .firstWhere((p) => p.id == productId);
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopSmart',
      routerConfig: _router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
