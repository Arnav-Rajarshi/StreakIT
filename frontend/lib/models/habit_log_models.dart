class HabitLogRequest {
  final String habitId;
  final String startedAt;
  final String endedAt;
  final int duration;

  HabitLogRequest({
    required this.habitId,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        "habit_id": habitId,
        "started_at": startedAt,
        "ended_at": endedAt,
        "duration": duration,
      };
}