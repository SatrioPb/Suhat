import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/analytics/pages/analytics_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/device/pages/device_page.dart';
import '../features/history/pages/history_page.dart';
import '../features/running_coach/pages/running_coach_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.suhatColors;
    final pages = [
      DashboardPage(onNavigateTab: _navigateToTab),
      const AnalyticsPage(),
      const RunningCoachPage(),
      const HistoryPage(),
      const DevicePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.hairline, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToTab,
          backgroundColor: c.surfaceElevated,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Analisis',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_run_outlined),
              selectedIcon: Icon(Icons.directions_run),
              label: 'Pelatih Lari',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.watch_outlined),
              selectedIcon: Icon(Icons.watch),
              label: 'Perangkat',
            ),
          ],
        ),
      ),
    );
  }
}
