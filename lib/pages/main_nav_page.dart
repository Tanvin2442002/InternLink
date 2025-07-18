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
  bool isCvUploaded = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const InternshipListPage(),
      const ApplicationTrackerPage(),
      ProfilePage(
        onCvUploaded: () {
          // You can update state here if you want later
          setState(() {
            isCvUploaded = true;
          });
        },
      ),
    ];
  }

  void _onNavTap(int index) {
    // Temporarily disable CV restriction
    // if (!isCvUploaded && index != 3) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please upload your CV to continue"),
    //     ),
    //   );
    //   return;
    // }

    if (_currentIndex == index) return;
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
