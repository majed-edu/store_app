import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/favorites_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/screens/auth/auth_gate.dart';
import 'package:store_app/screens/auth/register_page.dart';
import 'package:store_app/screens/customer/checkout_page.dart';
import 'package:store_app/screens/customer/order_success_page.dart';
import 'package:store_app/screens/customer/orders_page.dart';
import 'package:store_app/screens/customer/product_details_page.dart';
import 'package:store_app/screens/merchant/product_editor_page.dart';
import 'package:store_app/storage/local_store.dart';
import 'package:store_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();
  runApp(StoreApp(store: store));
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key, required this.store});

  final LocalStore store;

  @override
  Widget build(BuildContext context) {
    // Providers sit above MaterialApp so every screen can reach them.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(store)..restore()),
        ChangeNotifierProvider(create: (_) => CatalogProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => OrdersProvider(store)),
        ChangeNotifierProvider(create: (_) => ShellController()),
        // Cart and favorites belong to the logged-in user, so they follow AuthProvider.
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(store),
          update: (_, auth, cart) => cart!..bindUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(store),
          update: (_, auth, favorites) => favorites!..bindUser(auth.user?.id),
        ),
      ],
      child: MaterialApp(
        title: 'New Trend',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: {
          Routes.register: (context) => const RegisterPage(),
          Routes.productDetails: (context) => const ProductDetailsPage(),
          Routes.checkout: (context) => const CheckoutPage(),
          Routes.orderSuccess: (context) => const OrderSuccessPage(),
          Routes.orders: (context) => const OrdersPage(),
          Routes.productEditor: (context) => const ProductEditorPage(),
        },
      ),
    );
  }
}
