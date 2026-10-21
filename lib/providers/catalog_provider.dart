import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/models/product_form_data.dart';
import 'package:store_app/models/product_json.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/services/add_product.dart';
import 'package:store_app/services/all_categories_service.dart';
import 'package:store_app/services/delete_product_service.dart';
import 'package:store_app/services/get_all_product_service.dart';
import 'package:store_app/services/products_query_service.dart';
import 'package:store_app/services/update_product.dart';
import 'package:store_app/storage/local_store.dart';

enum LoadStatus { loading, ready, error }

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(
    this._store, {
    GetAllProductService? productsService,
    AllCategoriesService? categoriesService,
    ProductsQueryService? queryService,
    AddProduct? addService,
    UpdateProductService? updateService,
    DeleteProductService? deleteService,
  }) : _productsService = productsService ?? GetAllProductService(),
       _categoriesService = categoriesService ?? AllCategoriesService(),
       _queryService = queryService ?? ProductsQueryService(),
       _addService = addService ?? AddProduct(),
       _updateService = updateService ?? UpdateProductService(),
       _deleteService = deleteService ?? DeleteProductService() {
    _readChanges();
  }

  static const _changesKey = 'catalog_changes';

  final LocalStore _store;
  final GetAllProductService _productsService;
  final AllCategoriesService _categoriesService;
  final ProductsQueryService _queryService;
  final AddProduct _addService;
  final UpdateProductService _updateService;
  final DeleteProductService _deleteService;

  LoadStatus _status = LoadStatus.loading;
  List<ProductModel> _fromApi = [];
  List<String> _apiCategories = [];
  List<dynamic> _newArrivalIds = [];

  // Merchant changes, saved on the device.
  final List<ProductModel> _added = [];
  final Map<dynamic, ProductModel> _edited = {};
  final Set<dynamic> _deleted = {};

  LoadStatus get status => _status;

  // -------------------------------------------------------------- loading

  Future<void>? _inFlight;

  /// Safe to call from several places: while a load is running, everyone waits for the same one.
  Future<void> load({bool force = false}) {
    if (_inFlight != null) return _inFlight!;
    if (!force && _status == LoadStatus.ready) return Future.value();
    return _inFlight = _load().whenComplete(() => _inFlight = null);
  }

  Future<void> _load() async {
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      // All three requests start together; we wait for every one of them.
      final productsFuture = AppLog.run(
        'Load all products',
        () => _productsService.getAllProducts(),
        onSuccess: (l) => '${l.length} products',
      );
      final categoriesFuture = AppLog.run(
        'Load categories',
        () => _categoriesService.getAllCategories(),
        onSuccess: (l) => '${l.length} categories',
      );
      final arrivalsFuture = AppLog.run(
        'Load new arrivals',
        () => _queryService.getProducts(limit: 6, sort: 'desc'),
        onSuccess: (l) => '${l.length} products',
      );
      await Future.wait<void>([
        productsFuture,
        categoriesFuture,
        arrivalsFuture,
      ]);

      _fromApi = await productsFuture;
      _apiCategories = (await categoriesFuture)
          .map((c) => c.toString())
          .toList();
      _newArrivalIds = (await arrivalsFuture).map((p) => p.id).toList();
      _status = LoadStatus.ready;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  // -------------------------------------------------------------- reading

  ProductModel _resolve(ProductModel product) => _edited[product.id] ?? product;

  List<ProductModel> get products => [
    ..._added,
    ..._fromApi.where((p) => !_deleted.contains(p.id)).map(_resolve),
  ];

  ProductModel? byId(dynamic id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Map<dynamic, ProductModel> get productsById => {
    for (final product in products) product.id: product,
  };

  List<String> get categories {
    final all = products;
    final names = [..._apiCategories];
    for (final product in all) {
      if (!names.contains(product.category)) names.add(product.category);
    }
    return names.where((name) => all.any((p) => p.category == name)).toList();
  }

  List<ProductModel> inCategory(String category) =>
      products.where((p) => p.category == category).toList();

  String? imageForCategory(String category) {
    final list = inCategory(category);
    return list.isEmpty ? null : list.first.image;
  }

  List<ProductModel> get newArrivals {
    final fromApi = _newArrivalIds
        .map(byId)
        .whereType<ProductModel>()
        .where((p) => !p.isLocal);
    return [..._added, ...fromApi].take(6).toList();
  }

  List<ProductModel> get topRated {
    final rated = products.where((p) => p.rating.count > 0).toList()
      ..sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
    return rated.take(6).toList();
  }

  // ------------------------------------------------------ merchant actions

  ProductModel _fromForm(dynamic id, ProductFormData data, RatingModel rating) {
    return ProductModel(
      id: id,
      title: data.title,
      price: double.parse(data.price),
      description: data.description,
      category: data.category,
      image: data.image,
      rating: rating,
    );
  }

  int _nextLocalId() {
    var highest = AppConfig.localIdStart - 1;
    for (final product in _added) {
      if ((product.id as int) > highest) highest = product.id as int;
    }
    return highest + 1;
  }

  Future<ProductModel> createProduct(ProductFormData data) async {
    await AppLog.run(
      'Add product "${data.title}"',
      () => _addService.addProduct(
        title: data.title,
        price: data.price,
        description: data.description,
        image: data.image,
        category: data.category,
      ),
      onSuccess: (r) => 'server answered with id ${(r as ProductModel).id}',
    );

    final product = _fromForm(
      _nextLocalId(),
      data,
      RatingModel(rate: 0, count: 0),
    );
    _added.insert(0, product);
    await _saveChanges();
    notifyListeners();
    return product;
  }

  Future<ProductModel> updateProduct(
    ProductModel original,
    ProductFormData data,
  ) async {
    // Products created in the app don't exist on the server, so skip the request.
    if (!original.isLocal) {
      await AppLog.run(
        'Update product #${original.id}',
        () => _updateService.updateProduct(
          id: original.id,
          title: data.title,
          price: data.price,
          description: data.description,
          image: data.image,
          category: data.category,
        ),
        onSuccess: (r) => 'server answered "${(r as ProductModel).title}"',
      );
    }

    final updated = _fromForm(original.id, data, original.rating);
    if (original.isLocal) {
      final index = _added.indexWhere((p) => p.id == original.id);
      if (index >= 0) _added[index] = updated;
    } else {
      _edited[original.id] = updated;
    }
    await _saveChanges();
    notifyListeners();
    return updated;
  }

  Future<void> deleteProduct(ProductModel product) async {
    if (!product.isLocal) {
      await AppLog.run(
        'Delete product #${product.id}',
        () => _deleteService.deleteProduct(id: product.id as int),
      );
      _deleted.add(product.id);
      _edited.remove(product.id);
    } else {
      _added.removeWhere((p) => p.id == product.id);
    }
    await _saveChanges();
    notifyListeners();
  }

  // ---------------------------------------------------------- persistence

  Future<void> _saveChanges() {
    return _store.write(
      _changesKey,
      jsonEncode({
        'added': _added.map((p) => p.toJson()).toList(),
        'edited': _edited.values.map((p) => p.toJson()).toList(),
        'deleted': _deleted.toList(),
      }),
    );
  }

  void _readChanges() {
    final raw = _store.read(_changesKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _added.addAll(
        (map['added'] as List<dynamic>).map(
          (j) => ProductModel.fromJson(j as Map<String, dynamic>),
        ),
      );
      for (final json in map['edited'] as List<dynamic>) {
        final product = ProductModel.fromJson(json as Map<String, dynamic>);
        _edited[product.id] = product;
      }
      _deleted.addAll(map['deleted'] as List<dynamic>);
    } catch (_) {
      AppLog.info('CATALOG', 'saved changes were unreadable, ignoring them');
    }
  }
}
