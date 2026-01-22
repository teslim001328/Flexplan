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
  String? _userId;

  GoalProvider(String aiApiKey) : _aiService = AIService(aiApiKey);

  List<Goal> get goals => _goals;
  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;

  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (_userId != null) {
        fetchInitialData();
      } else {
        _goals = [];
        _userStats = UserStats();
        notifyListeners();
      }
    }
  }

  void fetchInitialData() {
    if (_userId == null) return;

    _dbService.getGoals(_userId!).listen((updatedGoals) {
      _goals = updatedGoals;
      notifyListeners();
    });
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    if (_userId == null) return;
    final stats = await _dbService.getUserStats(_userId!);
    if (stats != null) {
      _userStats = stats;
      notifyListeners();
    }
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required int durationDays,
  }) async {
    if (_userId == null) return;
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
        userId: _userId!,
      );

      await _dbService.saveGoal(newGoal);
    } catch (e) {
      debugPrint('Error creating goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(String goalId, String taskId, bool isDone) async {
    if (_userId == null) return;
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

      // Streak logic
      int newStreak = _userStats.streak;
      final now = DateTime.now();
      final lastDate = _userStats.lastCheckedIn;

      if (lastDate == null) {
        newStreak = 1;
      } else {
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final currentDay = DateTime(now.year, now.month, now.day);
        final differenceInDays = currentDay.difference(lastDay).inDays;

        if (differenceInDays == 1) {
          newStreak++;
        } else if (differenceInDays > 1) {
          newStreak = 1;
        }
      }

      _userStats = UserStats(
        xp: newXp,
        level: newLevel,
        streak: newStreak,
        lastCheckedIn: now,
      );

      await _dbService.updateUserStats(_userId!, _userStats);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    await _dbService.deleteGoal(goalId);
  }
}
