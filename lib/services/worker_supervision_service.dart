import '../models/worker_progress_model.dart';
import 'storage_service.dart';
import 'dart:convert';

/// Worker Supervision Service
class WorkerSupervisionService {
  static const String _storageKey = 'worker_progress';
  static int _nextProgressId = 1;
  static int _nextFeedbackId = 1;

  /// Get all progress reports
  static Future<List<WorkerProgress>> getAllProgress() async {
    try {
      final data = await StorageService.getData(_storageKey);
      if (data == null) return [];

      final List<dynamic> progressJson = json.decode(data);
      return progressJson.map((json) => WorkerProgress.fromJson(json)).toList();
    } catch (e) {
      print('[WorkerSupervisionService] Error loading progress: $e');
      return [];
    }
  }

  /// Get progress by worker ID
  static Future<List<WorkerProgress>> getProgressByWorker(int workerId) async {
    final all = await getAllProgress();
    return all.where((p) => p.workerId == workerId).toList();
  }

  /// Get progress by date
  static Future<List<WorkerProgress>> getProgressByDate(DateTime date) async {
    final all = await getAllProgress();
    return all.where((p) {
      return p.date.year == date.year &&
          p.date.month == date.month &&
          p.date.day == date.day;
    }).toList();
  }

  /// Create progress report
  static Future<WorkerProgress> createProgress(WorkerProgress progress) async {
    try {
      final progressList = await getAllProgress();

      final newProgress = WorkerProgress(
        progressId: _nextProgressId++,
        workerId: progress.workerId,
        workerName: progress.workerName,
        workerEmail: progress.workerEmail,
        batchId: progress.batchId,
        batchNumber: progress.batchNumber,
        date: progress.date,
        taskDescription: progress.taskDescription,
        hoursWorked: progress.hoursWorked,
        outputQuantity: progress.outputQuantity,
        unit: progress.unit,
        status: progress.status,
        notes: progress.notes,
        feedbacks: [],
        createdAt: DateTime.now(),
      );

      progressList.add(newProgress);
      await _saveProgress(progressList);

      print(
        '[WorkerSupervisionService] Progress created: #${newProgress.progressId}',
      );
      return newProgress;
    } catch (e) {
      print('[WorkerSupervisionService] Error creating progress: $e');
      rethrow;
    }
  }

  /// Add feedback to progress report
  static Future<void> addFeedback({
    required WorkerProgress progress,
    required int managerId,
    required String managerName,
    required String feedbackText,
    required String rating,
  }) async {
    try {
      final feedback = WorkerFeedback(
        feedbackId: _nextFeedbackId++,
        progressId: progress.progressId!,
        managerId: managerId,
        managerName: managerName,
        feedbackText: feedbackText,
        rating: rating,
        createdAt: DateTime.now(),
      );

      final progressList = await getAllProgress();
      final index = progressList.indexWhere(
        (p) => p.progressId == progress.progressId,
      );

      if (index != -1) {
        final updatedFeedbacks = List<WorkerFeedback>.from(
          progressList[index].feedbacks,
        )..add(feedback);

        progressList[index] = WorkerProgress(
          progressId: progress.progressId,
          workerId: progress.workerId,
          workerName: progress.workerName,
          workerEmail: progress.workerEmail,
          batchId: progress.batchId,
          batchNumber: progress.batchNumber,
          date: progress.date,
          taskDescription: progress.taskDescription,
          hoursWorked: progress.hoursWorked,
          outputQuantity: progress.outputQuantity,
          unit: progress.unit,
          status: progress.status,
          notes: progress.notes,
          feedbacks: updatedFeedbacks,
          createdAt: progress.createdAt,
        );

        await _saveProgress(progressList);
        print('[WorkerSupervisionService] Feedback added');
      }
    } catch (e) {
      print('[WorkerSupervisionService] Error adding feedback: $e');
      rethrow;
    }
  }

  /// Save progress to storage
  static Future<void> _saveProgress(List<WorkerProgress> progressList) async {
    final data = json.encode(progressList.map((p) => p.toJson()).toList());
    await StorageService.saveData(_storageKey, data);
  }

  /// Clear all progress (for testing)
  static Future<void> clearAllProgress() async {
    await StorageService.removeData(_storageKey);
    _nextProgressId = 1;
    _nextFeedbackId = 1;
  }
}
