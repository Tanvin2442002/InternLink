import 'package:flutter/material.dart';
import 'internship_details_page.dart';

class InternshipListPage extends StatelessWidget {
  const InternshipListPage({super.key});

  final internships = const [
    {
      'company': 'TechCorp',
      'role': 'Frontend Development Intern',
      'location': 'San Francisco, CA',
      'duration': '3 months',
      'stipend': '\$3,000/month',
      'skills': ['React', 'TypeScript', 'Figma'],
      'image': 'https://logo.clearbit.com/techcrunch.com',
    },
    {
      'company': 'DesignHub',
      'role': 'UI/UX Design Intern',
      'location': 'Remote',
      'duration': '6 months',
      'stipend': '\$2,500/month',
      'skills': ['Figma', 'Adobe XD', 'Prototyping'],
      'image': 'https://logo.clearbit.com/dribbble.com',
    },
    {
      'company': 'DataTech',
      'role': 'Data Science Intern',
      'location': 'New York, NY',
      'duration': '4 months',
      'stipend': '\$3,500/month',
      'skills': ['Python', 'Machine Learning', 'SQL'],
      'image': 'https://logo.clearbit.com/github.com',
    },
    {
      'company': 'CloudSys',
      'role': 'Cloud Engineering Intern',
      'location': 'Seattle, WA',
      'duration': '3 months',
      'stipend': '\$4,000/month',
      'skills': ['AWS', 'Docker', 'Kubernetes'],
      'image': 'https://logo.clearbit.com/docker.com',
    },
    {
      'company': 'MobileDev',
      'role': 'Mobile Development Intern',
      'location': 'Austin, TX',
      'duration': '6 months',
      'stipend': '\$3,200/month',
      'skills': ['React Native', 'iOS', 'Android'],
      'image': 'https://logo.clearbit.com/apple.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InternLink"),
        actions: const [Icon(Icons.grid_view_rounded)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search internships...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.filter_list),
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...internships.map((data) => InternshipCard(data: data)).toList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Internships',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class InternshipCard extends StatelessWidget {
  final Map data;
  const InternshipCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(data['image']),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['company'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data['role'], style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Text(data['location']),
                const SizedBox(width: 16),
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 4),
                Text(data['duration']),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: data['skills']
                  .map<Widget>((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['stipend'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // button background
                    foregroundColor: Colors.white, // text/icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InternshipDetailsPage(),
                      ),
                    );
                  },
                  child: const Text("View Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
