import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexplan/models/goal.dart';
import 'package:flexplan/models/micro_task.dart';
import 'package:flexplan/models/user_stats.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveGoal(Goal goal) async {
    await _db.collection('goals').doc(goal.id).set(goal.toMap());
  }

  Stream<List<Goal>> getGoals(String userId) {
    return _db
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList(),
        );
  }

  Future<void> updateTaskStatus(
    String goalId,
    String taskId,
    TaskStatus status,
  ) async {
    final docRef = _db.collection('goals').doc(goalId);
    final doc = await docRef.get();

    if (doc.exists) {
      final goal = Goal.fromMap(doc.data()!);
      final taskIndex = goal.tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        goal.tasks[taskIndex].status = status;
        await docRef.update({
          'tasks': goal.tasks.map((t) => t.toMap()).toList(),
        });
      }
    }
  }

  Future<void> deleteGoal(String goalId) async {
    await _db.collection('goals').doc(goalId).delete();
  }

  Future<UserStats?> getUserStats(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserStats.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserStats(String userId, UserStats stats) async {
    await _db.collection('users').doc(userId).set(stats.toMap());
  }
}
