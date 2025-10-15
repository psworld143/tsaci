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
      inventoryId: int.parse(json['inventory_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: double.parse(json['quantity'].toString()),
      location: json['location'] ?? 'Main Warehouse',
      minimumThreshold: double.parse(
        json['minimum_threshold']?.toString() ?? '10',
      ),
      lastUpdated: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
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
