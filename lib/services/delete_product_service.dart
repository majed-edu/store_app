import 'package:store_app/core/app_config.dart';
import 'package:store_app/helper/api.dart';

class DeleteProductService {
  Future<void> deleteProduct({required int id}) async {
    await Api().delete(url: '${AppConfig.baseUrl}/products/$id');
  }
}
