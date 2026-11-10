import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhat/core/constants/app_constants.dart';
import 'package:suhat/data/local/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesService Tests', () {
    late PreferencesService prefsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getDailyStepGoal should return default value when not set', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      expect(prefsService.getDailyStepGoal(), AppConstants.defaultDailyStepGoal);
    });

    test('setDailyStepGoal should persist custom step goal', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      final success = await prefsService.setDailyStepGoal(12000);
      expect(success, isTrue);
      expect(prefsService.getDailyStepGoal(), 12000);
    });

    test('themeMode getter and setter persists light, dark, and system', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      expect(prefsService.getThemeMode(), ThemeMode.system);
      await prefsService.setThemeMode(ThemeMode.dark);
      expect(prefsService.getThemeMode(), ThemeMode.dark);
      await prefsService.setThemeMode(ThemeMode.light);
      expect(prefsService.getThemeMode(), ThemeMode.light);
    });

    test('runnerAge and weeklyRunTarget persist and clamp safely', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      expect(prefsService.getRunnerAge(), AppConstants.defaultRunnerAge);
      expect(prefsService.getWeeklyRunTarget(), AppConstants.defaultWeeklyRunTarget);

      await prefsService.setRunnerAge(34);
      await prefsService.setWeeklyRunTarget(3);

      expect(prefsService.getRunnerAge(), 34);
      expect(prefsService.getWeeklyRunTarget(), 3);
    });

    test('distanceUnit getter and setter works correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      expect(prefsService.getDistanceUnit(), 'kilometer');
      await prefsService.setDistanceUnit('mil');
      expect(prefsService.getDistanceUnit(), 'mil');
    });

    test('lastSyncTime getter and setter works correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);

      expect(prefsService.getLastSyncTime(), isNull);
      final now = DateTime(2026, 10, 16, 11, 45);
      await prefsService.setLastSyncTime(now);
      expect(prefsService.getLastSyncTime(), now);
    });
  });
}
