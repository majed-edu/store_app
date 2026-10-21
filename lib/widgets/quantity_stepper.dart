import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';

/// − 2 +  control used in the cart and on the details page.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.canIncrement = true,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool canIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(icon: Icons.remove, tooltip: 'Decrease quantity', onPressed: onDecrement),
        SizedBox(
          width: 36,
          child: Text('$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        _RoundButton(
          icon: Icons.add,
          tooltip: 'Increase quantity',
          onPressed: canIncrement ? onIncrement : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon,
                size: 18,
                color: onPressed == null ? AppColors.line : AppColors.ink),
          ),
        ),
      ),
    );
  }
}
