import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_models.dart';
import 'package:frontend/theme/app_theme.dart';

class HabitHealthTrendSection extends StatelessWidget {
  const HabitHealthTrendSection({
    super.key,
    required this.dashboardPage,
  });

  final DashboardPageModel dashboardPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Health Trend',
          style: TextStyle(
            color: theme.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Consistency and momentum over time',
          style: TextStyle(
            color: theme.mutedInk,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        HabitHealthGraph(dashboardPage: dashboardPage),
      ],
    );
  }
}

class HabitHealthGraph extends StatefulWidget {
  const HabitHealthGraph({
    super.key,
    required this.dashboardPage,
  });

  final DashboardPageModel dashboardPage;

  @override
  State<HabitHealthGraph> createState() => _HabitHealthGraphState();
}

class _HabitHealthGraphState extends State<HabitHealthGraph> {
  late final Map<String, List<GraphData>> _groupedGraphData;
  late final Map<String, Color> _habitColors;

  @override
  void initState() {
    super.initState();
    _groupedGraphData = _buildGroupedGraphData(widget.dashboardPage.graphData);
    _habitColors = _buildHabitColors(
      widget.dashboardPage.summaryData,
      _groupedGraphData.keys.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    if (widget.dashboardPage.graphData.isEmpty) {
      return _DashboardGlassSection(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights_rounded, color: theme.accent, size: 34),
              const SizedBox(height: 12),
              Text(
                'No trend data yet',
                style: TextStyle(
                  color: theme.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your habit consistency trend will appear here once the backend publishes graph points.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.mutedInk,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _DashboardGlassSection(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: SizedBox(
          height: 280,
          child: LineChart(
            _lineChartData(theme),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  LineChartData _lineChartData(AppTheme theme) {
    final habitLines = _groupedGraphData.entries.map((entry) {
      final habitId = entry.key;
      final points = entry.value;
      final color = _habitColors[habitId] ?? _deterministicColor(habitId);

      return LineChartBarData(
        isCurved: true,
        curveSmoothness: 0.35,
        color: color,
        barWidth: 3,
        shadow: Shadow(
          color: color.withValues(alpha: .22),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3.5,
            color: color,
            strokeWidth: 2,
            strokeColor: theme.glassSurface,
          ),
        ),
        spots: points
            .map((point) => FlSpot(point.date.day.toDouble(), point.consistencyScore))
            .toList(),
      );
    }).toList();

    final maxDay = _groupedGraphData.values
        .expand((entries) => entries)
        .map((point) => point.date.day)
        .fold<int>(1, (current, next) => current > next ? current : next);

    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 100,
      minX: 1,
      maxX: maxDay.toDouble(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 16,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          tooltipBorder: BorderSide(color: theme.glassBorder),
          fitInsideHorizontally: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final habitId = _groupedGraphData.keys.toList()[touchedSpot.barIndex];
              final trend = _trendLabel(
                _groupedGraphData[habitId]![touchedSpot.spotIndex],
                touchedSpot.spotIndex > 0
                    ? _groupedGraphData[habitId]![touchedSpot.spotIndex - 1]
                    : null,
              );
              final point = _groupedGraphData[habitId]![touchedSpot.spotIndex];
              return LineTooltipItem(
                '${point.date.day}/${point.date.month} • ${point.consistencyScore.toStringAsFixed(0)}\nTrend: $trend',
                TextStyle(
                  color: theme.ink,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: TextStyle(
                color: theme.mutedInk,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 26,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: TextStyle(
                color: theme.mutedInk,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: habitLines,
    );
  }

  Map<String, List<GraphData>> _buildGroupedGraphData(List<GraphData> graphData) {
    final grouped = <String, List<GraphData>>{};

    for (final entry in graphData) {
      final list = grouped.putIfAbsent(entry.habitId, () => <GraphData>[]);
      list.add(entry);
    }

    for (final list in grouped.values) {
      list.sort((left, right) => left.date.compareTo(right.date));
    }

    return grouped;
  }

  Map<String, Color> _buildHabitColors(
    List<SummaryData> summaryData,
    List<String> habitIds,
  ) {
    final colors = <String, Color>{};

    for (var index = 0; index < habitIds.length; index++) {
      final habitId = habitIds[index];
      final summaryColor = summaryData.length > index
          ? summaryData[index].habitColor
          : null;

      colors[habitId] = summaryColor != null
          ? _hexToColor(summaryColor)
          : _deterministicColor(habitId);
    }

    return colors;
  }

  Color _hexToColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('0xFF$normalized'));
  }

  Color _deterministicColor(String habitId) {
    final hue = habitId.hashCode.abs() % 360;
    return HSVColor.fromAHSV(1, hue.toDouble(), 0.64, 0.72).toColor();
  }

  String _trendLabel(GraphData current, GraphData? previous) {
    if (previous == null) return 'Baseline';
    if (current.consistencyScore > previous.consistencyScore) return 'Improving';
    if (current.consistencyScore == previous.consistencyScore) return 'Stable';
    return 'Declining';
  }
}

class _DashboardGlassSection extends StatelessWidget {
  const _DashboardGlassSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.glassSurface.withValues(alpha: .96),
                theme.glassSurface.withValues(alpha: .78),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.glassBorder.withValues(alpha: .86)),
            boxShadow: [
              ...theme.softShadow,
              BoxShadow(
                color: const Color(0x15FFFFFF),
                blurRadius: 14,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
