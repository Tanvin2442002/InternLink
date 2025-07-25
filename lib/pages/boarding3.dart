import 'package:flutter/material.dart';

class Boarding3Page extends StatelessWidget {
  const Boarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5D5FEF), // top blue
              Color(0xFF7C5DF1), // mid
              Color(0xFF9A5CF2), // bottom purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Skip button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // Reduced from 24

                    // top image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=800&q=80',
                        width: 220, // Reduced from 260
                        height: 160, // Reduced from 200
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 220,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.work,
                              size: 60, // Reduced from 80
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24), // Reduced from 40

                    // title
                    const Text(
                      'Discover Amazing\nOpportunities!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26, // Reduced from 28
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12), // Reduced from 16

                    // subtitle
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Browse thousands of internships\nfrom top companies worldwide.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15, // Reduced from 16
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Reduced from 24

                    // Features list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.search,
                            title: 'Smart Search',
                            subtitle: 'Find internships that match your skills',
                          ),
                          const SizedBox(height: 12), // Reduced from 16
                          _buildFeatureItem(
                            icon: Icons.filter_list,
                            title: 'Advanced Filters',
                            subtitle: 'Filter by location, salary, and more',
                          ),
                          const SizedBox(height: 12), // Reduced from 16
                          _buildFeatureItem(
                            icon: Icons.star,
                            title: 'Top Companies',
                            subtitle: 'Access internships from Fortune 500',
                          ),
                        ],
                      ),
                    ),

                    const Expanded(child: SizedBox()), // Use Expanded instead of Spacer

                    // page indicators - boarding3 is active (3rd dot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(isActive: false), // boarding0
                        const SizedBox(width: 8),
                        _dot(isActive: false), // boarding1
                        const SizedBox(width: 8),
                        _dot(isActive: true), // boarding3 - ACTIVE
                        const SizedBox(width: 8),
                        _dot(isActive: false), // signup
                      ],
                    ),

                    const SizedBox(height: 24), // Reduced from 32

                    // Next button - goes to signup
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/boarding2'); // Go to signup (boarding2)
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Color(0xFF5D5FEF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32), // Reduced from 40
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10), // Reduced from 12
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22, // Reduced from 24
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15, // Reduced from 16
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13, // Reduced from 14
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // dot builder
  static Widget _dot({required bool isActive}) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}
