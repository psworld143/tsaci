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
      productId: _parseInt(json['product_id']),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: _parseDouble(json['price']),
      unit: json['unit'] ?? '',
    );
  }

  /// Safely parse integer values (handles both int and double from JSON)
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.parse(value.toString()).toInt();
  }

  /// Safely parse double values
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
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
