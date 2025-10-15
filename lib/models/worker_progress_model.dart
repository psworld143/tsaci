class WorkerProgress {
  final int? progressId;
  final int workerId;
  final String workerName;
  final String workerEmail;
  final int? batchId;
  final String? batchNumber;
  final DateTime date;
  final String taskDescription;
  final int hoursWorked;
  final double outputQuantity;
  final String? unit;
  final String status; // 'completed', 'in_progress', 'delayed'
  final String? notes;
  final List<WorkerFeedback> feedbacks;
  final DateTime createdAt;

  WorkerProgress({
    this.progressId,
    required this.workerId,
    required this.workerName,
    required this.workerEmail,
    this.batchId,
    this.batchNumber,
    required this.date,
    required this.taskDescription,
    required this.hoursWorked,
    required this.outputQuantity,
    this.unit,
    this.status = 'in_progress',
    this.notes,
    this.feedbacks = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkerProgress.fromJson(Map<String, dynamic> json) {
    return WorkerProgress(
      progressId: json['progress_id'],
      workerId: json['worker_id'] ?? 0,
      workerName: json['worker_name'] ?? '',
      workerEmail: json['worker_email'] ?? '',
      batchId: json['batch_id'],
      batchNumber: json['batch_number'],
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      taskDescription: json['task_description'] ?? '',
      hoursWorked: json['hours_worked'] ?? 0,
      outputQuantity:
          double.tryParse(json['output_quantity']?.toString() ?? '0') ?? 0,
      unit: json['unit'],
      status: json['status'] ?? 'in_progress',
      notes: json['notes'],
      feedbacks:
          (json['feedbacks'] as List<dynamic>?)
              ?.map((f) => WorkerFeedback.fromJson(f))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (progressId != null) 'progress_id': progressId,
      'worker_id': workerId,
      'worker_name': workerName,
      'worker_email': workerEmail,
      if (batchId != null) 'batch_id': batchId,
      if (batchNumber != null) 'batch_number': batchNumber,
      'date': date.toIso8601String(),
      'task_description': taskDescription,
      'hours_worked': hoursWorked,
      'output_quantity': outputQuantity,
      if (unit != null) 'unit': unit,
      'status': status,
      if (notes != null) 'notes': notes,
      'feedbacks': feedbacks.map((f) => f.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class WorkerFeedback {
  final int? feedbackId;
  final int progressId;
  final int managerId;
  final String managerName;
  final String feedbackText;
  final String rating; // 'excellent', 'good', 'needs_improvement'
  final DateTime createdAt;

  WorkerFeedback({
    this.feedbackId,
    required this.progressId,
    required this.managerId,
    required this.managerName,
    required this.feedbackText,
    required this.rating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkerFeedback.fromJson(Map<String, dynamic> json) {
    return WorkerFeedback(
      feedbackId: json['feedback_id'],
      progressId: json['progress_id'] ?? 0,
      managerId: json['manager_id'] ?? 0,
      managerName: json['manager_name'] ?? '',
      feedbackText: json['feedback_text'] ?? '',
      rating: json['rating'] ?? 'good',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (feedbackId != null) 'feedback_id': feedbackId,
      'progress_id': progressId,
      'manager_id': managerId,
      'manager_name': managerName,
      'feedback_text': feedbackText,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
