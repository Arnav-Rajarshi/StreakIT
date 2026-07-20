import 'package:flutter/material.dart';

/// Theme tokens shared by StreakIT's gradient-first interface.
class AppTheme extends ThemeExtension<AppTheme> {
  final LinearGradient pageGradient;
  final Color ink;
  final Color mutedInk;
  final Color accent;
  final Color glassSurface;
  final Color glassBorder;
  final Color success;
  final List<BoxShadow> softShadow;

  const AppTheme({
    required this.pageGradient,
    required this.ink,
    required this.mutedInk,
    required this.accent,
    required this.glassSurface,
    required this.glassBorder,
    required this.success,
    required this.softShadow,
  });

  @override
  AppTheme copyWith({
    LinearGradient? pageGradient,
    Color? ink,
    Color? mutedInk,
    Color? accent,
    Color? glassSurface,
    Color? glassBorder,
    Color? success,
    List<BoxShadow>? softShadow,
  }) =>
      AppTheme(
        pageGradient: pageGradient ?? this.pageGradient,
        ink: ink ?? this.ink,
        mutedInk: mutedInk ?? this.mutedInk,
        accent: accent ?? this.accent,
        glassSurface: glassSurface ?? this.glassSurface,
        glassBorder: glassBorder ?? this.glassBorder,
        success: success ?? this.success,
        softShadow: softShadow ?? this.softShadow,
      );

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      pageGradient: LinearGradient.lerp(pageGradient, other.pageGradient, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      softShadow: BoxShadow.lerpList(softShadow, other.softShadow, t)!,
    );
  }
}

const appTheme = AppTheme(
  pageGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8E0F4), Color(0xFFF2E6E9), Color(0xFFF7EEF4)],
    stops: [0.0, 0.6, 1.0],
  ),
  ink: Color(0xFF403757),
  mutedInk: Color(0xFF716A85),
  accent: Color(0xFF6C5A91),
  glassSurface: Color(0xCCFFFFFF),
  glassBorder: Color(0x66FFFFFF),
  success: Color(0xFF4F9B73),
  softShadow: [
    BoxShadow(color: Color(0x256B5B95), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x15FFFFFF), blurRadius: 16, offset: Offset(-6, -6)),
  ],
);
