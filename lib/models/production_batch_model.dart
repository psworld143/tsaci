class ProductionBatch {
  final int? batchId;
  final String batchNumber;
  final int productId;
  final String productName;
  final double targetQuantity;
  final String unit;
  final DateTime scheduledDate;
  final String
  status; // 'planned', 'ongoing', 'on_hold', 'completed', 'cancelled'
  final String currentStage; // 'mixing', 'packing', 'qa', 'dispatch'
  final List<int> supervisorIds;
  final List<String> supervisorNames;
  final List<int> workerIds;
  final List<String> workerNames;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductionBatch({
    this.batchId,
    required this.batchNumber,
    required this.productId,
    required this.productName,
    required this.targetQuantity,
    required this.unit,
    required this.scheduledDate,
    required this.status,
    this.currentStage = 'mixing',
    this.supervisorIds = const [],
    this.supervisorNames = const [],
    this.workerIds = const [],
    this.workerNames = const [],
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductionBatch.fromJson(Map<String, dynamic> json) {
    return ProductionBatch(
      batchId: json['batch_id'],
      batchNumber: json['batch_number'] ?? '',
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      targetQuantity:
          double.tryParse(json['target_quantity']?.toString() ?? '0') ?? 0,
      unit: json['unit'] ?? 'kg',
      scheduledDate:
          DateTime.tryParse(json['scheduled_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'planned',
      currentStage: json['current_stage'] ?? 'mixing',
      supervisorIds:
          (json['supervisor_ids'] as List<dynamic>?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          [],
      supervisorNames:
          (json['supervisor_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      workerIds:
          (json['worker_ids'] as List<dynamic>?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          [],
      workerNames:
          (json['worker_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (batchId != null) 'batch_id': batchId,
      'batch_number': batchNumber,
      'product_id': productId,
      'target_quantity': targetQuantity,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'current_stage': currentStage,
      'supervisor_ids': supervisorIds,
      'worker_ids': workerIds,
      if (notes != null) 'notes': notes,
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'planned':
        return 'Planned';
      case 'ongoing':
        return 'Ongoing';
      case 'on_hold':
        return 'On Hold';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get stageDisplay {
    switch (currentStage.toLowerCase()) {
      case 'mixing':
        return 'Mixing';
      case 'packing':
        return 'Packing';
      case 'qa':
        return 'QA Check';
      case 'dispatch':
        return 'Dispatch';
      default:
        return currentStage;
    }
  }
}
