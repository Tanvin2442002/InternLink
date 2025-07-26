import 'package:flutter/material.dart';

class Application {
  final String title;
  final String company;
  final String logo;
  final String date;
  final String status;
  final Color color;
  final String applicationId;
  final String position;
  final String salary;
  final String location;
  final String description;
  final List<String> requirements;
  final int daysAgo;

  Application({
    required this.title,
    required this.company,
    required this.logo,
    required this.date,
    required this.status,
    required this.color,
    required this.applicationId,
    required this.position,
    required this.salary,
    required this.location,
    required this.description,
    required this.requirements,
    required this.daysAgo,
  });
}

class ApplicationTrackerPage extends StatefulWidget {
  const ApplicationTrackerPage({super.key});

  @override
  State<ApplicationTrackerPage> createState() => _ApplicationTrackerPageState();
}

class _ApplicationTrackerPageState extends State<ApplicationTrackerPage> {
  String searchQuery = '';
  String selectedFilter = 'All';
  final List<String> filterOptions = [
    'All',
    'Under Review',
    'Interview Scheduled',
    'Rejected',
    'Phone Interview',
    'Technical Interview',
    'Applied',
  ];

  static final List<Application> applications = [
    Application(
      title: "Software Engineering Intern",
      company: "Google",
      logo: "https://logo.clearbit.com/google.com",
      date: "Dec 15, 2023",
      status: "Under Review",
      color: Colors.blue,
      applicationId: "APP001",
      position: "SWE Intern",
      salary: "\$85,000/year",
      location: "Mountain View, CA",
      description:
          "Join Google's world-class engineering team to build products that help billions of users connect, explore, and interact with information.",
      requirements: [
        "Computer Science degree",
        "Python/Java proficiency",
        "Data structures knowledge",
      ],
      daysAgo: 45,
    ),
    Application(
      title: "Product Design Intern",
      company: "Apple",
      logo: "https://logo.clearbit.com/apple.com",
      date: "Dec 12, 2023",
      status: "Interview Scheduled",
      color: Colors.purple,
      applicationId: "APP002",
      position: "Design Intern",
      salary: "\$75,000/year",
      location: "Cupertino, CA",
      description:
          "Create intuitive and beautiful user experiences for Apple's next generation of products used by millions worldwide.",
      requirements: [
        "Design portfolio",
        "Figma/Sketch proficiency",
        "User-centered design principles",
      ],
      daysAgo: 48,
    ),
    Application(
      title: "UX Research Intern",
      company: "Microsoft",
      logo: "https://logo.clearbit.com/microsoft.com",
      date: "Dec 10, 2023",
      status: "Selected",
      color: Colors.green,
      applicationId: "APP003",
      position: "UX Research Intern",
      salary: "\$70,000/year",
      location: "Redmond, WA",
      description:
          "Conduct user research to inform product decisions and improve user experiences across Microsoft's ecosystem of products.",
      requirements: [
        "Research methodology",
        "Data analysis",
        "Communication skills",
      ],
      daysAgo: 50,
    ),
    Application(
      title: "Frontend Developer Intern",
      company: "Meta",
      logo: "https://logo.clearbit.com/meta.com",
      date: "Dec 8, 2023",
      status: "Applied",
      color: Colors.grey,
      applicationId: "APP004",
      position: "Frontend Intern",
      salary: "\$80,000/year",
      location: "Menlo Park, CA",
      description:
          "Build responsive and scalable web applications that connect people around the world through Meta's family of apps.",
      requirements: ["React/JavaScript", "HTML/CSS", "Version control (Git)"],
      daysAgo: 52,
    ),
    Application(
      title: "Data Science Intern",
      company: "Amazon",
      logo: "https://logo.clearbit.com/amazon.com",
      date: "Dec 5, 2023",
      status: "Rejected",
      color: Colors.red,
      applicationId: "APP005",
      position: "Data Science Intern",
      salary: "\$90,000/year",
      location: "Seattle, WA",
      description:
          "Apply machine learning and statistical analysis to solve complex business problems and improve customer experiences.",
      requirements: ["Python/R", "Machine learning", "Statistics background"],
      daysAgo: 55,
    ),
    Application(
      title: "Mobile App Developer Intern",
      company: "Netflix",
      logo: "https://logo.clearbit.com/netflix.com",
      date: "Dec 3, 2023",
      status: "Phone Interview",
      color: Colors.orange,
      applicationId: "APP006",
      position: "Mobile Dev Intern",
      salary: "\$78,000/year",
      location: "Los Gatos, CA",
      description:
          "Develop innovative mobile experiences that help millions of users discover and enjoy entertainment content.",
      requirements: ["iOS/Android development", "Swift/Kotlin", "Mobile UI/UX"],
      daysAgo: 57,
    ),
    Application(
      title: "Backend Engineer Intern",
      company: "Spotify",
      logo: "https://logo.clearbit.com/spotify.com",
      date: "Nov 28, 2023",
      status: "Technical Interview",
      color: Colors.purple,
      applicationId: "APP007",
      position: "Backend Intern",
      salary: "\$82,000/year",
      location: "New York, NY",
      description:
          "Build scalable backend systems that power music streaming for over 400 million users worldwide.",
      requirements: ["Java/Python", "Distributed systems", "Database design"],
      daysAgo: 62,
    ),
    Application(
      title: "Cloud Infrastructure Intern",
      company: "Tesla",
      logo: "https://logo.clearbit.com/tesla.com",
      date: "Nov 25, 2023",
      status: "Applied",
      color: Colors.grey,
      applicationId: "APP008",
      position: "Cloud Intern",
      salary: "\$88,000/year",
      location: "Austin, TX",
      description:
          "Help build and maintain the cloud infrastructure that powers Tesla's autonomous vehicles and energy products.",
      requirements: ["AWS/Azure", "DevOps practices", "Linux systems"],
      daysAgo: 65,
    ),
  ];

