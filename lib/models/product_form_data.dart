/// The values a merchant typed in the product form.
/// Price stays a String because the services expect a String.
class ProductFormData {
  const ProductFormData({
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
  });

  final String title, price, description, image, category;
}
