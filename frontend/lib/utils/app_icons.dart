import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static const IconData defaultIcon = Icons.check_circle;

  static const Map<String, IconData> icons = {
    // preset icon //
    "fire":Icons.local_fire_department,
    // ===== Existing Database Icons =====
    "stretch": Icons.accessibility_new,
    "code": Icons.code,
    "lotus-flower": Icons.spa,
    "book-open": Icons.menu_book,
    "dumbbell": Icons.fitness_center,
    "journal": Icons.edit_note,
    "language": Icons.language,
    "salad": Icons.restaurant,
    "running-shoe": Icons.directions_run,
    "moon": Icons.dark_mode,
    "meditation": Icons.self_improvement,
    "water-drop": Icons.water_drop,
    "guitar": Icons.music_note,
    "calendar": Icons.calendar_month,
    "wallet": Icons.account_balance_wallet,

    // ===== Health =====
    "walk": Icons.directions_walk,
    "bike": Icons.directions_bike,
    "swim": Icons.pool,
    "yoga": Icons.self_improvement,
    "heart": Icons.favorite,
    "sleep": Icons.bedtime,
    "medicine": Icons.medication,
    "apple": Icons.apple,
    "fitness": Icons.monitor_heart,
    "gym": Icons.sports_gymnastics,

    // ===== Study =====
    "study": Icons.school,
    "reading": Icons.chrome_reader_mode,
    "book": Icons.book,
    "science": Icons.science,
    "calculate": Icons.calculate,
    "quiz": Icons.quiz,
    "psychology": Icons.psychology,
    "terminal": Icons.terminal,
    "laptop": Icons.laptop,
    "computer": Icons.computer,

    // ===== Productivity =====
    "task": Icons.task_alt,
    "check": Icons.check_circle,
    "clock": Icons.schedule,
    "target": Icons.track_changes,
    "timer": Icons.timer,
    "flag": Icons.flag,
    "star": Icons.star,
    "rocket": Icons.rocket_launch,
    "lightbulb": Icons.lightbulb,
    "work": Icons.work,

    // ===== Lifestyle =====
    "camera": Icons.camera_alt,
    "movie": Icons.movie,
    "music": Icons.music_note,
    "travel": Icons.flight,
    "car": Icons.directions_car,
    "home": Icons.home,
    "shopping": Icons.shopping_cart,
    "phone": Icons.phone_android,
    "plant": Icons.local_florist,
    "pets": Icons.pets,

    // ===== Finance =====
    "money": Icons.attach_money,
    "credit-card": Icons.credit_card,
    "savings": Icons.savings,

    // ===== Food =====
    "coffee": Icons.coffee,
    "restaurant": Icons.restaurant,
    "cake": Icons.cake,

    // ===== Misc =====
    "email": Icons.email,
    "lock": Icons.lock,
    "bolt": Icons.bolt,
    "cloud": Icons.cloud,
    "sun": Icons.wb_sunny,
    "rain": Icons.umbrella,
  };

  /// Backend String -> Flutter Icon
  static IconData getIcon(String? iconName) {
    if (iconName == null) return defaultIcon;

    return icons[iconName.toLowerCase()] ?? defaultIcon;
  }

  /// Flutter Icon -> Backend String
  static String getName(IconData icon) {
    for (final entry in icons.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }

    return "check";
  }
}