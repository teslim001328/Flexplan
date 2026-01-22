class GoalTemplate {
  final String title;
  final String description;
  final int defaultDurationDays;

  const GoalTemplate({
    required this.title,
    required this.description,
    required this.defaultDurationDays,
  });
}

class GoalTemplates {
  static const List<GoalTemplate> list = [
    GoalTemplate(
      title: 'Learn Flutter Basics',
      description:
          'Master widgets, state management, and navigation in one month.',
      defaultDurationDays: 30,
    ),
    GoalTemplate(
      title: 'Healthy Morning Routine',
      description:
          'Establish a consistent routine with exercise and meditation.',
      defaultDurationDays: 7,
    ),
    GoalTemplate(
      title: 'Read 3 Books',
      description: 'Finish three books on personal development or tech.',
      defaultDurationDays: 21,
    ),
    GoalTemplate(
      title: 'Daily Coding Practice',
      description:
          'Solve one algorithm problem or build a small feature daily.',
      defaultDurationDays: 14,
    ),
  ];
}
