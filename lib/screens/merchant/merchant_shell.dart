import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/screens/merchant/dashboard_tab.dart';
import 'package:store_app/screens/merchant/merchant_orders_tab.dart';
import 'package:store_app/screens/merchant/merchant_products_tab.dart';
import 'package:store_app/screens/shared/profile_tab.dart';
import 'package:store_app/theme/app_theme.dart';

/// The merchant's app: dashboard, products, orders, profile.
class MerchantShell extends StatefulWidget {
  const MerchantShell({super.key});

  @override
  State<MerchantShell> createState() => _MerchantShellState();
}

class _MerchantShellState extends State<MerchantShell> {
  @override
  void initState() {
    super.initState();
    context.read<ShellController>().reset();
    _loadOrders();
  }

  /// Orders are built from products, so the catalog must be loaded first.
  Future<void> _loadOrders() async {
    final catalog = context.read<CatalogProvider>();
    final orders = context.read<OrdersProvider>();
    await catalog.load();
    await orders.loadServerOrders(catalog.productsById);
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellController>();
    final toShip = context.select<OrdersProvider, int>(
      (o) => o.allOrders.where((order) => order.status.index == 0).length,
    );

    return Scaffold(
      body: IndexedStack(
        index: shell.index,
        children: const [
          DashboardTab(),
          MerchantProductsTab(),
          MerchantOrdersTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: shell.index,
          onDestinationSelected: shell.select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: toShip > 0,
                backgroundColor: AppColors.accent,
                label: Text('$toShip'),
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: toShip > 0,
                backgroundColor: AppColors.accent,
                label: Text('$toShip'),
                child: const Icon(Icons.receipt_long),
              ),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
