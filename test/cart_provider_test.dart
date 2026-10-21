import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/storage/local_store.dart';

ProductModel _product(int id, double price) => ProductModel(
      id: id,
      title: 'Product $id',
      price: price,
      description: 'Description $id',
      category: 'electronics',
      image: 'https://example.com/$id.png',
      rating: RatingModel(rate: 4, count: 10),
    );

void main() {
  late LocalStore store;
  late CartProvider cart;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await LocalStore.open();
    cart = CartProvider(store);
  });

  test('same product twice raises quantity', () {
    cart.add(_product(1, 10));
    cart.add(_product(1, 10));
    expect(cart.items.length, 1);
    expect(cart.quantityOf(1), 2);
  });

  test('quantity is capped', () {
    cart.add(_product(1, 10), quantity: 50);
    expect(cart.quantityOf(1), AppConfig.maxQuantity);
  });

  test('delivery is charged under the free-shipping limit only', () {
    cart.add(_product(1, 30));
    expect(cart.shipping, AppConfig.shippingFee);
    expect(cart.total, 30 + AppConfig.shippingFee);

    cart.add(_product(2, 80));
    expect(cart.shipping, 0);
    expect(cart.amountToFreeShipping, 0);
  });

  test('decrement removes the product at zero, undo brings it back', () {
    cart.add(_product(1, 10));
    cart.decrement(1);
    expect(cart.isEmpty, isTrue);

    final removed = (cart..add(_product(2, 10))).remove(2)!;
    cart.restore(removed);
    expect(cart.quantityOf(2), 1);
  });

  test('cart is saved per user and restored', () async {
    cart.bindUser(7);
    cart.add(_product(1, 10), quantity: 3);

    final other = CartProvider(store)..bindUser(7);
    expect(other.quantityOf(1), 3);

    final stranger = CartProvider(store)..bindUser(8);
    expect(stranger.isEmpty, isTrue);
  });
}
