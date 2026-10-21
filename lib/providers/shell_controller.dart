import 'package:flutter/foundation.dart';

class CustomerTabs {
  static const home = 0;
  static const explore = 1;
  static const saved = 2;
  static const cart = 3;
  static const profile = 4;
}

class MerchantTabs {
  static const dashboard = 0;
  static const products = 1;
  static const orders = 2;
  static const profile = 3;
}

/// Which bottom-bar tab is open. Any screen can change it
/// (for example "View cart" from a snackbar on the details page).
class ShellController extends ChangeNotifier {
  int index = 0;

  // Used to open the Explore tab with a category selected, or the search focused.
  int exploreRequestId = 0;
  String? exploreCategory;
  bool focusSearch = false;

  void select(int newIndex) {
    index = newIndex;
    notifyListeners();
  }

  void openExplore({String? category, bool focusSearch = false}) {
    index = CustomerTabs.explore;
    exploreCategory = category;
    this.focusSearch = focusSearch;
    exploreRequestId++;
    notifyListeners();
  }

  /// Called when a different user logs in. Doesn't notify (it runs while building).
  void reset() {
    index = 0;
    exploreCategory = null;
    focusSearch = false;
  }
}
