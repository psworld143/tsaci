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
      saleId: int.parse(json['sale_id'].toString()),
      customerId: int.parse(json['customer_id'].toString()),
      customerName: json['customer_name'] ?? '',
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? json['name'] ?? '',
      quantity: int.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'] ?? 'pending',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
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
