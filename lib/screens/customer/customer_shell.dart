import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/screens/customer/cart_tab.dart';
import 'package:store_app/screens/customer/explore_tab.dart';
import 'package:store_app/screens/customer/home_tab.dart';
import 'package:store_app/screens/customer/saved_tab.dart';
import 'package:store_app/screens/shared/profile_tab.dart';
import 'package:store_app/theme/app_theme.dart';

/// The shopper's app: five tabs in a bottom bar.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  @override
  void initState() {
    super.initState();
    context.read<ShellController>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellController>();
    final cartCount = context.select<CartProvider, int>((c) => c.totalQuantity);

    return Scaffold(
      body: IndexedStack(
        index: shell.index,
        children: const [
          HomeTab(),
          ExploreTab(),
          SavedTab(),
          CartTab(),
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Explore',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                backgroundColor: AppColors.accent,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                backgroundColor: AppColors.accent,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Cart',
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
