import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    AppColors.isLightMode = false;
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      AppColors.isLightMode = false;
    } else {
      state = ThemeMode.light;
      AppColors.isLightMode = true;
    }
  }
}

final textSizeProvider = StateNotifierProvider<TextSizeNotifier, double>((ref) {
  return TextSizeNotifier();
});

class TextSizeNotifier extends StateNotifier<double> {
  TextSizeNotifier() : super(1.0);

  void setScale(double scale) {
    state = scale;
  }
}
