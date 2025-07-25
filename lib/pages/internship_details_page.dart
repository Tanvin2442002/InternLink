import 'package:flutter/material.dart';
import 'application_form_page.dart';

class InternshipDetailsPage extends StatelessWidget {
  const InternshipDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Internship Details"),
        leading: const BackButton(),
        actions: const [Icon(Icons.bookmark_border)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://logo.clearbit.com/github.com",
                ),
                radius: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Frontend Developer Intern",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("TechVision Labs"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text("Remote")),
              Chip(label: Text("3 Months")),
              Chip(label: Text("\$300/month")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              InfoIcon(icon: Icons.person_outline, label: '124 Applied'),
              InfoIcon(icon: Icons.access_time, label: '2 days ago'),
              InfoIcon(icon: Icons.calendar_today, label: 'Jul 30, 2023'),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader("About TechVision Labs"),
          const Text(
            "TechVision Labs is a leading software development company specializing in AI-powered solutions...",
          ),
          const SizedBox(height: 16),
          const SectionHeader("Role Overview"),
          BulletList([
            "Work on frontend development using React",
            "Collaborate with senior developers",
            "Participate in code reviews",
            "Learn modern development practices",
          ]),
          const SectionHeader("Required Skills"),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text("HTML/CSS")),
              Chip(label: Text("JavaScript")),
              Chip(label: Text("React Basics")),
              Chip(label: Text("Git")),
              Chip(label: Text("Problem Solving")),
            ],
          ),
          const SectionHeader("Eligibility"),
          BulletList([
            "Currently pursuing Computer Science or related field",
            "Minimum GPA of 3.0",
            "Available for 3 months full-time",
          ]),
          const SectionHeader("Perks & Benefits"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              BenefitItem(icon: Icons.access_time, label: "Flexible Hours"),
              BenefitItem(icon: Icons.school, label: "Learning Resources"),
              BenefitItem(icon: Icons.verified, label: "Certificate"),
              BenefitItem(icon: Icons.group, label: "Mentorship"),
              BenefitItem(icon: Icons.trending_up, label: "Career Growth"),
              BenefitItem(
                icon: Icons.card_giftcard,
                label: "Performance Bonus",
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplicationFormPage(
                          internshipTitle: "Frontend Developer Intern",
                          companyName: "TechVision Labs",
                        ),
                      ),
                    );
                  },
                  child: const Text("Apply Now"),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text("Save for Later"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;
  const BulletList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item)),
              ],
            ),
          )
          .toList(),
    );
  }
}

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const BenefitItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
