import 'package:store_app/core/app_config.dart';
import 'package:store_app/helper/api.dart';

class CartsService {
  Future<List<dynamic>> getAllCarts() async {
    final data = await Api().get(url: '${AppConfig.baseUrl}/carts');
    return data as List<dynamic>;
  }

  Future<dynamic> createCart({
    required int userId,
    required DateTime date,
    required List<Map<String, int>> products,
  }) {
    return Api().post(
      url: '${AppConfig.baseUrl}/carts',
      asJson: true,
      Token: null,
      body: {
        'userId': userId,
        'date': date.toIso8601String(),
        'products': products,
      },
    );
  }
}
