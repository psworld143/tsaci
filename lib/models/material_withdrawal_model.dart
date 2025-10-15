class MaterialWithdrawal {
  final int? withdrawalId;
  final int inventoryId;
  final String productName;
  final String category;
  final double requestedQuantity;
  final String unit;
  final int requestedBy; // User ID
  final String requestedByName;
  final int? batchId;
  final String? batchNumber;
  final String purpose;
  final String status; // 'pending', 'approved', 'rejected'
  final int? approvedBy; // Production Manager ID
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime requestedAt;

  MaterialWithdrawal({
    this.withdrawalId,
    required this.inventoryId,
    required this.productName,
    required this.category,
    required this.requestedQuantity,
    required this.unit,
    required this.requestedBy,
    required this.requestedByName,
    this.batchId,
    this.batchNumber,
    required this.purpose,
    this.status = 'pending',
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.rejectionReason,
    DateTime? requestedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  factory MaterialWithdrawal.fromJson(Map<String, dynamic> json) {
    return MaterialWithdrawal(
      withdrawalId: json['withdrawal_id'],
      inventoryId: json['inventory_id'] ?? 0,
      productName: json['product_name'] ?? '',
      category: json['category'] ?? '',
      requestedQuantity:
          double.tryParse(json['requested_quantity']?.toString() ?? '0') ?? 0,
      unit: json['unit'] ?? '',
      requestedBy: json['requested_by'] ?? 0,
      requestedByName: json['requested_by_name'] ?? '',
      batchId: json['batch_id'],
      batchNumber: json['batch_number'],
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? 'pending',
      approvedBy: json['approved_by'],
      approvedByName: json['approved_by_name'],
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      requestedAt:
          DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (withdrawalId != null) 'withdrawal_id': withdrawalId,
      'inventory_id': inventoryId,
      'product_name': productName,
      'category': category,
      'requested_quantity': requestedQuantity,
      'unit': unit,
      'requested_by': requestedBy,
      'requested_by_name': requestedByName,
      if (batchId != null) 'batch_id': batchId,
      if (batchNumber != null) 'batch_number': batchNumber,
      'purpose': purpose,
      'status': status,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedByName != null) 'approved_by_name': approvedByName,
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
