import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/product_image.dart';
import 'package:store_app/widgets/quantity_stepper.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';
import 'package:store_app/widgets/summary_row.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'Cart',
            subtitle: cart.isEmpty ? null : Formatters.items(cart.totalQuantity),
          ),
          Expanded(
            child: cart.isEmpty
                ? StateMessage(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message: 'Add something you like and it will wait for you here.',
                    actionLabel: 'Browse products',
                    onAction: () => context.read<ShellController>().openExplore(),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      _ShippingProgress(cart: cart),
                      const SizedBox(height: 14),
                      for (final item in cart.items) ...[
                        _CartTile(item: item),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
          if (!cart.isEmpty) _Summary(cart: cart),
        ],
      ),
    );
  }
}

class _ShippingProgress extends StatelessWidget {
  const _ShippingProgress({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final free = cart.amountToFreeShipping == 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: free ? AppColors.successSoft : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            free
                ? "You've got free delivery"
                : 'Add ${Formatters.price(cart.amountToFreeShipping)} more for free delivery',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: free ? AppColors.success : AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (cart.subtotal / AppConfig.freeShippingThreshold).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white,
              color: free ? AppColors.success : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = item.product;

    return Dismissible(
      key: ValueKey('cart-${product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        final messenger = ScaffoldMessenger.of(context);
        final removed = cart.remove(product.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Removed from cart'),
              action: removed == null
                  ? null
                  : SnackBarAction(label: 'Undo', onPressed: () => cart.restore(removed)),
            ),
          );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: ProductImage(url: product.image, padding: const EdgeInsets.all(4)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
                  const SizedBox(height: 4),
                  Text(Formatters.price(item.subtotal), style: AppText.display(17)),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    quantity: item.quantity,
                    canIncrement: item.quantity < AppConfig.maxQuantity,
                    onDecrement: () => cart.decrement(product.id),
                    onIncrement: () => cart.increment(product.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
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
            text: 'Checkout',
            onTap: () => Navigator.pushNamed(context, Routes.checkout),
          ),
        ],
      ),
    );
  }
}
