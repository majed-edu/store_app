import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/providers/orders_provider.dart';
import 'package:store_app/services/carts_service.dart';
import 'package:store_app/storage/local_store.dart';

class _FakeCartsService extends CartsService {
  List<Map<String, int>>? sent;

  @override
  Future<dynamic> createCart({
    required int userId,
    required DateTime date,
    required List<Map<String, int>> products,
  }) async {
    sent = products;
    return {'id': 8};
  }
}

const _user = AppUser(
  id: 3,
  username: 'sara',
  email: 'sara@example.com',
  firstName: 'sara',
  lastName: 'ali',
  phone: '050',
  street: '1 main st',
  city: 'riyadh',
  role: UserRole.customer,
);

ProductModel _product(int id, double price) => ProductModel(
      id: id,
      title: 'Product $id',
      price: price,
      description: 'd',
      category: 'electronics',
      image: 'https://example.com/$id.png',
      rating: RatingModel(rate: 4, count: 1),
    );

void main() {
  late LocalStore store;
  late _FakeCartsService carts;
  late OrdersProvider orders;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await LocalStore.open();
    carts = _FakeCartsService();
    orders = OrdersProvider(store, cartsService: carts);
  });

  test('placing an order sends the cart and saves the order', () async {
    final items = [CartItem(product: _product(1, 30), quantity: 2)];
    final order = await orders.placeOrder(user: _user, items: items, address: '1 Main St');

    expect(carts.sent, [
      {'productId': 1, 'quantity': 2},
    ]);
    expect(order.subtotal, 60);
    expect(order.status, OrderStatus.placed);
    expect(orders.ordersOf(3).length, 1);
    expect(orders.ordersOf(99), isEmpty);
  });

  test('merchant moves the order forward, and it is saved', () async {
    final order = await orders.placeOrder(
      user: _user,
      items: [CartItem(product: _product(1, 120))],
      address: 'x',
    );
    await orders.advance(order);
    await orders.advance(order);
    await orders.advance(order); // already delivered: nothing happens
    expect(order.status, OrderStatus.delivered);

    final restarted = OrdersProvider(store, cartsService: carts);
    expect(restarted.ordersOf(3).single.status, OrderStatus.delivered);
  });

  test('delivery fee follows the same free-shipping rule as the cart', () {
    final small = Order(
      id: 'a', userId: 1, customerName: 'x', date: DateTime(2026), address: '',
      items: const [
        OrderItem(productId: 1, title: 't', image: 'i', category: 'c', price: 40, quantity: 1),
      ],
    );
    expect(small.total, 46);
  });
}
