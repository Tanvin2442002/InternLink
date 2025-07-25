import 'package:flutter/material.dart';

class RecruiterBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RecruiterBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "Post",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Candidates",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: "Profile",
        ),
      ],
    );
  }
}