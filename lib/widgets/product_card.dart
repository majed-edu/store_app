import 'package:flutter/material.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/models/product_details_args.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/favorite_button.dart';
import 'package:store_app/widgets/product_image.dart';
import 'package:store_app/widgets/pulse.dart';
import 'package:store_app/widgets/rating_label.dart';

/// Card used in every product list. Tapping it opens the details page.
///
/// [heroScope] must be different for each list on screen (for example "home-new"
/// and "explore"), so the same product shown twice never shares a Hero tag.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.heroScope});

  final ProductModel product;
  final String heroScope;

  @override
  Widget build(BuildContext context) {
    final heroTag = '$heroScope-${product.id}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          Routes.productDetails,
          arguments: ProductDetailsArgs(product: product, heroTag: heroTag),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: ProductImage(
                        url: product.image,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: FavoriteButton(productId: product.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(Formatters.price(product.price),
                          style: AppText.display(18)),
                      const Spacer(),
                      RatingLabel(rating: product.rating),
                    ],
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

/// Grey placeholder shown while products load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Pulse(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBox(height: double.infinity, radius: 14)),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity),
            SizedBox(height: 8),
            SkeletonBox(width: 70),
          ],
        ),
      ),
    );
  }
}

const productGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.68,
);

/// A grid of product cards (or skeletons) to use inside a CustomScrollView.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key, required this.products, required this.heroScope});

  final List<ProductModel> products;
  final String heroScope;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: productGridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(product: products[index], heroScope: heroScope),
        childCount: products.length,
      ),
    );
  }
}

class ProductSkeletonSliverGrid extends StatelessWidget {
  const ProductSkeletonSliverGrid({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: productGridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ProductCardSkeleton(),
        childCount: count,
      ),
    );
  }
}
