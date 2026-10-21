import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/providers/auth_provider.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/edit_profile_sheet.dart';
import 'package:store_app/widgets/summary_row.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _placing = false;

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final user = auth.user!;

    if (user.address.isEmpty || user.phone.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Add your delivery details first')));
      await showEditProfileSheet(context);
      return;
    }

    setState(() => _placing = true);
    try {
      final order = await orders.placeOrder(
        user: user,
        items: cart.items,
        address: user.address,
      );
      cart.clear();
      navigator.pushReplacementNamed(Routes.orderSuccess, arguments: order);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't place your order. Your cart is safe, try again.")),
      );
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _Section(
                  title: 'Delivery',
                  action: 'Change',
                  onAction: () => showEditProfileSheet(context),
                  child: user.address.isEmpty
                      ? const Text('Add your address to continue.',
                          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(user.address,
                                style: const TextStyle(color: AppColors.inkSoft)),
                            const SizedBox(height: 2),
                            Text(user.phone, style: const TextStyle(color: AppColors.inkSoft)),
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Items (${cart.totalQuantity})',
                  child: Column(
                    children: [
                      for (final item in cart.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('${item.quantity}×',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item.product.title,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 10),
                              Text(Formatters.price(item.subtotal),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const _Section(
                  title: 'Payment',
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Cash on delivery',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Icon(Icons.check_circle, color: AppColors.accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SummaryRow(label: 'Subtotal', value: Formatters.price(cart.subtotal)),
                  SummaryRow(
                    label: 'Delivery',
                    value: cart.shipping == 0 ? 'Free' : Formatters.price(cart.shipping),
                    valueColor: cart.shipping == 0 ? AppColors.success : null,
                  ),
                  const Divider(height: 20, color: AppColors.line),
                  SummaryRow(label: 'Total', value: Formatters.price(cart.total), bold: true),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'Place order',
                    isLoading: _placing,
                    onTap: cart.isEmpty ? null : _placeOrder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action, this.onAction});

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppText.display(18)),
              const Spacer(),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(action!,
                      style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
