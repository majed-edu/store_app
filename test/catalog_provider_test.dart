import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/models/product_form_data.dart';
import 'package:store_app/models/product_json.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/services/add_product.dart';
import 'package:store_app/services/all_categories_service.dart';
import 'package:store_app/services/delete_product_service.dart';
import 'package:store_app/services/get_all_product_service.dart';
import 'package:store_app/services/products_query_service.dart';
import 'package:store_app/services/update_product.dart';
import 'package:store_app/storage/local_store.dart';

ProductModel _product(int id, String category) => ProductModel(
      id: id,
      title: 'Product $id',
      price: 10.0 * id,
      description: 'Description $id',
      category: category,
      image: 'https://example.com/$id.png',
      rating: RatingModel(rate: 4, count: 5),
    );

class _Products extends GetAllProductService {
  @override
  Future<List<ProductModel>> getAllProducts() async =>
      [_product(1, 'jewelery'), _product(2, 'electronics'), _product(3, 'electronics')];
}

class _Categories extends AllCategoriesService {
  @override
  Future<List<dynamic>> getAllCategories() async => ['electronics', 'jewelery'];
}

class _Query extends ProductsQueryService {
  @override
  Future<List<ProductModel>> getProducts({int? limit, String? sort}) async =>
      [_product(3, 'electronics'), _product(2, 'electronics')];
}

class _Add extends AddProduct {
  @override
  Future<dynamic> addProduct({
    required String title,
    required String price,
    required String description,
    required String image,
    required String category,
  }) async =>
      _product(21, category);
}

class _Update extends UpdateProductService {
  @override
  Future<dynamic> updateProduct({
    required int id,
    required String title,
    required String price,
    required String description,
    required String image,
    required String category,
  }) async =>
      _product(id, category);
}

class _Delete extends DeleteProductService {
  int? deletedId;

  @override
  Future<void> deleteProduct({required int id}) async => deletedId = id;
}

const _form = ProductFormData(
  title: 'New jacket',
  price: '49.5',
  description: 'Warm',
  image: 'https://example.com/jacket.png',
  category: 'electronics',
);

void main() {
  late LocalStore store;
  late _Delete deleter;

  CatalogProvider build() => CatalogProvider(
        store,
        productsService: _Products(),
        categoriesService: _Categories(),
        queryService: _Query(),
        addService: _Add(),
        updateService: _Update(),
        deleteService: deleter,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await LocalStore.open();
    deleter = _Delete();
  });

  test('load fills products, categories and new arrivals', () async {
    final catalog = build();
    await catalog.load();

    expect(catalog.status, LoadStatus.ready);
    expect(catalog.products.length, 3);
    expect(catalog.categories, ['electronics', 'jewelery']);
    expect(catalog.newArrivals.map((p) => p.id), [3, 2]);
  });

  test('merchant adds a product: it gets a local id and shows first', () async {
    final catalog = build();
    await catalog.load();
    final added = await catalog.createProduct(_form);

    expect(added.isLocal, isTrue);
    expect(catalog.products.first.id, added.id);
    expect(catalog.products.length, 4);
  });

  test('merchant edits an API product: the edit is applied on top', () async {
    final catalog = build();
    await catalog.load();
    await catalog.updateProduct(catalog.byId(1)!, _form);

    expect(catalog.byId(1)!.title, 'New jacket');
    expect(catalog.byId(1)!.rating.count, 5); // rating is kept
  });

  test('merchant deletes products: API ones are hidden, local ones removed', () async {
    final catalog = build();
    await catalog.load();
    final added = await catalog.createProduct(_form);

    await catalog.deleteProduct(catalog.byId(2)!);
    await catalog.deleteProduct(added);

    expect(deleter.deletedId, 2); // only API products hit the network
    expect(catalog.byId(2), isNull);
    expect(catalog.byId(added.id), isNull);
  });

  test('changes survive a restart', () async {
    final first = build();
    await first.load();
    await first.createProduct(_form);
    await first.deleteProduct(first.byId(3)!);

    final second = build();
    await second.load();
    expect(second.products.length, 3); // 3 from API - 1 deleted + 1 added
    expect(second.byId(3), isNull);
    expect(second.products.first.title, 'New jacket');
  });
}
