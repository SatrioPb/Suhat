import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences_service.dart';

/// Mengelola pilihan mode tema (Terang, Gelap, Sistem) beserta penyimpanannya
class ThemeModeController extends StateNotifier<ThemeMode> {
  final PreferencesService _prefs;

  ThemeModeController(this._prefs) : super(_prefs.getThemeMode());

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setThemeMode(mode);
  }

  Future<void> toggleLightDark(Brightness currentBrightness) async {
    final next = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return ThemeModeController(prefs);
});

/// Mengelola target langkah harian secara reaktif agar Dashboard & Device tersinkronisasi
class DailyStepGoalController extends StateNotifier<int> {
  final PreferencesService _prefs;

  DailyStepGoalController(this._prefs)
      : super(_prefs.getDailyStepGoal() > 0
            ? _prefs.getDailyStepGoal()
            : AppConstants.defaultDailyStepGoal);

  Future<void> setGoal(int goal) async {
    state = goal;
    await _prefs.setDailyStepGoal(goal);
  }
}

final dailyStepGoalProvider =
    StateNotifierProvider<DailyStepGoalController, int>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return DailyStepGoalController(prefs);
});
