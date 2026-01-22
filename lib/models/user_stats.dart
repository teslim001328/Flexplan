class UserStats {
  final int xp;
  final int level;
  final int streak;
  final DateTime? lastCheckedIn;

  UserStats({this.xp = 0, this.level = 1, this.streak = 0, this.lastCheckedIn});

  int get xpToNextLevel => level * 100;
  double get levelProgress => xp / xpToNextLevel;

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'streak': streak,
      'lastCheckedIn': lastCheckedIn?.toIso8601String(),
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      streak: map['streak'] ?? 0,
      lastCheckedIn: map['lastCheckedIn'] != null
          ? DateTime.parse(map['lastCheckedIn'])
          : null,
    );
  }
}
