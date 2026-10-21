import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/favorites_provider.dart';
import 'package:store_app/theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 22});

  final dynamic productId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context
        .select<FavoritesProvider, bool>((f) => f.isFavorite(productId));

    return IconButton(
      tooltip: isFavorite ? 'Remove from saved' : 'Save for later',
      onPressed: () => context.read<FavoritesProvider>().toggle(productId),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: size,
        color: isFavorite ? AppColors.danger : AppColors.inkSoft,
      ),
    );
  }
}