  List<Application> get filteredApplications {
    List<Application> filtered = applications;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (app) =>
                app.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                app.company.toLowerCase().contains(searchQuery.toLowerCase()) ||
                app.position.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (selectedFilter != 'All') {
      filtered = filtered.where((app) => app.status == selectedFilter).toList();
    }

    return filtered;
  }

  void _showApplicationDetails(Application app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header with logo and company
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          app.logo,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.title,
                              style: const TextStyle(
                                fontSize: 18, // Reduced from 22
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2, // Allow 2 lines
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              app.company,
                              style: TextStyle(
                                fontSize: 14, // Reduced from 16
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: app.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          app.status,
                          style: TextStyle(
                            color: app.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Key details
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.attach_money,
                          label: 'Salary',
                          value: app.salary,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: app.location,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.calendar_today,
                          label: 'Applied',
                          value: '${app.daysAgo} days ago',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.badge,
                          label: 'ID',
                          value: app.applicationId,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Description
                  const Text(
                    'About the Role',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    app.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Requirements
                  const Text(
                    'Requirements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...app.requirements
                      .map(
                        (req) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: app.color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        const Text(
                          'Application Tracker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${filteredApplications.length} applications',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search applications...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterOptions.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF667eea),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF667eea)
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Applications list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final app = filteredApplications[index];
                return GestureDetector(
                  onTap: () => _showApplicationDetails(app),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo with hero animation
                            Hero(
                              tag: 'logo_${app.applicationId}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  app.logo,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.business,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Reduced from 18
                                    ),
                                    maxLines:
                                        2, // Allow 2 lines for long titles
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    app.company,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14, // Reduced from 16
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ), // Reduced icon size
                                      const SizedBox(width: 4),
                                      Expanded(
                                        // Make location expandable
                                        child: Text(
                                          app.location,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ), // Reduced font size
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Status pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: app.color.withOpacity(0.15),
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

                        const SizedBox(height: 16),

                        // Quick info row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildQuickInfo(
                                Icons.attach_money,
                                app.salary,
                                Colors.green,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildQuickInfo(
                                Icons.access_time,
                                '${app.daysAgo}d ago',
                                Colors.orange,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildQuickInfo(
                                Icons.badge,
                                app.applicationId,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Description preview
                        Text(
                          app.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Tap to view more
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                color: const Color(0xFF667eea),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: const Color(0xFF667eea),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: filteredApplications.length),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
