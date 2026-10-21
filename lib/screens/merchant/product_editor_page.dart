import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/models/product_form_data.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/providers/catalog_provider.dart';
import 'package:store_app/widgets/product_form.dart';

/// Merchant only. Opens empty to add a product, or filled to edit one.
class ProductEditorPage extends StatefulWidget {
  const ProductEditorPage({super.key});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  bool _saving = false;

  Future<void> _save(ProductModel? product, ProductFormData data) async {
    final catalog = context.read<CatalogProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      if (product == null) {
        await catalog.createProduct(data);
      } else {
        await catalog.updateProduct(product, data);
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(product == null ? 'Product added' : 'Changes saved'),
        ));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't save. Check your connection and try again.")),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    final categories = context.read<CatalogProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: Text(product == null ? 'New product' : 'Edit product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: ProductForm(
          initial: product,
          categories: categories,
          isSubmitting: _saving,
          submitLabel: product == null ? 'Add product' : 'Save changes',
          onSubmit: (data) => _save(product, data),
        ),
      ),
    );
  }
}
