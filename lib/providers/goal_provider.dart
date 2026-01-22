import 'package:flutter/material.dart';
import 'package:flexplan/models/goal.dart';
import 'package:flexplan/models/micro_task.dart';
import 'package:flexplan/services/ai_service.dart';
import 'package:flexplan/services/database_service.dart';

import 'package:flexplan/models/user_stats.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService;

  List<Goal> _goals = [];
  UserStats _userStats = UserStats();
  bool _isLoading = false;

  GoalProvider(String aiApiKey) : _aiService = AIService(aiApiKey);

  List<Goal> get goals => _goals;
  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;

  void fetchGoals(String userId) {
    _dbService.getGoals(userId).listen((updatedGoals) {
      _goals = updatedGoals;
      notifyListeners();
    });
    fetchUserStats(userId);
  }

  Future<void> fetchUserStats(String userId) async {
    final stats = await _dbService.getUserStats(userId);
    if (stats != null) {
      _userStats = stats;
      notifyListeners();
    }
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required int durationDays,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tasks = await _aiService.generateTasks(
        title,
        description,
        durationDays,
      );
      final newGoal = Goal(
        title: title,
        description: description,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: durationDays)),
        tasks: tasks,
        userId: userId,
      );

      await _dbService.saveGoal(newGoal);
    } catch (e) {
      debugPrint('Error creating goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(
    String goalId,
    String taskId,
    bool isDone,
    String userId,
  ) async {
    final status = isDone ? TaskStatus.done : TaskStatus.pending;
    await _dbService.updateTaskStatus(goalId, taskId, status);

    if (isDone) {
      // Award XP
      int newXp = _userStats.xp + 10;
      int newLevel = _userStats.level;
      if (newXp >= _userStats.xpToNextLevel) {
        newXp -= _userStats.xpToNextLevel;
        newLevel++;
      }

      _userStats = UserStats(
        xp: newXp,
        level: newLevel,
        streak: _userStats.streak, // Add streak logic if needed
        lastCheckedIn: DateTime.now(),
      );

      await _dbService.updateUserStats(userId, _userStats);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    await _dbService.deleteGoal(goalId);
  }
}
