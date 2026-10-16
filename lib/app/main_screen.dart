import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/analytics/pages/analytics_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/device/pages/device_page.dart';
import '../features/history/pages/history_page.dart';

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
    final pages = [
      DashboardPage(onNavigateTab: _navigateToTab),
      const AnalyticsPage(),
      const HistoryPage(),
      const DevicePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryTeal.withOpacity(0.15),
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryTeal),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: AppTheme.primaryTeal),
            label: 'Analisis',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primaryTeal),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch, color: AppTheme.primaryTeal),
            label: 'Perangkat',
          ),
        ],
      ),
    );
  }
}
