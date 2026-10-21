import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 28),
              Text('Order placed', style: AppText.display(32)),
              const SizedBox(height: 10),
              Text(
                '${order.id} · ${Formatters.items(order.itemCount)}\nPay ${Formatters.price(order.total)} when it arrives.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              CustomButton(
                text: 'Track my order',
                onTap: () => Navigator.pushReplacementNamed(context, Routes.orders),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Keep shopping',
                outlined: true,
                onTap: () {
                  context.read<ShellController>().select(CustomerTabs.home);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
