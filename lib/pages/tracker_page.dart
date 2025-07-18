import 'package:flutter/material.dart';

class Application {
  final String title;
  final String company;
  final String logo;
  final String date;
  final String status;
  final Color color;

  Application({
    required this.title,
    required this.company,
    required this.logo,
    required this.date,
    required this.status,
    required this.color,
  });
}

class ApplicationTrackerPage extends StatelessWidget {
  const ApplicationTrackerPage({super.key});

  static final List<Application> applications = [
    Application(
      title: "Software Engineering Intern",
      company: "Google",
      logo: "https://logo.clearbit.com/google.com",
      date: "Dec 15, 2023",
      status: "Under Review",
      color: Colors.blue,
    ),
    Application(
      title: "Product Design Intern",
      company: "Apple",
      logo: "https://logo.clearbit.com/apple.com",
      date: "Dec 12, 2023",
      status: "Interview Scheduled",
      color: Colors.purple,
    ),
    Application(
      title: "UX Research Intern",
      company: "Microsoft",
      logo: "https://logo.clearbit.com/microsoft.com",
      date: "Dec 10, 2023",
      status: "Selected",
      color: Colors.green,
    ),
    Application(
      title: "Frontend Developer Intern",
      company: "Meta",
      logo: "https://logo.clearbit.com/meta.com",
      date: "Dec 8, 2023",
      status: "Applied",
      color: Colors.grey,
    ),
    Application(
      title: "Data Science Intern",
      company: "Amazon",
      logo: "https://logo.clearbit.com/amazon.com",
      date: "Dec 5, 2023",
      status: "Rejected",
      color: Colors.red,
    ),
    Application(
      title: "Mobile App Developer Intern",
      company: "Netflix",
      logo: "https://logo.clearbit.com/netflix.com",
      date: "Dec 3, 2023",
      status: "Phone Interview",
      color: Colors.orange,
    ),
    Application(
      title: "Backend Engineer Intern",
      company: "Spotify",
      logo: "https://logo.clearbit.com/spotify.com",
      date: "Nov 28, 2023",
      status: "Technical Interview",
      color: Colors.purple,
    ),
    Application(
      title: "Cloud Infrastructure Intern",
      company: "Tesla",
      logo: "https://logo.clearbit.com/tesla.com",
      date: "Nov 25, 2023",
      status: "Applied",
      color: Colors.grey,
    ),
    Application(
      title: "AI/ML Engineer Intern",
      company: "OpenAI",
      logo: "https://logo.clearbit.com/openai.com",
      date: "Nov 22, 2023",
      status: "Under Review",
      color: Colors.blue,
    ),
    Application(
      title: "DevOps Intern",
      company: "Adobe",
      logo: "https://logo.clearbit.com/adobe.com",
      date: "Nov 20, 2023",
      status: "Final Interview",
      color: Colors.deepPurple,
    ),
    Application(
      title: "Cybersecurity Intern",
      company: "IBM",
      logo: "https://logo.clearbit.com/ibm.com",
      date: "Nov 18, 2023",
      status: "Rejected",
      color: Colors.red,
    ),
    Application(
      title: "Full Stack Developer Intern",
      company: "Stripe",
      logo: "https://logo.clearbit.com/stripe.com",
      date: "Nov 15, 2023",
      status: "Offer Extended",
      color: Colors.green,
    ),
    Application(
      title: "Product Manager Intern",
      company: "Slack",
      logo: "https://logo.clearbit.com/slack.com",
      date: "Nov 12, 2023",
      status: "Applied",
      color: Colors.grey,
    ),
    Application(
      title: "Data Analyst Intern",
      company: "Uber",
      logo: "https://logo.clearbit.com/uber.com",
      date: "Nov 10, 2023",
      status: "Phone Screen",
      color: Colors.orange,
    ),
    Application(
      title: "QA Engineer Intern",
      company: "Airbnb",
      logo: "https://logo.clearbit.com/airbnb.com",
      date: "Nov 8, 2023",
      status: "Under Review",
      color: Colors.blue,
    ),
    Application(
      title: "Game Developer Intern",
      company: "Unity",
      logo: "https://logo.clearbit.com/unity.com",
      date: "Nov 5, 2023",
      status: "Coding Challenge",
      color: Colors.indigo,
    ),
    Application(
      title: "Marketing Tech Intern",
      company: "HubSpot",
      logo: "https://logo.clearbit.com/hubspot.com",
      date: "Nov 3, 2023",
      status: "Applied",
      color: Colors.grey,
    ),
    Application(
      title: "Blockchain Developer Intern",
      company: "Coinbase",
      logo: "https://logo.clearbit.com/coinbase.com",
      date: "Nov 1, 2023",
      status: "Rejected",
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Application Tracker",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.filter_list, color: Colors.black),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: applications.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final app = applications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    app.logo,
                    height: 48,
                    width: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 48,
                        width: 48,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        app.company,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Applied on ${app.date}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: app.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status,
                    style: TextStyle(
                      color: app.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
