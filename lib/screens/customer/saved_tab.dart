import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/favorites_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/widgets/product_card.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final favorites = context.watch<FavoritesProvider>();

    final saved = favorites.ids
        .map(catalog.byId)
        .whereType<ProductModel>()
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'Saved',
            subtitle: saved.isEmpty ? null : '${saved.length} products you liked',
          ),
          Expanded(
            child: saved.isEmpty
                ? StateMessage(
                    icon: Icons.favorite_border,
                    title: 'Nothing saved yet',
                    message: 'Tap the heart on a product to keep it here.',
                    actionLabel: 'Browse products',
                    onAction: () => context.read<ShellController>().openExplore(),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        sliver: ProductSliverGrid(products: saved, heroScope: 'saved'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
