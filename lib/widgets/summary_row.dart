import 'package:flutter/material.dart';
import 'package:store_app/theme/app_theme.dart';

/// One line of a price summary: "Subtotal ........ $120.00"
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value, this.bold = false, this.valueColor});

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: bold ? 17 : 15,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: bold ? AppColors.ink : AppColors.inkSoft,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          Text(
            value,
            style: bold
                ? AppText.display(22)
                : labelStyle.copyWith(color: valueColor ?? AppColors.ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
