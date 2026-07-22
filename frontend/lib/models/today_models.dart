import 'package:flutter/material.dart';

import '../utils/app_icons.dart';

/// ===========================================================================
/// GET /today
/// Returned by FastAPI.
/// Used ONLY for displaying today's habits.
/// ===========================================================================
class TodayHabit {
  const TodayHabit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetDuration,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSessions,
    required this.totalDuration,
    required this.completed,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  /// Minutes
  final int targetDuration;

  final int currentStreak;
  final int bestStreak;
  final int totalSessions;

  /// Minutes
  final int totalDuration;

  final bool completed;

  factory TodayHabit.fromJson(Map<String, dynamic> json) {
    try {
      final config = json["config"];
      final cache = json["cache"];

      return TodayHabit(
        id: config["hid"].toString(),
        name: config["habit_name"],
        icon: AppIcons.getIcon(config["icon"]),
        color: _hexToColor(config["color"]),
        targetDuration: config["target_duration_per_session"],
        currentStreak: cache["current_streak"],
        bestStreak: cache["best_streak"],
        totalSessions: cache["total_sessions"],
        totalDuration: cache["total_duration"],
        completed: json["completed"],
      );
    } catch (e, stackTrace) {
      print("=========== TodayHabit.fromJson ERROR ===========");
      print(json);
      print(e);
      print(stackTrace);
      rethrow;
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceFirst("#", "");

    return Color(
      int.parse("0xFF$hex"),
    );
  }
}

/// ===========================================================================
/// POST /habit/log
/// Sent from Flutter when user completes a habit.
/// ===========================================================================
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

/// ===========================================================================
/// Mock Models
/// Keep these until backend is connected.
/// ===========================================================================
class TodayTask {
  TodayTask({
    required this.title,
    this.completed = false,
  });

  final String title;
  bool completed;
}

class TodayEvent {
  const TodayEvent({
    required this.time,
    required this.title,
  });

  final String time;
  final String title;
}