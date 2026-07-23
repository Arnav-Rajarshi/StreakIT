import 'package:flutter/material.dart';
import 'package:frontend/models/habit_create_models.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/services/habitCreate_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/utils/app_icons.dart';
import 'package:frontend/utils/habit_colors.dart';

class CreateHabitPage extends StatefulWidget{
  
  const CreateHabitPage({super.key , required this.username , required this.uid});
  final String username;
  final String uid; 
  

  @override
  State<StatefulWidget> createState() {
    return _CreateHabitPageState();
  }
}

class _CreateHabitPageState extends State<CreateHabitPage>{ 

  final TextEditingController _habitNameController = TextEditingController();

  String _selectedIcon = "fire";
  
  Color _selectedColor = const Color(0xFFE53935);
  
  final Set<int> _selectedDays = {};

  double _targetDuration = 30;

  double _minimumDays = 5;

  double _allowedMisses = 1;
  
  static const List<String> _dayLabels = [
    "S",
    "M",
    "T",
    "W",
    "T",
    "F",
    "Sa",
  ];


  Widget _iconPicker(AppTheme theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _showIconPicker,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.getIcon(_selectedIcon),
              size: 22,
              color: theme.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedIcon
                    .replaceAll("-", " ")
                    .split(" ")
                    .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
                    .join(" "),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    final theme = Theme.of(context).extension<AppTheme>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .55,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Choose Icon",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),

              const Divider(height: 18),

              Expanded(
                child: GridView.builder(
                  itemCount: AppIcons.icons.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, index) {
                    final entry = AppIcons.icons.entries.elementAt(index);

                    final selected = entry.key == _selectedIcon;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedIcon = entry.key;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.accent.withValues(alpha:.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? theme.accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          size: 22,
                          color: selected
                              ? theme.accent
                              : Colors.grey.shade800,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorPicker(AppTheme theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _showColorPicker,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Selected Color",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .55,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Choose Color",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 18),

              Expanded(
                child: GridView.builder(
                  itemCount: HabitColors.habitColors.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, index) {
                    final color = HabitColors.habitColors[index];
                    final selected = color == _selectedColor;

                    return InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: selected ? 3 : 1,
                            color: selected
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _trackOnPicker(AppTheme theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(7, (index) {
        final selected = _selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? theme.accent
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? theme.accent
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              _dayLabels[index],
              style: TextStyle(
                color:
                    selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }


  Future<void> _createHabit() async {
      print("Calling creathabit API");

      final request = HabitCreateRequest(
          habitName: _habitNameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          trackOn: _selectedDays.toList()..sort(),
          targetDuration: _targetDuration.toInt(),
          minimumDays: _minimumDays.toInt(),
          allowedConsecutiveMisses:
              _allowedMisses.toInt(),
      );

      try {
            await HabitService.createHabit(widget.uid,request);
            print("POP NOW");
            if (!mounted) return;
            Navigator.pop(context,true);
          }
          catch (e) {
            debugPrint(e.toString());
          }
  }
  

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context).extension<AppTheme>()!;

    // --- CALCULATIONS FOR MINIMUM DAYS ---
    final double minDaysMax = _selectedDays.isEmpty ? 1.0 : _selectedDays.length.toDouble();
    final double minDaysMin = 1.0;
    // Ensure divisions is at least 1 so Flutter doesn't throw a division-by-zero error
    final int minDaysDivisions = (minDaysMax - minDaysMin).toInt().clamp(1, 7);

    // Safe current value (prevents crash if _minimumDays > minDaysMax)
    final double safeMinimumDays = _minimumDays.clamp(minDaysMin, minDaysMax);


    // --- CALCULATIONS FOR CONSECUTIVE MISSES ---
    final double missesMin = 0.0;
    // Max misses dynamically calculated based on selected days and minimum required days
    final double missesMax = (_selectedDays.isEmpty ? 7 : 7 - safeMinimumDays).toDouble();
    final int missesDivisions = (missesMax - missesMin).toInt().clamp(1, 7);

    // Safe current value (prevents crash if _allowedMisses > missesMax)
    final double safeAllowedMisses = _allowedMisses.clamp(missesMin, missesMax);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: theme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              CreateHabitAppBar(username: widget.username),
              Expanded(child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Habit Name
                      Text(
                        "Habit Name",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _habitNameController,
                        decoration: const InputDecoration(
                          hintText: "Morning Run",
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Choose Icon
                      Text(
                        "Choose Icon",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _iconPicker(theme),

                      const SizedBox(height: 18),

                      // Choose Color
                      Text(
                        "Choose Color",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _colorPicker(theme),

                      const SizedBox(height: 18),

                      // Track On
                      Text(
                        "Track On",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _trackOnPicker(theme),

                      const SizedBox(height: 20),

                      // Target Duration
                      Text(
                        "Target Duration",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${_targetDuration.toInt()} min",
                              style: TextStyle(
                                color: theme.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            Slider(
                              min: 5,
                              max: 655,
                              divisions: 130,
                              value: _targetDuration,
                              label: "${_targetDuration.toInt()} min",
                              onChanged: (value) {
                                setState(() {
                                  _targetDuration = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Minimum Days Per Week
                      Text(
                        "Minimum Days Per Week",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${safeMinimumDays.toInt()} days",
                              style: TextStyle(
                                color: theme.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            Slider(
                              min: minDaysMin,
                              max: minDaysMax,
                              divisions: minDaysDivisions,
                              value: safeMinimumDays,
                              label: "${safeMinimumDays.toInt()}",
                              onChanged: (value) {
                                setState(() {
                                  _minimumDays = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Allowed Consecutive Misses
                      Text(
                        "Allowed Consecutive Misses",
                        style: TextStyle(
                          color: theme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${safeAllowedMisses.toInt()} misses",
                              style: TextStyle(
                                color: theme.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            Slider(
                              min: missesMin,
                              max: missesMax,
                              divisions: missesDivisions,
                              value: safeAllowedMisses,
                              label: "${safeAllowedMisses.toInt()}",
                              onChanged: (value) {
                                setState(() {
                                  _allowedMisses = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _createHabit,
                          child: const Text(
                            "Create Habit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
               )
              )
            ],
          )
        )
      )
    );
  }

}

class CreateHabitAppBar extends StatelessWidget{
  
  const CreateHabitAppBar({super.key , required this.username});
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

    return Container(
      padding:const EdgeInsets.fromLTRB(20, 14, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting, $username', style: TextStyle(color: theme.ink, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                    const SizedBox(height: 4),
                    Text('We are excited that you are inculcating a NEW habit 🥳', style: TextStyle(color: theme.mutedInk, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
          ),

          SizedBox(width: 8),

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
          )
          
        ],
      ),
    );
  }
}

