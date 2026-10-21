import 'package:flutter/material.dart';
import 'package:store_app/core/app_logger.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/validators.dart';
import 'package:store_app/models/product_form_data.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/theme/app_theme.dart';
import 'package:store_app/widgets/custom_button.dart';
import 'package:store_app/widgets/custom_text_field.dart';
import 'package:store_app/widgets/product_image.dart';

/// One form for both "Add product" and "Edit product" (merchant only).
class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    required this.categories,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
    this.isSubmitting = false,
  });

  final List<String> categories;
  final String submitLabel;
  final Future<void> Function(ProductFormData data) onSubmit;
  final ProductModel? initial;
  final bool isSubmitting;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _imageFocus = FocusNode();

  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title);
  late final TextEditingController _price =
      TextEditingController(text: widget.initial?.price.toString());
  late final TextEditingController _description =
      TextEditingController(text: widget.initial?.description);
  late final TextEditingController _image =
      TextEditingController(text: widget.initial?.image);

  late String _category = widget.initial?.category ??
      (widget.categories.isNotEmpty ? widget.categories.first : '');

  // The preview updates when the merchant leaves the image field,
  // so we don't download a half-typed link on every key press.
  late String _previewUrl = widget.initial?.image ?? '';

  @override
  void initState() {
    super.initState();
    _imageFocus.addListener(() {
      if (!_imageFocus.hasFocus) {
        setState(() => _previewUrl = _image.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    _image.dispose();
    _imageFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      AppLog.info('FORM', 'validation failed, nothing was sent');
      return;
    }
    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a category for this product')),
      );
      return;
    }
    await widget.onSubmit(ProductFormData(
      title: _title.text.trim(),
      price: _price.text.trim(),
      description: _description.text.trim(),
      image: _image.text.trim(),
      category: _category,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = Validators.imageUrl(_previewUrl) == null;

    // Keep the current category selectable even if no other product uses it.
    final categories = widget.categories.contains(_category) || _category.isEmpty
        ? widget.categories
        : [_category, ...widget.categories];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: hasPreview
                ? ProductImage(url: _previewUrl)
                : const Center(
                    child: Text('Image preview appears here',
                        style: TextStyle(color: AppColors.inkSoft)),
                  ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Product name',
            controller: _title,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                Validators.requiredText(v, message: 'Enter a product name'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Price (USD)',
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: Validators.price,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Description',
            controller: _description,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            validator: (v) =>
                Validators.requiredText(v, message: 'Enter a description'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Image link',
            hintText: 'https://...',
            controller: _image,
            focusNode: _imageFocus,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            validator: Validators.imageUrl,
          ),
          const SizedBox(height: 24),
          const Text('Category',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                ChoiceChip(
                  label: Text(Formatters.sentenceCase(category)),
                  selected: category == _category,
                  showCheckmark: false,
                  selectedColor: AppColors.accentSoft,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: category == _category ? AppColors.accent : AppColors.line,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: widget.submitLabel,
            isLoading: widget.isSubmitting,
            onTap: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
