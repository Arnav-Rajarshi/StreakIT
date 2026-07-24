import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_models.dart';
import 'package:frontend/screens/today_home_page.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/dashboard/habit_health_graph.dart';
import 'package:frontend/widgets/dashboard/habit_summary_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.uid,
    required this.username,
  });

  final String uid;
  final String username;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoadingDashboard = true;
  String? _dashboardLoadError;
  DashboardPageModel? _dashboardPage;
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard = await _dashboardService.getDashboard(widget.uid);

      if (!mounted) return;

      setState(() {
        _dashboardPage = dashboard;
        _isLoadingDashboard = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _dashboardLoadError = error.toString();
        _isLoadingDashboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: theme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              DashboardAppBar(
                username: widget.username,
                monthLabel: _monthLabel,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth > 720 ? 680 : double.infinity,
                      ),
                      child: _isLoadingDashboard
                          ? const Center(child: CircularProgressIndicator())
                          : _dashboardLoadError != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      _dashboardLoadError!,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const DashboardSectionPlaceholder(
                                        title: 'Monthly Heatmap',
                                        subtitle: 'Your habit consistency at a glance',
                                      ),
                                      const SizedBox(height: 18),
                                      HabitHealthTrendSection(
                                        dashboardPage: _dashboardPage!,
                                      ),
                                      const SizedBox(height: 18),
                                      HabitSummarySection(
                                        summaryData: _dashboardPage!.summaryData,
                                      )
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onSelected: (index) async {
          if (index == _selectedNavIndex) return;

          switch (index) {
            case 0:
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TodayHomePage(
                    uid: widget.uid,
                    username: widget.username,
                  ),
                ),
              );
              return;

            case 1:
              break;

            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Calendar coming soon")),
              );
              break;

            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile coming soon")),
              );
              break;
          }

          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  String get _monthLabel {
    final month = DateTime.now().month;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    required this.username,
    required this.monthLabel,
  });

  final String username;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.accent.withValues(alpha: .26),
                  theme.glassSurface.withValues(alpha: .92),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.glassBorder),
              boxShadow: [
                ...theme.softShadow,
                BoxShadow(
                  color: const Color(0x1AFFFFFF),
                  blurRadius: 18,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: theme.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, $username',
                        style: TextStyle(
                          color: theme.mutedInk,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        monthLabel,
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.glassSurface.withValues(alpha: .9),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1C6B5B95),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: theme.accent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardSectionPlaceholder extends StatelessWidget {
  const DashboardSectionPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.mutedInk,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.glassSurface.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.glassBorder),
              ),
              child: Center(
                child: Text(
                  'Placeholder section',
                  style: TextStyle(
                    color: theme.mutedInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSummaryPlaceholder extends StatelessWidget {
  const DashboardSummaryPlaceholder({
    super.key,
    required this.cardCount,
  });

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                cardCount > 0 ? cardCount : 4,
                (index) => SizedBox(
                  width: 150,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.glassSurface.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          color: theme.accent,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Summary card',
                          style: TextStyle(
                            color: theme.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            color: theme.mutedInk,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBottomNavigationBar extends StatelessWidget {
  const DashboardBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <(IconData, String)>[
    (Icons.home_rounded, 'Today'),
    (Icons.bar_chart_rounded, 'Dashboard'),
    (Icons.calendar_month_rounded, 'Calendar'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.glassSurface.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: theme.glassBorder),
                boxShadow: [
                  ...theme.softShadow,
                  BoxShadow(
                    color: const Color(0x15FFFFFF),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final active = index == selectedIndex;
                  final item = _items[index];
                  return Expanded(
                    child: InkWell(
                      onTap: () => onSelected(index),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                              decoration: BoxDecoration(
                                color: active ? theme.accent.withValues(alpha: .14) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(item.$1, color: active ? theme.accent : theme.mutedInk, size: 22),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: TextStyle(
                                color: active ? theme.accent : theme.mutedInk,
                                fontSize: 10.5,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                              ),
                              child: Text(item.$2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
