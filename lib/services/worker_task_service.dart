import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/worker_task_model.dart';
import '../utils/app_logger.dart';

/// Worker Task Service - Local storage for worker tasks
class WorkerTaskService {
  static const String _storageKey = 'worker_tasks';

  /// Get all tasks
  static Future<List<WorkerTask>> getAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_storageKey);

      if (tasksJson == null || tasksJson.isEmpty) {
        return [];
      }

      final List<dynamic> tasksList = json.decode(tasksJson);
      return tasksList.map((json) => WorkerTask.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading tasks', e.toString());
      return [];
    }
  }

  /// Get tasks by worker ID
  static Future<List<WorkerTask>> getTasksByWorkerId(int workerId) async {
    final tasks = await getAllTasks();
    return tasks.where((t) => t.workerId == workerId).toList();
  }

  /// Get today's tasks for worker
  static Future<List<WorkerTask>> getTodaysTasks(int workerId) async {
    final tasks = await getTasksByWorkerId(workerId);
    final today = DateTime.now();

    return tasks.where((t) {
      return t.assignedDate.year == today.year &&
          t.assignedDate.month == today.month &&
          t.assignedDate.day == today.day;
    }).toList();
  }

  /// Get tasks by status
  static Future<List<WorkerTask>> getTasksByStatus(
    int workerId,
    String status,
  ) async {
    final tasks = await getTasksByWorkerId(workerId);
    return tasks.where((t) => t.status == status).toList();
  }

  /// Create task
  static Future<bool> createTask(WorkerTask task) async {
    try {
      final tasks = await getAllTasks();

      final newTask = WorkerTask(
        taskId: tasks.isEmpty
            ? 1
            : (tasks.map((t) => t.taskId ?? 0).reduce((a, b) => a > b ? a : b) +
                  1),
        workerId: task.workerId,
        workerName: task.workerName,
        batchId: task.batchId,
        batchNumber: task.batchNumber,
        productName: task.productName,
        targetQuantity: task.targetQuantity,
        completedQuantity: task.completedQuantity,
        status: task.status,
        assignedDate: task.assignedDate,
        startedAt: task.startedAt,
        completedAt: task.completedAt,
        notes: task.notes,
      );

      tasks.add(newTask);

      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());

      await prefs.setString(_storageKey, tasksJson);

      AppLogger.success('Task created', task.productName);
      return true;
    } catch (e) {
      AppLogger.error('Error creating task', e.toString());
      return false;
    }
  }

  /// Update task
  static Future<bool> updateTask(WorkerTask task) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((t) => t.taskId == task.taskId);

      if (index == -1) {
        AppLogger.error('Task not found', task.taskId.toString());
        return false;
      }

      tasks[index] = task;

      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());

      await prefs.setString(_storageKey, tasksJson);

      AppLogger.success('Task updated', task.productName);
      return true;
    } catch (e) {
      AppLogger.error('Error updating task', e.toString());
      return false;
    }
  }

  /// Start task
  static Future<bool> startTask(int taskId) async {
    final tasks = await getAllTasks();
    final task = tasks.firstWhere((t) => t.taskId == taskId);

    final updatedTask = WorkerTask(
      taskId: task.taskId,
      workerId: task.workerId,
      workerName: task.workerName,
      batchId: task.batchId,
      batchNumber: task.batchNumber,
      productName: task.productName,
      targetQuantity: task.targetQuantity,
      completedQuantity: task.completedQuantity,
      status: 'in_progress',
      assignedDate: task.assignedDate,
      startedAt: DateTime.now(),
      completedAt: task.completedAt,
      notes: task.notes,
    );

    return updateTask(updatedTask);
  }

  /// Complete task
  static Future<bool> completeTask(
    int taskId,
    double completedQuantity,
    String? notes,
  ) async {
    final tasks = await getAllTasks();
    final task = tasks.firstWhere((t) => t.taskId == taskId);

    final updatedTask = WorkerTask(
      taskId: task.taskId,
      workerId: task.workerId,
      workerName: task.workerName,
      batchId: task.batchId,
      batchNumber: task.batchNumber,
      productName: task.productName,
      targetQuantity: task.targetQuantity,
      completedQuantity: completedQuantity,
      status: 'completed',
      assignedDate: task.assignedDate,
      startedAt: task.startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
      notes: notes,
    );

    return updateTask(updatedTask);
  }

  /// Get worker statistics
  static Future<Map<String, dynamic>> getWorkerStatistics(int workerId) async {
    final tasks = await getTasksByWorkerId(workerId);
    final today = DateTime.now();

    final todaysTasks = tasks.where((t) {
      return t.assignedDate.year == today.year &&
          t.assignedDate.month == today.month &&
          t.assignedDate.day == today.day;
    }).toList();

    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekTasks = tasks.where((t) {
      return t.assignedDate.isAfter(thisWeekStart);
    }).toList();

    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final totalOutput = completedTasks.fold<double>(
      0,
      (sum, t) => sum + (t.completedQuantity ?? 0),
    );

    return {
      'total_tasks': tasks.length,
      'today_tasks': todaysTasks.length,
      'today_completed': todaysTasks.where((t) => t.isCompleted).length,
      'week_tasks': weekTasks.length,
      'week_completed': weekTasks.where((t) => t.isCompleted).length,
      'total_completed': completedTasks.length,
      'total_output': totalOutput,
      'in_progress': tasks.where((t) => t.isInProgress).length,
    };
  }

  /// Initialize demo tasks for worker
  static Future<void> initializeDemoTasks(
    int workerId,
    String workerName,
  ) async {
    final tasks = await getTasksByWorkerId(workerId);
    if (tasks.isNotEmpty) return; // Already has tasks

    final today = DateTime.now();
    final demoTasks = [
      WorkerTask(
        workerId: workerId,
        workerName: workerName,
        batchId: 145,
        batchNumber: 'BATCH-145',
        productName: 'Coconut Shell Activated Carbon',
        targetQuantity: 100,
        completedQuantity: 100,
        status: 'completed',
        assignedDate: today,
        startedAt: today.subtract(const Duration(hours: 4)),
        completedAt: today.subtract(const Duration(hours: 1)),
        notes: 'Batch completed successfully',
      ),
      WorkerTask(
        workerId: workerId,
        workerName: workerName,
        batchId: 147,
        batchNumber: 'BATCH-147',
        productName: 'Rice Husk Activated Carbon',
        targetQuantity: 150,
        completedQuantity: 75,
        status: 'in_progress',
        assignedDate: today,
        startedAt: today.subtract(const Duration(hours: 2)),
        notes: 'Work in progress',
      ),
      WorkerTask(
        workerId: workerId,
        workerName: workerName,
        batchId: 148,
        batchNumber: 'BATCH-148',
        productName: 'Wood Chip Activated Carbon',
        targetQuantity: 120,
        status: 'not_started',
        assignedDate: today,
      ),
    ];

    for (var task in demoTasks) {
      await createTask(task);
    }
  }
}
