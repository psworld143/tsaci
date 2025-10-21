class BatchTemplate {
  final int? templateId;
  final String templateName;
  final int productId;
  final String productName;
  final double targetQuantity;
  final String unit;
  final List<int> supervisorIds;
  final List<String> supervisorNames;
  final List<int> workerIds;
  final List<String> workerNames;
  final String? notes;
  final DateTime createdAt;

  BatchTemplate({
    this.templateId,
    required this.templateName,
    required this.productId,
    required this.productName,
    required this.targetQuantity,
    required this.unit,
    required this.supervisorIds,
    required this.supervisorNames,
    required this.workerIds,
    required this.workerNames,
    this.notes,
    required this.createdAt,
  });

  factory BatchTemplate.fromJson(Map<String, dynamic> json) {
    return BatchTemplate(
      templateId: json['template_id'],
      templateName: json['template_name'] ?? '',
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? '',
      targetQuantity: json['target_quantity'] is double
          ? json['target_quantity']
          : double.parse(json['target_quantity'].toString()),
      unit: json['unit'] ?? 'kg',
      supervisorIds:
          (json['supervisor_ids'] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.parse(e.toString()))
              .toList() ??
          [],
      supervisorNames:
          (json['supervisor_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      workerIds:
          (json['worker_ids'] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.parse(e.toString()))
              .toList() ??
          [],
      workerNames:
          (json['worker_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (templateId != null) 'template_id': templateId,
      'template_name': templateName,
      'product_id': productId,
      'product_name': productName,
      'target_quantity': targetQuantity,
      'unit': unit,
      'supervisor_ids': supervisorIds,
      'supervisor_names': supervisorNames,
      'worker_ids': workerIds,
      'worker_names': workerNames,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert template to batch data for API
  Map<String, dynamic> toBatchData() {
    return {
      'product_id': productId,
      'target_quantity': targetQuantity,
      'supervisor_ids': supervisorIds,
      'worker_ids': workerIds,
      'notes': notes,
      'status': 'planned',
      'current_stage': 'mixing',
    };
  }
}
