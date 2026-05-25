import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const _themeKey = 'theme_mode';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  FutureOr<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_themeKey, 'light');
      case ThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
      case ThemeMode.system:
        await prefs.setString(_themeKey, 'system');
    }
  }
}
