class ProductModel {
  final int productId;
  final String name;
  final String category;
  final double price;
  final String unit;

  ProductModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: int.parse(json['product_id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: double.parse(json['price'].toString()),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
    };
  }
}

// Alias for backward compatibility
typedef Product = ProductModel;
