// Calls your real services against FakeStoreAPI and prints PASS / FAIL.
//
// Run from the project root:   dart run tool/api_smoke_test.dart
import 'dart:io';

import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/jwt.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/services/add_product.dart';
import 'package:store_app/services/all_categories_service.dart';
import 'package:store_app/services/auth_service.dart';
import 'package:store_app/services/carts_service.dart';
import 'package:store_app/services/categories_service.dart';
import 'package:store_app/services/delete_product_service.dart';
import 'package:store_app/services/get_all_product_service.dart';
import 'package:store_app/services/products_query_service.dart';
import 'package:store_app/services/update_product.dart';
import 'package:store_app/services/users_service.dart';

int _passed = 0;
int _failed = 0;

void _expect(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> _check(String name, Future<void> Function() body) async {
  final stopwatch = Stopwatch()..start();
  try {
    await body();
    _passed++;
    print('  PASS  $name (${stopwatch.elapsedMilliseconds} ms)');
  } catch (error) {
    _failed++;
    print('  FAIL  $name → $error');
  }
}

Future<void> main() async {
  print('\nFakeStoreAPI smoke test\n');
  List<dynamic> categories = [];

  await _check('GetAllProductService', () async {
    final products = await GetAllProductService().getAllProducts();
    _expect(products.isNotEmpty, 'empty list');
    print('        ${products.length} products');
  });

  await _check('ProductsQueryService (limit + sort)', () async {
    final products = await ProductsQueryService().getProducts(limit: 3, sort: 'desc');
    _expect(products.length == 3, 'expected 3, got ${products.length}');
  });

  await _check('AllCategoriesService', () async {
    categories = await AllCategoriesService().getAllCategories();
    _expect(categories.isNotEmpty, 'empty list');
    print('        $categories');
  });

  await _check('CategoriesService', () async {
    final category = categories.first.toString();
    final list = await CategoriesService()
        .getCategoryProducts(categoryName: Uri.encodeComponent(category));
    _expect(list.isNotEmpty && list.every((p) => p.category == category), 'wrong products');
  });

  await _check('AddProduct', () async {
    final added = await AddProduct().addProduct(
      title: 'Smoke test',
      price: '49.5',
      description: 'test',
      image: 'https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg',
      category: 'electronics',
    ) as ProductModel;
    _expect(added.price == 49.5, 'price came back as ${added.price}');
  });

  await _check('UpdateProductService', () async {
    final updated = await UpdateProductService().updateProduct(
      id: 1,
      title: 'Updated',
      price: '10.5',
      description: 'test',
      image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
      category: 'electronics',
    ) as ProductModel;
    _expect(updated.title == 'Updated', 'title came back as ${updated.title}');
  });

  await _check('DeleteProductService', () => DeleteProductService().deleteProduct(id: 1));

  for (final account in [AppConfig.demoShopper, AppConfig.demoMerchant]) {
    await _check('Login as ${account.username} → token → profile', () async {
      final token = await AuthService()
          .login(username: account.username, password: account.password);
      final id = Jwt.userId(token);
      _expect(id != null, 'token has no user id');
      final user = await UsersService().getUser(id!);
      _expect(user.username == account.username, 'got @${user.username}');
      print('        ${user.fullName} → ${user.role.name}');
    });
  }

  await _check('Wrong password is rejected', () async {
    try {
      await AuthService().login(username: 'johnd', password: 'wrong');
    } catch (_) {
      return;
    }
    throw StateError('login should have failed');
  });

  await _check('UsersService.getAllUsers', () async {
    final users = await UsersService().getAllUsers();
    _expect(users.isNotEmpty, 'empty list');
    _expect(users.any((u) => u.role == UserRole.merchant), 'no merchant found');
  });

  await _check('CartsService.getAllCarts', () async {
    final carts = await CartsService().getAllCarts();
    _expect(carts.isNotEmpty, 'empty list');
  });

  await _check('CartsService.createCart', () async {
    final result = await CartsService().createCart(
      userId: 1,
      date: DateTime.now(),
      products: [
        {'productId': 1, 'quantity': 2},
      ],
    );
    _expect(result is Map && result['id'] != null, 'no id in $result');
  });

  print('\nResult: $_passed passed, $_failed failed\n');
  exit(_failed == 0 ? 0 : 1);
}
