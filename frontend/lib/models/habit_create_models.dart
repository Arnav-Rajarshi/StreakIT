import 'package:flutter/material.dart';

class HabitCreateRequest {

  final String habitName;

  final String icon;

  final Color color;

  final List<int> trackOn;

  final int targetDuration;

  final int minimumDays;

  final int maximumConsecutiveMisses;

  const HabitCreateRequest({

    required this.habitName,

    required this.icon,

    required this.color,

    required this.trackOn,

    required this.targetDuration,

    required this.minimumDays,

    required this.maximumConsecutiveMisses,

  });

  Map<String, dynamic> toJson() {

    final hexColor =
        '#${color.toARGB32().toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}';

    return {

      "habit_name": habitName,

      "icon": icon,

      "color": hexColor,

      "track_on": trackOn,

      "minimum_days": minimumDays,

      "maximum_consecutive_misses":
          maximumConsecutiveMisses,

      "target_duration_per_session":
          targetDuration,

    };

  }

}