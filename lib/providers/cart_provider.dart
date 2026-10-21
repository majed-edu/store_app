import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:store_app/core/app_config.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/models/product_json.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/storage/local_store.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final ProductModel product;
  int quantity;

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
      );
}

/// The shopping cart. Saved on the device per user, so it survives closing the app.
class CartProvider extends ChangeNotifier {
  CartProvider(this._store);

  final LocalStore _store;
  final Map<dynamic, CartItem> _items = {};
  int? _userId;

  /// Called by the app whenever the logged-in user changes.
  void bindUser(int? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _items.clear();
    _load();
    // Notify after the current build is finished.
    Future.microtask(notifyListeners);
  }

  List<CartItem> get items => _items.values.toList(growable: false);
  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  double get shipping =>
      isEmpty || subtotal >= AppConfig.freeShippingThreshold ? 0 : AppConfig.shippingFee;

  double get total => subtotal + shipping;

  double get amountToFreeShipping =>
      math.max(0.0, AppConfig.freeShippingThreshold - subtotal);

  int quantityOf(dynamic productId) => _items[productId]?.quantity ?? 0;

  void add(ProductModel product, {int quantity = 1}) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity = math.min(AppConfig.maxQuantity, existing.quantity + quantity);
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: math.min(AppConfig.maxQuantity, quantity),
      );
    }
    AppLog.info('CART', 'added #${product.id} → qty ${quantityOf(product.id)}, subtotal ${subtotal.toStringAsFixed(2)}');
    _changed();
  }

  void increment(dynamic productId) {
    final item = _items[productId];
    if (item == null || item.quantity >= AppConfig.maxQuantity) return;
    item.quantity++;
    _changed();
  }

  void decrement(dynamic productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      remove(productId);
      return;
    }
    item.quantity--;
    _changed();
  }

  /// Returns the removed item so the UI can offer "Undo".
  CartItem? remove(dynamic productId) {
    final removed = _items.remove(productId);
    if (removed != null) {
      AppLog.info('CART', 'removed #$productId');
      _changed();
    }
    return removed;
  }

  void restore(CartItem item) {
    _items[item.product.id] = item;
    _changed();
  }

  void clear() {
    _items.clear();
    AppLog.info('CART', 'cleared');
    _changed();
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------- persistence

  String get _key => 'cart_$_userId';

  void _save() {
    if (_userId == null) return;
    _store.write(_key, jsonEncode(_items.values.map((i) => i.toJson()).toList()));
  }

  void _load() {
    if (_userId == null) return;
    final raw = _store.read(_key);
    if (raw == null) return;
    try {
      for (final json in jsonDecode(raw) as List<dynamic>) {
        final item = CartItem.fromJson(json as Map<String, dynamic>);
        _items[item.product.id] = item;
      }
    } catch (_) {
      AppLog.info('CART', 'saved cart was unreadable, starting empty');
    }
  }
}
