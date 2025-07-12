import 'package:flutter/material.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              const SizedBox(height: 20),

              // Greeting
              Text(
                "Hi, Pallab 👋",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ready to explore?",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Profile Completion Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Completion",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Complete your profile to get better matches",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3663F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Complete your profile"),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF3663F2),
                                ),
                              ),
                            ),
                            const Text("75%"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
                children: const [
                  _StatCard(
                    icon: Icons.search,
                    count: "24",
                    label: "Internships Matched",
                    iconColor: Colors.purple,
                  ),
                  _StatCard(
                    icon: Icons.description,
                    count: "8",
                    label: "Applications Sent",
                    iconColor: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.calendar_today,
                    count: "3",
                    label: "Interviews Scheduled",
                    iconColor: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.visibility,
                    count: "12",
                    label: "Profile Views",
                    iconColor: Colors.pink,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recommended for You
              const Text(
                "Recommended for You",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable Job Cards
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _JobCard(
                      company: "Google",
                      title: "UX Design Intern",
                      logo: Icons.g_mobiledata,
                      iconColor: Colors.redAccent,
                    ),
                    SizedBox(width: 12),
                    _JobCard(
                      company: "Microsoft",
                      title: "Product Intern",
                      logo: Icons.apps,
                      iconColor: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    _JobCard(
                      company: "Spotify",
                      title: "Frontend Intern",
                      logo: Icons.music_note,
                      iconColor: Colors.green,
                    ),
                    SizedBox(width: 12),
                    _JobCard(
                      company: "Meta",
                      title: "Design Intern",
                      logo: Icons.facebook,
                      iconColor: Colors.indigo,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Add Skills Tip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Add more skills to improve your match score!"),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Update Skills'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== Components ==========

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final IconData logo;
  final Color iconColor;

  const _JobCard({
    required this.title,
    required this.company,
    required this.logo,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // View label in top-right
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              "View",
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Logo and info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(logo, size: 32, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
