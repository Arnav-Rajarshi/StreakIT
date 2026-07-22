import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static const IconData defaultIcon = Icons.check_circle;

  static const Map<String, IconData> icons = {
    // =========================
    // Health & Wellness
    // =========================
    'book': Icons.menu_book,
    'fitness': Icons.fitness_center,
    'water': Icons.water_drop,
    'run': Icons.directions_run,
    'meditation': Icons.self_improvement,
    'sleep': Icons.bedtime,
    'food': Icons.restaurant,
    'walk': Icons.directions_walk,
    'bike': Icons.directions_bike,
    'swim': Icons.pool,

    // =========================
    // Productivity
    // =========================
    'study': Icons.school,
    'code': Icons.code,
    'work': Icons.work,
    'money': Icons.attach_money,
    'task': Icons.check_circle_outline,
    'calendar': Icons.calendar_month,
    'clock': Icons.schedule,
    'email': Icons.email,

    // =========================
    // Lifestyle
    // =========================
    'music': Icons.music_note,
    'guitar': Icons.music_note,
    'art': Icons.palette,
    'camera': Icons.photo_camera,
    'gaming': Icons.sports_esports,
    'journal': Icons.edit_note,
    'reading': Icons.chrome_reader_mode,
    'movie': Icons.movie,
    'travel': Icons.flight,

    // =========================
    // Misc
    // =========================
    'home': Icons.home,
    'car': Icons.directions_car,
    'shopping': Icons.shopping_cart,
    'phone': Icons.phone_android,
    'pet': Icons.pets,
    'plant': Icons.local_florist,
    'star': Icons.star,
    'heart': Icons.favorite,
    'check': Icons.check_circle,
    'target': Icons.track_changes,
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