class StockAdjustment {
  final int? adjustmentId;
  final int inventoryId;
  final String productName;
  final String adjustmentType; // IN, OUT, DAMAGE, WASTE, TRANSFER
  final double quantity;
  final String reason;
  final int adjustedBy;
  final String adjustedByName;
  final DateTime createdAt;

  StockAdjustment({
    this.adjustmentId,
    required this.inventoryId,
    required this.productName,
    required this.adjustmentType,
    required this.quantity,
    required this.reason,
    required this.adjustedBy,
    required this.adjustedByName,
    required this.createdAt,
  });

  factory StockAdjustment.fromJson(Map<String, dynamic> json) {
    return StockAdjustment(
      adjustmentId: json['adjustment_id'],
      inventoryId: _parseInt(json['inventory_id']),
      productName: json['product_name'] ?? '',
      adjustmentType: json['adjustment_type'] ?? 'IN',
      quantity: _parseDouble(json['quantity']),
      reason: json['reason'] ?? '',
      adjustedBy: _parseInt(json['adjusted_by']),
      adjustedByName: json['adjusted_by_name'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (adjustmentId != null) 'adjustment_id': adjustmentId,
      'inventory_id': inventoryId,
      'product_name': productName,
      'adjustment_type': adjustmentType,
      'quantity': quantity,
      'reason': reason,
      'adjusted_by': adjustedBy,
      'adjusted_by_name': adjustedByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.parse(value.toString()).toInt();
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }

  String get typeDisplay {
    switch (adjustmentType.toUpperCase()) {
      case 'IN':
        return 'Stock In';
      case 'OUT':
        return 'Stock Out';
      case 'DAMAGE':
        return 'Damaged';
      case 'WASTE':
        return 'Wastage';
      case 'TRANSFER':
        return 'Transfer';
      default:
        return adjustmentType;
    }
  }
}
