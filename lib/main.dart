import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/health_connect/presentation/screens/health_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const SuhatApp(),
    ),
  );
}

class SuhatApp extends StatelessWidget {
  const SuhatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supercalla Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HealthDashboardScreen(),
    );
  }
}
