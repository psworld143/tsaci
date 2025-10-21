class SalesModel {
  final int saleId;
  final int customerId;
  final String customerName;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String status;
  final DateTime date;
  final DateTime createdAt;

  SalesModel({
    required this.saleId,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.createdAt,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      saleId: _parseInt(json['sale_id']),
      customerId: _parseInt(json['customer_id']),
      customerName: json['customer_name'] ?? '',
      productId: _parseInt(json['product_id']),
      productName: json['product_name'] ?? json['name'] ?? '',
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status'] ?? 'pending',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
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
      'sale_id': saleId,
      'customer_id': customerId,
      'customer_name': customerName,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'status': status,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
