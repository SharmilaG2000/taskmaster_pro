import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _filterCategory = 'All';

  List<Task> get tasks {
    if (_filterCategory == 'All') {
      return _tasks;
    }
    return _tasks.where((task) => task.category == _filterCategory).toList();
  }

  bool get isLoading => _isLoading;
  String get filterCategory => _filterCategory;

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();
  
  List<Task> get pendingTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  int get taskCount => _tasks.length;
  
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  void setFilter(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _firebaseService.getTasks();
    } catch (e) {
      print('Error fetching tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void listenToTasks() {
    _firebaseService.getTasksStream().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    try {
      await _firebaseService.addTask(task);
      _tasks.insert(0, task);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firebaseService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firebaseService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }
}
