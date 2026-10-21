class ProductModel {
  final dynamic id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final RatingModel rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> jsonData) {
    return ProductModel(
      id: jsonData['id'],
      title: jsonData['title'],
      price: double.parse(jsonData['price'].toString()),
      description: jsonData['description'],
      category: jsonData['category'],
      image: jsonData['image'],
      rating: jsonData['rating'] != null
          ? RatingModel.fromJson(jsonData['rating'])
          : RatingModel(rate: 0, count: 0),
    );
  }
}

class RatingModel {
  final double rate;
  final int count;

  RatingModel({required this.rate, required this.count});

  factory RatingModel.fromJson(Map<String, dynamic> jsonData) {
    return RatingModel(
      rate: double.parse(jsonData['rate'].toString()),
      count: jsonData['count'],
    );
  }
}
