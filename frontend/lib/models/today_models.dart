import 'package:flutter/material.dart';

class TodayHabit {
  TodayHabit({
    required this.name,
    required this.icon,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.completed = false,
    this.startTime,
    this.endTime,
    this.sessionDuration,
  });

  final String name;
  final IconData icon;
  final TimeOfDay scheduledStart;
  final TimeOfDay scheduledEnd;
  bool completed;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Duration? sessionDuration;
}

class TodayTask {
  TodayTask({required this.title, this.completed = false});

  final String title;
  bool completed;
}

class TodayEvent {
  const TodayEvent({required this.time, required this.title});

  final String time;
  final String title;
}
