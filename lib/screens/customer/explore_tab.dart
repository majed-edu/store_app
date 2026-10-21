import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/providers/shell_controller.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/category_tabs.dart';
import 'package:store_app/widgets/product_card.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';

enum _Sort { featured, priceLow, priceHigh, topRated }

const _sortLabels = {
  _Sort.featured: 'Featured',
  _Sort.priceLow: 'Price: low to high',
  _Sort.priceHigh: 'Price: high to low',
  _Sort.topRated: 'Top rated',
};

/// Search, filter by category, and sort.
class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  static const _all = 'all';

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  late final ShellController _shell;

  String _category = _all;
  _Sort _sort = _Sort.featured;
  int _handledRequest = 0;

  @override
  void initState() {
    super.initState();
    _shell = context.read<ShellController>();
    _shell.addListener(_onShellChanged);
  }

  @override
  void dispose() {
    _shell.removeListener(_onShellChanged);
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Home asked us to open a category or focus the search field.
  void _onShellChanged() {
    if (_shell.exploreRequestId == _handledRequest) return;
    _handledRequest = _shell.exploreRequestId;
    setState(() => _category = _shell.exploreCategory ?? _all);
    if (_shell.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  List<ProductModel> _results(CatalogProvider catalog) {
    var list = _category == _all ? catalog.products : catalog.inCategory(_category);

    final query = _search.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    switch (_sort) {
      case _Sort.featured:
        break;
      case _Sort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.topRated:
        list.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
    }
    return list;
  }

  Future<void> _pickSort() async {
    final picked = await showModalBottomSheet<_Sort>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in _Sort.values)
              ListTile(
                title: Text(_sortLabels[option]!,
                    style: TextStyle(
                        fontWeight: option == _sort ? FontWeight.w700 : FontWeight.w500)),
                trailing: option == _sort
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.pop(sheetContext, option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _category = _all;
      _sort = _Sort.featured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final results = _results(catalog);
    final isLoading = catalog.status == LoadStatus.loading && catalog.products.isEmpty;
    final hasFailed = catalog.status == LoadStatus.error && catalog.products.isEmpty;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'Explore'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _search,
              focusNode: _searchFocus,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          CategoryTabs(
            categories: [_all, ...catalog.categories],
            selected: _category,
            onSelected: (c) => setState(() => _category = c),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
            child: Row(
              children: [
                Text(Formatters.items(results.length).replaceAll('item', 'product'),
                    style: const TextStyle(color: AppColors.inkSoft)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickSort,
                  icon: const Icon(Icons.swap_vert, size: 20),
                  label: Text(_sortLabels[_sort]!),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const CustomScrollView(slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
                      sliver: ProductSkeletonSliverGrid(),
                    ),
                  ])
                : hasFailed
                    ? ErrorView(onRetry: () => catalog.load(force: true))
                    : results.isEmpty
                        ? StateMessage(
                            icon: Icons.search_off_rounded,
                            title: 'Nothing found',
                            message: 'Try another word or clear the filters.',
                            actionLabel: 'Clear filters',
                            onAction: _clearFilters,
                          )
                        : CustomScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                sliver: ProductSliverGrid(
                                  products: results,
                                  heroScope: 'explore',
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
