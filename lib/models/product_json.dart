import 'package:store_app/core/app_config.dart';
import 'package:store_app/models/product_model.dart';

/// Lets us save a product on the device without touching `ProductModel`.
/// The result can be read back with `ProductModel.fromJson`.
extension ProductJson on ProductModel {
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'rating': {'rate': rating.rate, 'count': rating.count},
  };

  bool get isLocal => id is int && (id as int) >= AppConfig.localIdStart;
}
