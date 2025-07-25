import 'package:flutter/material.dart';
import 'package:interlink/widgets/recruiter_bottom_nav.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: RecruiterBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}