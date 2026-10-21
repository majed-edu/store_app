import 'package:flutter/material.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/product_image.dart';

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Placed';
    case OrderStatus.shipped:
      return 'Shipped';
    case OrderStatus.delivered:
      return 'Delivered';
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final delivered = status == OrderStatus.delivered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: delivered ? AppColors.successSoft : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        orderStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: delivered ? AppColors.success : AppColors.accent,
        ),
      ),
    );
  }
}

/// Three steps: Placed → Shipped → Delivered.
class OrderProgress extends StatelessWidget {
  const OrderProgress({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatus.values;

    Widget dot(int index) {
      final reached = index <= status.index;
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: reached ? AppColors.accent : AppColors.canvas,
          shape: BoxShape.circle,
        ),
        child: reached
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : null,
      );
    }

    Widget line(int index) => Expanded(
          child: Container(
            height: 3,
            color: index < status.index ? AppColors.accent : AppColors.canvas,
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              dot(i),
              if (i < steps.length - 1) line(i),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final step in steps)
              Text(orderStatusLabel(step),
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
          ],
        ),
      ],
    );
  }
}

/// One order. Shoppers see the progress; merchants also see the customer
/// and get a button to move the order forward.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.showCustomer = false,
    this.onAdvance,
  });

  final Order order;
  final bool showCustomer;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final visible = order.items.take(4).toList();
    final hidden = order.items.length - visible.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: AppText.display(18)),
              const Spacer(),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            showCustomer
                ? '${order.customerName} · ${Formatters.date(order.date)}'
                : Formatters.date(order.date),
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final item in visible)
                Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ProductImage(url: item.image, padding: const EdgeInsets.all(6)),
                ),
              if (hidden > 0)
                Text('+$hidden', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.price(order.total), style: AppText.display(20)),
                  Text(Formatters.items(order.itemCount),
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          OrderProgress(status: order.status),
          if (onAdvance != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: order.status == OrderStatus.placed
                  ? 'Mark as shipped'
                  : 'Mark as delivered',
              onTap: onAdvance,
            ),
          ],
        ],
      ),
    );
  }
}
