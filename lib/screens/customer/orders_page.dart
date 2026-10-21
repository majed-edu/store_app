import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/widgets/order_card.dart';
import 'package:store_app/widgets/state_views.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final orders = context.watch<OrdersProvider>().ordersOf(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? StateMessage(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'When you place an order you can follow it here.',
              actionLabel: 'Start shopping',
              onAction: () {
                context.read<ShellController>().openExplore();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) => OrderCard(order: orders[index]),
            ),
    );
  }
}
