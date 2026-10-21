import 'package:flutter/material.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/theme/app_theme.dart';

class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, this.showCount = false});

  final RatingModel rating;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    // New products have no reviews yet, so there is nothing to show.
    if (rating.count == 0) return const SizedBox.shrink();

    final text = showCount
        ? '${rating.rate.toStringAsFixed(1)}  (${rating.count} reviews)'
        : rating.rate.toStringAsFixed(1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
      ],
    );
  }
}
