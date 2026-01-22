import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flexplan/models/goal.dart';
import 'package:flexplan/models/micro_task.dart';
import 'package:flexplan/providers/goal_provider.dart';
import 'package:intl/intl.dart';

class GoalDetailsScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<GoalProvider>();

    // Find the actual goal from provider to get updated status
    final currentGoal = provider.goals.firstWhere(
      (g) => g.id == goal.id,
      orElse: () => goal,
    );

    return Scaffold(
      appBar: AppBar(title: Text(currentGoal.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: currentGoal.progress,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(currentGoal.progress * 100).toInt()}% Completed',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: currentGoal.tasks.length,
              itemBuilder: (context, index) {
                final task = currentGoal.tasks[index];
                final isDone = task.status == TaskStatus.done;

                return ListTile(
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (value) {
                      provider.toggleTask(
                        currentGoal.id,
                        task.id,
                        value ?? false,
                        'test_user_id',
                      );
                    },
                  ),
                  title: Text(
                    task.description,
                    style: TextStyle(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(DateFormat.yMMMd().format(task.scheduledDate)),
                  trailing: _getStatusIcon(task.status),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.missed:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.pending_actions, color: Colors.orange);
    }
  }
}
