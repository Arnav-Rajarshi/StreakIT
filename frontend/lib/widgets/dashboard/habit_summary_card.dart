import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_models.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/utils/app_icons.dart';

/// Formats a duration in minutes as compact human-readable text.
/// Examples: `45m`, `1h`, `1h 15m`, `3h 40m`.
String formatDurationMinutes(num minutes) {
  final totalMinutes = minutes.round().clamp(0, 1 << 31);
  if (totalMinutes < 60) return '${totalMinutes}m';

  final hours = totalMinutes ~/ 60;
  final remainingMinutes = totalMinutes % 60;
  if (remainingMinutes == 0) return '${hours}h';
  return '${hours}h ${remainingMinutes}m';
}

class HabitSummarySection extends StatelessWidget {
  const HabitSummarySection({
    super.key,
    required this.summaryData,
  });

  final List<SummaryData> summaryData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Summary',
          style: TextStyle(
            color: theme.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Per-habit health summary cards',
          style: TextStyle(
            color: theme.mutedInk,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (summaryData.isEmpty)
          _EmptySummaryState(theme: theme)
        else
          ...summaryData.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitSummaryCard(summary: summary),
            ),
          ),
      ],
    );
  }
}

class HabitSummaryCard extends StatelessWidget {
  HabitSummaryCard({
    super.key,
    required SummaryData summary,
  })  : habitName = summary.habitName,
        accent = summary.color,
        icon = AppIcons.getIcon(summary.habitIcon),
        currStreakLabel = '${summary.currStreak}',
        bestStreakLabel = '${summary.bestStreak}',
        avgSessionLabel = formatDurationMinutes(summary.avgSessionDuration),
        totalSessionsLabel = '${summary.totalSessions}',
        weekLabel = formatDurationMinutes(summary.tdWeek),
        monthLabel = formatDurationMinutes(summary.tdMonth),
        overallLabel = formatDurationMinutes(summary.totalDuration);

  final String habitName;
  final Color accent;
  final IconData icon;
  final String currStreakLabel;
  final String bestStreakLabel;
  final String avgSessionLabel;
  final String totalSessionsLabel;
  final String weekLabel;
  final String monthLabel;
  final String overallLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return _SummaryGlassCard(
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryHeader(
              habitName: habitName,
              icon: icon,
              accent: accent,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _StatsGrid(
              theme: theme,
              accent: accent,
              items: [
                _StatItem(label: 'Current Streak', value: currStreakLabel),
                _StatItem(label: 'Best Streak', value: bestStreakLabel),
                _StatItem(label: 'Average Session', value: avgSessionLabel),
                _StatItem(label: 'Total Sessions', value: totalSessionsLabel),
              ],
            ),
            const SizedBox(height: 16),
            _TimeInvestedSection(
              theme: theme,
              accent: accent,
              weekLabel: weekLabel,
              monthLabel: monthLabel,
              overallLabel: overallLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.habitName,
    required this.icon,
    required this.accent,
    required this.theme,
  });

  final String habitName;
  final IconData icon;
  final Color accent;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: .28),
                accent.withValues(alpha: .10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.glassBorder),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            habitName,
            style: TextStyle(
              color: theme.ink,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.theme,
    required this.accent,
    required this.items,
  });

  final AppTheme theme;
  final Color accent;
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatTile(item: items[0], theme: theme, accent: accent)),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(item: items[1], theme: theme, accent: accent)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _StatTile(item: items[2], theme: theme, accent: accent)),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(item: items[3], theme: theme, accent: accent)),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.item,
    required this.theme,
    required this.accent,
  });

  final _StatItem item;
  final AppTheme theme;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.glassSurface.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
              color: theme.mutedInk,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeInvestedSection extends StatelessWidget {
  const _TimeInvestedSection({
    required this.theme,
    required this.accent,
    required this.weekLabel,
    required this.monthLabel,
    required this.overallLabel,
  });

  final AppTheme theme;
  final Color accent;
  final String weekLabel;
  final String monthLabel;
  final String overallLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Invested',
          style: TextStyle(
            color: theme.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.glassSurface.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.glassBorder),
          ),
          child: Column(
            children: [
              _TimeRow(label: 'Week', value: weekLabel, theme: theme, accent: accent),
              Divider(height: 1, color: theme.glassBorder),
              _TimeRow(label: 'Month', value: monthLabel, theme: theme, accent: accent),
              Divider(height: 1, color: theme.glassBorder),
              _TimeRow(label: 'Overall', value: overallLabel, theme: theme, accent: accent),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.accent,
  });

  final String label;
  final String value;
  final AppTheme theme;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.mutedInk,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGlassCard extends StatelessWidget {
  const _SummaryGlassCard({
    required this.child,
    required this.accent,
  });

  final Widget child;
  final Color accent;

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
                Color.lerp(theme.glassSurface, accent, 0.08)!.withValues(alpha: .96),
                theme.glassSurface.withValues(alpha: .78),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(theme.glassBorder, accent, 0.22)!.withValues(alpha: .86),
            ),
            boxShadow: [
              ...theme.softShadow,
              BoxShadow(
                color: accent.withValues(alpha: .14),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EmptySummaryState extends StatelessWidget {
  const _EmptySummaryState({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return _SummaryGlassCard(
      accent: theme.accent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.spa_rounded, color: theme.accent, size: 34),
            const SizedBox(height: 12),
            Text(
              'No habit summaries yet',
              style: TextStyle(
                color: theme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Summary cards will appear here once your habits have tracked activity.',
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
}
