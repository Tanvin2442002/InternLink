import 'package:flutter/material.dart';
import 'recruiter_dashboard.dart';
import 'recruiter_post_job_page.dart';
import 'recruiter_candidates_page.dart';
import 'recruiter_profile_page.dart';

class RecruiterMainNavigationPage extends StatefulWidget {
  const RecruiterMainNavigationPage({super.key});

  @override
  State<RecruiterMainNavigationPage> createState() => _RecruiterMainNavigationPageState();
}

class _RecruiterMainNavigationPageState extends State<RecruiterMainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecruiterDashboardPage(onSwitchTab: _onNavTap),
      const RecruiterPostJobPage(),
      const RecruiterCandidatesPage(),
      const RecruiterProfilePage(),
    ];
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Post Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Candidates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}