import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/routes.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/product_image.dart';
import 'package:store_app/widgets/section_header.dart';
import 'package:store_app/widgets/state_views.dart';

/// The merchant's product list: add, edit and delete.
class MerchantProductsTab extends StatefulWidget {
  const MerchantProductsTab({super.key});

  @override
  State<MerchantProductsTab> createState() => _MerchantProductsTabState();
}

class _MerchantProductsTabState extends State<MerchantProductsTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final catalog = context.read<CatalogProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${product.title}" will be removed from the store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await catalog.deleteProduct(product);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Product deleted')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't delete the product. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final query = _search.text.trim().toLowerCase();
    final products = catalog.products
        .where((p) => query.isEmpty || p.title.toLowerCase().contains(query))
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'Products',
            subtitle: '${catalog.products.length} in your store',
            trailing: IconButton.filled(
              tooltip: 'Add product',
              onPressed: () => Navigator.pushNamed(context, Routes.productEditor),
              style: IconButton.styleFrom(backgroundColor: AppColors.accent),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search your products',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: catalog.status == LoadStatus.error && catalog.products.isEmpty
                ? ErrorView(onRetry: () => catalog.load(force: true))
                : products.isEmpty
                    ? const StateMessage(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products found',
                        message: 'Try another word, or add a new product.',
                      )
                    : ListView.separated(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _ProductRow(
                          product: products[index],
                          onEdit: () => Navigator.pushNamed(
                            context,
                            Routes.productEditor,
                            arguments: products[index],
                          ),
                          onDelete: () => _confirmDelete(products[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onEdit, required this.onDelete});

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: ProductImage(url: product.image, padding: const EdgeInsets.all(4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.price(product.price)} · ${Formatters.sentenceCase(product.category)}',
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
