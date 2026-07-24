import 'package:flutter/material.dart';

/// ===========================================================================
/// GET /dashboard
/// Returned by FastAPI.
/// Mirror the backend DashboardPage contract exactly.
/// ===========================================================================
class DashboardPageModel {
  const DashboardPageModel({
    required this.heatmapData,
    required this.graphData,
    required this.summaryData,
  });

  final List<HeatmapData> heatmapData;
  final List<GraphData> graphData;
  final List<SummaryData> summaryData;

  factory DashboardPageModel.fromJson(Map<String, dynamic> json) {
    try {
      return DashboardPageModel(
        heatmapData: (json['HeatmapData'] as List<dynamic>? ?? [])
            .map((item) => HeatmapData.fromJson(item as Map<String, dynamic>))
            .toList(),
        graphData: (json['GraphData'] as List<dynamic>? ?? [])
            .map((item) => GraphData.fromJson(item as Map<String, dynamic>))
            .toList(),
        summaryData: (json['SummaryData'] as List<dynamic>? ?? [])
            .map((item) => SummaryData.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error, stackTrace) {
      print('=========== DashboardPageModel.fromJson ERROR ===========');
      print(json);
      print(error);
      print(stackTrace);
      rethrow;
    }
  }
}

class HeatmapData {
  const HeatmapData({
    required this.habitId,
    required this.date,
    required this.completed,
    required this.scheduled,
    required this.duration,
  });

  final String habitId;
  final DateTime date;
  final bool completed;
  final bool scheduled;
  final int duration;

  factory HeatmapData.fromJson(Map<String, dynamic> json) {
    return HeatmapData(
      habitId: json['habit_id'].toString(),
      date: DateTime.parse(json['date'].toString()),
      completed: json['completed'] as bool? ?? false,
      scheduled: json['scheduled'] as bool? ?? false,
      duration: json['duration'] as int? ?? 0,
    );
  }
}

class GraphData {
  const GraphData({
    required this.habitId,
    required this.date,
    required this.consistencyScore,
  });

  final String habitId;
  final DateTime date;
  final double consistencyScore;

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      habitId: json['habit_id'].toString(),
      date: DateTime.parse(json['date'].toString()),
      consistencyScore: (json['consistency_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SummaryData {
  const SummaryData({
    required this.habitName,
    required this.habitColor,
    required this.habitIcon,
    required this.currStreak,
    required this.bestStreak,
    required this.avgSessionDuration,
    required this.totalSessions,
    required this.totalDuration,
    required this.tdWeek,
    required this.tdMonth,
    required this.tdYear,
  });

  final String habitName;
  final String habitColor;
  final String habitIcon;
  final int currStreak;
  final int bestStreak;
  final double avgSessionDuration;
  final int totalSessions;
  final int totalDuration;
  final int tdWeek;
  final int tdMonth;
  final int tdYear;

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      habitName: json['HabitName']?.toString() ?? '',
      habitColor: json['HabitColor']?.toString() ?? '#6C5A91',
      habitIcon: json['HabitIcon']?.toString() ?? 'check',
      currStreak: json['curr_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      avgSessionDuration: (json['avg_session_duration'] as num?)?.toDouble() ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      tdWeek: json['td_week'] as int? ?? 0,
      tdMonth: json['td_month'] as int? ?? 0,
      tdYear: json['td_year'] as int? ?? 0,
    );
  }

  Color get color => _hexToColor(habitColor);

  static Color _hexToColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('0xFF$normalized'));
  }
}
