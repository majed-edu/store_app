import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/models/product_details_args.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/favorite_button.dart';
import 'package:store_app/widgets/product_card.dart';
import 'package:store_app/widgets/product_image.dart';
import 'package:store_app/widgets/quantity_stepper.dart';
import 'package:store_app/widgets/rating_label.dart';

/// Shopper's product page: image, price, rating, full description,
/// similar products, and "Add to cart".
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  void _addToCart(ProductModel product) {
    HapticFeedback.lightImpact();
    context.read<CartProvider>().add(product, quantity: _quantity);

    // Captured now, because the snackbar action can run after this page is gone.
    final shell = context.read<ShellController>();
    final navigator = Navigator.of(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added $_quantity to cart'),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () {
              shell.select(CustomerTabs.cart);
              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ProductDetailsArgs;
    final product = args.product;
    final imageHeight = MediaQuery.sizeOf(context).height * 0.40;

    final related = context
        .read<CatalogProvider>()
        .inCategory(product.category)
        .where((p) => p.id != product.id)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: SafeArea(
              bottom: false,
              child: Hero(
                tag: args.heroTag,
                child: ProductImage(
                  url: product.image,
                  padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _CircleAction(
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const Spacer(),
                    _CircleAction(child: FavoriteButton(productId: product.id)),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: imageHeight - 28,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Formatters.sentenceCase(product.category),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(product.title,
                              style: AppText.display(24).copyWith(height: 1.2)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(Formatters.price(product.price),
                                  style: AppText.display(30)),
                              const Spacer(),
                              RatingLabel(rating: product.rating, showCount: true),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Description',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                                fontSize: 15, height: 1.55, color: AppColors.inkSoft),
                          ),
                          if (related.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            const Text('More like this',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 230,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: related.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) => SizedBox(
                                  width: 160,
                                  child: ProductCard(
                                    product: related[index],
                                    heroScope: 'related-${product.id}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Row(
                          children: [
                            QuantityStepper(
                              quantity: _quantity,
                              canIncrement: _quantity < AppConfig.maxQuantity,
                              onDecrement: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              onIncrement: () => setState(() => _quantity++),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                icon: Icons.shopping_bag_outlined,
                                text: 'Add · ${Formatters.price(product.price * _quantity)}',
                                onTap: () => _addToCart(product),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.canvas, shape: BoxShape.circle),
      child: child,
    );
  }
}
