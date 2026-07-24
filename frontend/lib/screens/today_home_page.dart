import 'dart:ui';
import 'package:frontend/screens/create_habit_page.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/services/today_service.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/today_models.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/screens/dashboard_page.dart';

/// The authenticated landing page. Data is local mock state until API wiring.
class TodayHomePage extends StatefulWidget {
  const TodayHomePage({
    super.key,
    required this.uid,
    required this.username,
  });

  final String uid;
  final String username;

  @override
  State<TodayHomePage> createState() => _TodayHomePageState();
}


class _TodayHomePageState extends State<TodayHomePage> {
  int _selectedNavIndex = 0;
  bool _contentVisible = false;

  final TodayService _todayService = TodayService();

  List<TodayHabit> _habits = [];

  bool _isLoadingHabits = true;
  String? _habitLoadError;

  final _tasks = <TodayTask>[
    TodayTask(title: 'Review system design notes'),
    TodayTask(title: "Plan tomorrow's workout"),
  ];

  final _events = const <TodayEvent>[
    TodayEvent(time: '11:30 AM', title: 'Team stand-up'),
    TodayEvent(time: '6:00 PM', title: 'Evening walk'),
  ];

  Future<void> _loadHabits() async {
    try {
      print("Loading habits for ${widget.uid}");

      final habits = await _todayService.getTodayHabits(widget.uid);

      print("Received ${habits.length} habits");

      if (!mounted) return;

      setState(() {
        _habits = habits;
        _isLoadingHabits = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        _habitLoadError = e.toString();
        _isLoadingHabits = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadHabits();

    Future.microtask(() {
      if (mounted) {
        setState(() => _contentVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateHabitPage(
                username: widget.username,
                uid: widget.uid,
              ),
            ),
          );

          print("returned from create Habit page");

          if (created == true) {
            print("reloading habits");
            await _loadHabits();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Habit"),
        backgroundColor: theme.accent,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(gradient: theme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              HomeAppBar(username: widget.username),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth > 720 ? 680 : double.infinity),
                      child: AnimatedOpacity(
                        opacity: _contentVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: _isLoadingHabits ? const Center(child: CircularProgressIndicator(),)
                             : _habitLoadError != null ? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(24),
                                                              child: Text(
                                                                _habitLoadError!,
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          )
                              : _TodayContent(
                                      habits: _habits,
                                      tasks: _tasks,
                                      events: _events,
                                      onHabitComplete: _completeHabit,
                                      onTaskChanged: _toggleTask,
                                      onAddTask: _showTaskMessage,
                                      onAddEvent: _showEventMessage,
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
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onSelected: (index) async {
          if (index == _selectedNavIndex) return;

          switch (index) {
            case 0:
              break;

            case 2:
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardPage(
                    uid: widget.uid,
                    username: widget.username,
                  ),
                ),
              );
              return;

            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Calendar coming soon")),
              );
              break;

            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("More coming soon")),
              );
              break;
          }

          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  Future<void> _completeHabit(TodayHabit habit) async {
    if (habit.completed) return;
    final start = await showTimePicker(context: context,initialTime: TimeOfDay.now(), helpText: 'Select start time');
    if (!mounted || start == null) return;
    final end = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'Select end time');
    if (!mounted || end == null) return;

    final duration = _durationBetween(start, end);
    final shouldSave = await _showSessionConfirmation(habit, start, end, duration);
    if (!mounted || !shouldSave) return;

    final request = HabitLogRequest(
      habitId: habit.id,
      startedAt:
          "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00",
      endedAt:
          "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00",
      duration: duration.inMinutes,
    );
    await _todayService.logHabit(request);
    await _loadHabits();
  }

  Duration _durationBetween(TimeOfDay start, TimeOfDay end) {
    final startMinutes = (start.hour * 60) + start.minute;
    final endMinutes = (end.hour * 60) + end.minute;
    var minutes = endMinutes - startMinutes;
    if (minutes < 0) minutes += Duration.minutesPerDay;
    return Duration(minutes: minutes);
  }

  Future<bool> _showSessionConfirmation(TodayHabit habit, TimeOfDay start, TimeOfDay end, Duration duration) async {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: theme.glassSurface,
            title: Text('Save ${habit.name} session', style: TextStyle(color: theme.ink, fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SessionDetail(label: 'Start time', value: start.format(dialogContext)),
                _SessionDetail(label: 'End time', value: end.format(dialogContext)),
                _SessionDetail(label: 'Duration', value: _formatDuration(duration), emphasized: true),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
            ],
          ),
        ) ??
        false;
  }

  void _toggleTask(TodayTask task, bool completed) => setState(() => task.completed = completed);
  void _showTaskMessage() => _showMessage('Task creation will be available soon.');
  void _showEventMessage() => _showMessage('Event creation will be available soon.');
  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  String _formatDuration(Duration duration) => '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.habits,
    required this.tasks,
    required this.events,
    required this.onHabitComplete,
    required this.onTaskChanged,
    required this.onAddTask,
    required this.onAddEvent,
  });

  final List<TodayHabit> habits;
  final List<TodayTask> tasks;
  final List<TodayEvent> events;
  final ValueChanged<TodayHabit> onHabitComplete;
  final void Function(TodayTask, bool) onTaskChanged;
  final VoidCallback onAddTask;
  final VoidCallback onAddEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
      children: [
        const _SectionTitle(
          title: 'Current streaks',
          subtitle: 'Your consistency, in motion',
        ),
        const SizedBox(height: 12),
        _StreakList(habits: habits),
        const SizedBox(height: 28),
        const _SectionTitle(
          title: "Today's habits",
          subtitle: 'Small actions, lasting progress',
        ),
        const SizedBox(height: 12),

        // --- EMPTY STATE VS HABITS LIST ---
        if (habits.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "No habits scheduled for today ✨",
                  style: TextStyle(
                    color: theme.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        else
          ...habits.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                habit: habit,
                onComplete: () => onHabitComplete(habit),
              ),
            ),
          ),
        // ----------------------------------

        const SizedBox(height: 18),
        _SectionTitle(
          title: "Today's tasks",
          actionLabel: '+ Add Task',
          onAction: onAddTask,
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: tasks
                .asMap()
                .entries
                .map(
                  (entry) => TaskCard(
                    task: entry.value,
                    showDivider: entry.key < tasks.length - 1,
                    onChanged: (value) => onTaskChanged(entry.value, value),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 28),
        _SectionTitle(
          title: "Today's events",
          actionLabel: '+ Add Event',
          onAction: onAddEvent,
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: events
                .asMap()
                .entries
                .map(
                  (entry) => EventCard(
                    event: entry.value,
                    showDivider: entry.key < events.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.username});
  final String username;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 22) return 'Good Evening';
    return 'Hello';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_greeting, $username', style: TextStyle(color: theme.ink, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                const SizedBox(height: 4),
                Text('Your daily rhythm is looking strong ✨', style: TextStyle(color: theme.mutedInk, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Profile menu',
            offset: const Offset(0, 54),
            onSelected: (value) {
                if (value == "logout") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                        ),
                        (route) => false,
                    );
                }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'theme', child: Text('Theme')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.accent, theme.accent.withValues(alpha: .72)]),
                shape: BoxShape.circle,
                border: Border.all(color: theme.glassBorder, width: 1.8),
                boxShadow: [
                  ...theme.softShadow,
                  BoxShadow(color: const Color(0x33FFFFFF), blurRadius: 12, offset: const Offset(-4, -4)),
                ],
              ),
              child: Text(username.characters.first.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakList extends StatelessWidget {
  const _StreakList({
    required this.habits,
  });

  final List<TodayHabit> habits;

  @override
  Widget build(BuildContext context) {

    if (habits.isEmpty) {
      return const Center(
        child: Text("No habits yet"),
      );
    }

    return Column(
      children: [
        for (final habit in habits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HabitStreakBar(
              name: habit.name,
              days: habit.currentStreak,
              progress: habit.bestStreak == 0
                        ? 0
                        : (habit.currentStreak / habit.bestStreak).clamp(0.0, 1.0),
              color: habit.color,
              icon: habit.icon,
            ),
          ),
      ],
    );
  }
}

class HabitStreakBar extends StatelessWidget {
  const HabitStreakBar({super.key, required this.name, required this.icon, required this.days, required this.progress, required this.color});
  final String name;
  final IconData icon;
  final int days;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: TextStyle(color: theme.ink, fontSize: 12.5, fontWeight: FontWeight.w800))),
            SizedBox(width: 56, child: Text('$days Days', textAlign: TextAlign.end, style: TextStyle(color: theme.mutedInk, fontSize: 11.5, fontWeight: FontWeight.w800))),
          ],
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, constraints) => ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: color.withValues(alpha: .16)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: .75)]),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit, required this.onComplete});
  final TodayHabit habit;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    final details = habit.completed
    ? 'Completed today'
    : 'Target · ${habit.targetDuration} min';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onComplete,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 12, 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [theme.accent.withValues(alpha: .24), theme.accent.withValues(alpha: .08)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.glassBorder),
                  ),
                  child: Icon(habit.icon, color: theme.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: TextStyle(color: theme.ink, fontWeight: FontWeight.w800, fontSize: 15.5)),
                      const SizedBox(height: 4),
                      Text(details, style: TextStyle(color: theme.mutedInk, fontSize: 12.2, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: habit.completed ? theme.success.withValues(alpha: .14) : theme.glassSurface.withValues(alpha: .58),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: habit.completed ? theme.success.withValues(alpha: .24) : theme.glassBorder),
                      boxShadow: [BoxShadow(color: const Color(0x1C6B5B95), blurRadius: 10, offset: const Offset(0, 6))],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        key: ValueKey(habit.completed),
                        habit.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: habit.completed ? theme.success : theme.mutedInk,
                        size: 24,
                      ),
                    ),
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

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});
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
              colors: [theme.glassSurface.withValues(alpha: .96), theme.glassSurface.withValues(alpha: .78)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.glassBorder.withValues(alpha: .86)),
            boxShadow: [
              ...theme.softShadow,
              BoxShadow(color: const Color(0x15FFFFFF), blurRadius: 14, offset: const Offset(-4, -4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.showDivider, required this.onChanged});
  final TodayTask task;
  final bool showDivider;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CheckboxListTile(
            value: task.completed,
            onChanged: (value) => onChanged(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            activeColor: theme.success,
            title: Text(
              task.title,
              style: TextStyle(
                color: theme.ink,
                fontWeight: FontWeight.w600,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                decorationColor: theme.mutedInk,
                fontSize: 14.5,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 18, endIndent: 18, color: theme.glassBorder),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.showDivider});
  final TodayEvent event;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(event.time, style: TextStyle(color: theme.accent, fontSize: 11.8, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(event.title, style: TextStyle(color: theme.ink, fontWeight: FontWeight.w600, fontSize: 14.2))),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 18, endIndent: 18, color: theme.glassBorder),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle, this.actionLabel, this.onAction});
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: theme.ink, fontSize: 19.5, fontWeight: FontWeight.w800, letterSpacing: -.25)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: TextStyle(color: theme.mutedInk, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: TextStyle(color: theme.accent, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.label, required this.value, this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.mutedInk)),
          Text(value, style: TextStyle(color: emphasized ? theme.accent : theme.ink, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>()!;
    return Container(
      decoration: BoxDecoration(
        color: theme.glassSurface.withValues(alpha: .9),
        shape: BoxShape.circle,
        border: Border.all(color: theme.glassBorder),
        boxShadow: [
          BoxShadow(color: const Color(0x1C6B5B95), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(icon, color: theme.ink, size: 20),
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const _items = <(IconData, String)>[(Icons.home_rounded, 'Home'), (Icons.calendar_month_rounded, 'Calendar'), (Icons.bar_chart_rounded, 'Dashboard'), (Icons.menu_rounded, 'More')];

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
                  BoxShadow(color: const Color(0x15FFFFFF), blurRadius: 18, offset: const Offset(0, 10)),
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
                              style: TextStyle(color: active ? theme.accent : theme.mutedInk, fontSize: 10.5, fontWeight: active ? FontWeight.w800 : FontWeight.w600),
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
