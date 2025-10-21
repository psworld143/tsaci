class InventoryModel {
  final int inventoryId;
  final int productId;
  final String productName;
  final String category;
  final double quantity;
  final String location;
  final double minimumThreshold;
  final DateTime? lastUpdated;

  InventoryModel({
    required this.inventoryId,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.location,
    required this.minimumThreshold,
    this.lastUpdated,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: _parseInt(json['inventory_id']),
      productId: _parseInt(json['product_id']),
      productName: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: _parseDouble(json['quantity']),
      location: json['location'] ?? 'Main Warehouse',
      minimumThreshold: _parseDouble(json['minimum_threshold'] ?? 10),
      lastUpdated: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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

  bool get isLowStock => quantity <= minimumThreshold;

  Map<String, dynamic> toJson() {
    return {
      'inventory_id': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'quantity': quantity,
      'location': location,
      'minimum_threshold': minimumThreshold,
      'updated_at': lastUpdated?.toIso8601String(),
    };
  }
}
