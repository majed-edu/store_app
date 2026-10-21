import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/order_card.dart';
import 'package:store_app/widgets/section_header.dart';

/// Numbers a merchant cares about: revenue, orders, what sells.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final catalog = context.watch<CatalogProvider>();
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.allOrders;

    final revenue = orders.fold(0.0, (sum, o) => sum + o.total);
    final average = orders.isEmpty ? 0.0 : revenue / orders.length;
    final toShip = orders.where((o) => o.status == OrderStatus.placed).length;

    // Money earned per category.
    final byCategory = <String, double>{};
    for (final order in orders) {
      for (final item in order.items) {
        byCategory[item.category] = (byCategory[item.category] ?? 0) + item.subtotal;
      }
    }
    final categoryRows = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = categoryRows.isEmpty ? 1.0 : categoryRows.first.value;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await catalog.load(force: true);
          await ordersProvider.loadServerOrders(catalog.productsById);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ScreenHeader(
              title: 'Overview',
              subtitle: 'Welcome back, ${user.displayFirstName}',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue',
                        style: TextStyle(color: Color(0xFFB4BCCB), fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(Formatters.price(revenue),
                        style: AppText.display(40, color: Colors.white)),
                    const SizedBox(height: 12),
                    Text(
                      '${Formatters.items(orders.length).replaceAll('item', 'order')} · average ${Formatters.price(average)}',
                      style: const TextStyle(color: Color(0xFFB4BCCB), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Products',
                      value: '${catalog.products.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.category_outlined,
                      label: 'Categories',
                      value: '${catalog.categories.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_shipping_outlined,
                      label: 'To ship',
                      value: '$toShip',
                      highlight: toShip > 0,
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Sales by category'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: categoryRows.isEmpty
                    ? Text(
                        ordersProvider.isLoadingServer
                            ? 'Loading sales...'
                            : 'No sales yet.',
                        style: const TextStyle(color: AppColors.inkSoft),
                      )
                    : Column(
                        children: [
                          for (final row in categoryRows)
                            _CategoryBar(
                              label: Formatters.sentenceCase(row.key),
                              value: row.value,
                              fraction: row.value / maxValue,
                            ),
                        ],
                      ),
              ),
            ),
            SectionHeader(
              title: 'Recent orders',
              actionLabel: 'See all',
              onAction: () => context.read<ShellController>().select(MerchantTabs.orders),
            ),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Orders will show up here.',
                    style: TextStyle(color: AppColors.inkSoft)),
              )
            else
              for (final order in orders.take(2))
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: OrderCard(order: order, showCustomer: true),
                ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: CustomButton(
                text: 'Add a product',
                icon: Icons.add,
                outlined: true,
                onTap: () => Navigator.pushNamed(context, Routes.productEditor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.accentSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 12),
          Text(value, style: AppText.display(26)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.label, required this.value, required this.fraction});

  final String label;
  final double value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(Formatters.price(value),
                  style: const TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.canvas,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
