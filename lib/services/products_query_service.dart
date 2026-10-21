import 'package:store_app/core/app_config.dart';
import 'package:store_app/helper/api.dart';
import 'package:store_app/models/product_model.dart';

/// GET /products?limit=5&sort=desc  (the API supports both options)
class ProductsQueryService {
  Future<List<ProductModel>> getProducts({int? limit, String? sort}) async {
    final query = <String>[
      if (limit != null) 'limit=$limit',
      if (sort != null) 'sort=$sort',
    ].join('&');

    List<dynamic> data = await Api().get(
      url: '${AppConfig.baseUrl}/products${query.isEmpty ? '' : '?$query'}',
    );

    return data
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
