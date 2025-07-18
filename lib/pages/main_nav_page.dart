import 'package:flutter/material.dart';
import 'package:interlink/widgets/custom_bottom_nav_bar.dart';
import 'dashboard_page.dart';
import 'internships_page.dart';
import 'tracker_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    InternshipListPage(),
    TrackerPage(),
    ProfilePage(),
  ];

  void _onNavTap(int index) {
    if (_currentIndex == index) return; // prevent rebuild if same tab tapped
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
