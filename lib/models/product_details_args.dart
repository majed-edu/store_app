import 'package:store_app/models/product_model.dart';

/// What the details page needs: the product, and the Hero tag of the card
/// that was tapped (so the image flies from exactly that card).
class ProductDetailsArgs {
  const ProductDetailsArgs({required this.product, required this.heroTag});

  final ProductModel product;
  final String heroTag;
}
