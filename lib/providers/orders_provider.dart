import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/models/order_model.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/models/user_model.dart';
import 'package:store_app/providers/cart_provider.dart';
import 'package:store_app/services/carts_service.dart';
import 'package:store_app/services/users_service.dart';
import 'package:store_app/storage/local_store.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(
    this._store, {
    CartsService? cartsService,
    UsersService? usersService,
  }) : _cartsService = cartsService ?? CartsService(),
       _usersService = usersService ?? UsersService() {
    _readLocal();
  }

  static const _key = 'orders';

  final LocalStore _store;
  final CartsService _cartsService;
  final UsersService _usersService;

  final List<Order> _local = [];
  List<Order> _server = [];
  bool _loadingServer = false;
  bool _serverFailed = false;

  bool get isLoadingServer => _loadingServer;
  bool get serverFailed => _serverFailed;

  List<Order> ordersOf(int userId) =>
      _sorted(_local.where((o) => o.userId == userId));

  /// Everything a merchant can see.
  List<Order> get allOrders => _sorted([..._local, ..._server]);

  List<Order> _sorted(Iterable<Order> orders) =>
      orders.toList()..sort((a, b) => b.date.compareTo(a.date));

  // ---------------------------------------------------------- placing

  Future<Order> placeOrder({
    required AppUser user,
    required List<CartItem> items,
    required String address,
  }) async {
    final date = DateTime.now();

    await AppLog.run(
      'Send order to server',
      () => _cartsService.createCart(
        userId: user.id,
        date: date,
        products: [
          for (final item in items)
            {
              'productId': (item.product.id as num).toInt(),
              'quantity': item.quantity,
            },
        ],
      ),
      onSuccess: (r) => r is Map ? 'server cart id ${r['id']}' : 'ok',
    );

    final order = Order(
      id: 'NT-${1001 + _local.length}',
      userId: user.id,
      customerName: user.fullName.isEmpty ? user.username : user.fullName,
      date: date,
      address: address,
      items: [
        for (final item in items)
          OrderItem(
            productId: item.product.id,
            title: item.product.title,
            image: item.product.image,
            category: item.product.category,
            price: item.product.price,
            quantity: item.quantity,
          ),
      ],
    );

    _local.add(order);
    await _saveLocal();
    AppLog.info(
      'ORDERS',
      '${order.id} placed: ${order.itemCount} items, total ${order.total.toStringAsFixed(2)}',
    );
    notifyListeners();
    return order;
  }

  // ------------------------------------------------------ merchant side

  /// Moves a local order forward: placed → shipped → delivered.
  Future<void> advance(Order order) async {
    if (order.fromServer || order.status == OrderStatus.delivered) return;
    order.status = OrderStatus.values[order.status.index + 1];
    await _saveLocal();
    AppLog.info('ORDERS', '${order.id} is now ${order.status.name}');
    notifyListeners();
  }

  Future<void> loadServerOrders(Map<dynamic, ProductModel> productsById) async {
    _loadingServer = true;
    _serverFailed = false;
    notifyListeners();

    try {
      final carts = await AppLog.run(
        'Load sample orders',
        () => _cartsService.getAllCarts(),
        onSuccess: (l) => '${l.length} orders',
      );

      var names = <int, String>{};
      try {
        final users = await AppLog.run(
          'Load customers',
          () => _usersService.getAllUsers(),
          onSuccess: (l) => '${l.length} customers',
        );
        names = {for (final u in users) u.id: u.fullName};
      } catch (_) {
        // Names are nice to have; orders still work without them.
      }

      _server = carts
          .map(
            (json) => _orderFromCart(
              json as Map<String, dynamic>,
              productsById,
              names,
            ),
          )
          .where((order) => order.items.isNotEmpty)
          .toList();
    } catch (_) {
      _serverFailed = true;
    }

    _loadingServer = false;
    notifyListeners();
  }

  Order _orderFromCart(
    Map<String, dynamic> json,
    Map<dynamic, ProductModel> productsById,
    Map<int, String> names,
  ) {
    final userId = json['userId'] as int;
    final items = <OrderItem>[];
    for (final entry in (json['products'] as List<dynamic>)) {
      final map = entry as Map<String, dynamic>;
      final product = productsById[map['productId']];
      if (product == null) continue;
      items.add(
        OrderItem(
          productId: product.id,
          title: product.title,
          image: product.image,
          category: product.category,
          price: product.price,
          quantity: map['quantity'] as int,
        ),
      );
    }

    return Order(
      id: 'S-${json['id']}',
      userId: userId,
      customerName: names[userId] ?? 'Customer $userId',
      date: DateTime.tryParse('${json['date']}') ?? DateTime.now(),
      items: items,
      address: '',
      status: OrderStatus.delivered,
      fromServer: true,
    );
  }

  // ---------------------------------------------------------- persistence

  Future<void> _saveLocal() {
    return _store.write(
      _key,
      jsonEncode(_local.map((o) => o.toJson()).toList()),
    );
  }

  void _readLocal() {
    final raw = _store.read(_key);
    if (raw == null) return;
    try {
      _local.addAll(
        (jsonDecode(raw) as List<dynamic>).map(
          (j) => Order.fromJson(j as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      AppLog.info('ORDERS', 'saved orders were unreadable, ignoring them');
    }
  }
}
