class WorkerTask {
  final int? taskId;
  final int workerId;
  final String workerName;
  final int batchId;
  final String batchNumber;
  final String productName;
  final double targetQuantity;
  final double? completedQuantity;
  final String status; // not_started, in_progress, completed, paused
  final DateTime assignedDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;

  WorkerTask({
    this.taskId,
    required this.workerId,
    required this.workerName,
    required this.batchId,
    required this.batchNumber,
    required this.productName,
    required this.targetQuantity,
    this.completedQuantity,
    required this.status,
    required this.assignedDate,
    this.startedAt,
    this.completedAt,
    this.notes,
  });

  factory WorkerTask.fromJson(Map<String, dynamic> json) {
    return WorkerTask(
      taskId: json['task_id'],
      workerId: _parseInt(json['worker_id']),
      workerName: json['worker_name'] ?? '',
      batchId: _parseInt(json['batch_id']),
      batchNumber: json['batch_number'] ?? '',
      productName: json['product_name'] ?? '',
      targetQuantity: _parseDouble(json['target_quantity']),
      completedQuantity: json['completed_quantity'] != null
          ? _parseDouble(json['completed_quantity'])
          : null,
      status: json['status'] ?? 'not_started',
      assignedDate: DateTime.parse(
        json['assigned_date'] ?? DateTime.now().toIso8601String(),
      ),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'task_id': taskId,
      'worker_id': workerId,
      'worker_name': workerName,
      'batch_id': batchId,
      'batch_number': batchNumber,
      'product_name': productName,
      'target_quantity': targetQuantity,
      if (completedQuantity != null) 'completed_quantity': completedQuantity,
      'status': status,
      'assigned_date': assignedDate.toIso8601String(),
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
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

  bool get isNotStarted => status == 'not_started';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isPaused => status == 'paused';

  double get completionPercentage {
    if (completedQuantity == null || targetQuantity == 0) return 0;
    return (completedQuantity! / targetQuantity * 100).clamp(0, 100);
  }

  String get statusDisplay {
    switch (status) {
      case 'not_started':
        return 'Not Started';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'paused':
        return 'Paused';
      default:
        return status;
    }
  }
}

class WorkerPerformance {
  final int workerId;
  final String workerName;
  final int tasksCompleted;
  final double totalOutput;
  final double averageEfficiency;
  final int hoursWorked;
  final DateTime periodStart;
  final DateTime periodEnd;

  WorkerPerformance({
    required this.workerId,
    required this.workerName,
    required this.tasksCompleted,
    required this.totalOutput,
    required this.averageEfficiency,
    required this.hoursWorked,
    required this.periodStart,
    required this.periodEnd,
  });

  factory WorkerPerformance.fromJson(Map<String, dynamic> json) {
    return WorkerPerformance(
      workerId: _parseInt(json['worker_id']),
      workerName: json['worker_name'] ?? '',
      tasksCompleted: _parseInt(json['tasks_completed']),
      totalOutput: _parseDouble(json['total_output']),
      averageEfficiency: _parseDouble(json['average_efficiency']),
      hoursWorked: _parseInt(json['hours_worked']),
      periodStart: DateTime.parse(
        json['period_start'] ?? DateTime.now().toIso8601String(),
      ),
      periodEnd: DateTime.parse(
        json['period_end'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'worker_id': workerId,
      'worker_name': workerName,
      'tasks_completed': tasksCompleted,
      'total_output': totalOutput,
      'average_efficiency': averageEfficiency,
      'hours_worked': hoursWorked,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
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

  double get outputPerTask =>
      tasksCompleted > 0 ? totalOutput / tasksCompleted : 0;
}
