import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/storage/local_store.dart';

/// The products a shopper marked with a heart. Saved on the device per user.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._store);

  final LocalStore _store;
  final Set<dynamic> _ids = {};
  int? _userId;

  void bindUser(int? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _ids.clear();
    if (userId != null) {
      final raw = _store.read('favorites_$userId');
      if (raw != null) _ids.addAll(jsonDecode(raw) as List<dynamic>);
    }
    Future.microtask(notifyListeners);
  }

  List<dynamic> get ids => _ids.toList(growable: false);
  int get count => _ids.length;

  bool isFavorite(dynamic productId) => _ids.contains(productId);

  void toggle(dynamic productId) {
    final removed = _ids.remove(productId);
    if (!removed) _ids.add(productId);
    AppLog.info('FAVORITES', '#$productId ${removed ? 'removed' : 'added'} (${_ids.length} total)');
    if (_userId != null) {
      _store.write('favorites_$_userId', jsonEncode(_ids.toList()));
    }
    notifyListeners();
  }
}
