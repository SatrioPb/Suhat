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
