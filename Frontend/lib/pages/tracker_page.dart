import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

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
  final String jobId;
  final DateTime submittedAt;

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
    required this.jobId,
    required this.submittedAt,
  });

  // Factory method to create Application from API response
  factory Application.fromApi(Map<String, dynamic> data) {
    // Parse requirements from JSON array or comma-separated string
    List<String> requirements = [];
    if (data['requirements'] != null) {
      if (data['requirements'] is List) {
        requirements = List<String>.from(data['requirements']);
      } else if (data['requirements'] is String) {
        try {
          final parsed = jsonDecode(data['requirements']);
          if (parsed is List) {
            requirements = List<String>.from(parsed);
          }
        } catch (_) {
          requirements = data['requirements'].toString().split(',').map((e) => e.trim()).toList();
        }
      }
    }

    // Status color mapping
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
        case 'applied':
          return Colors.grey;
        case 'under review':
        case 'reviewing':
          return Colors.blue;
        case 'interview scheduled':
        case 'phone interview':
        case 'technical interview':
          return Colors.orange;
        case 'selected':
        case 'hired':
        case 'accepted':
          return Colors.green;
        case 'rejected':
        case 'declined':
          return Colors.red;
        default:
          return Colors.purple;
      }
    }

    return Application(
      title: data['title']?.toString() ?? 'Unknown Position',
      company: data['company']?.toString() ?? 'Unknown Company',
      logo: data['logo']?.toString() ?? '',
      date: data['date']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      color: getStatusColor(data['status']?.toString() ?? 'pending'),
      applicationId: data['applicationid']?.toString() ?? '',
      position: data['position']?.toString() ?? 'Internship',
      salary: data['salary']?.toString() ?? 'Not specified',
      location: data['location']?.toString() ?? 'Not specified',
      description: data['description']?.toString() ?? 'No description available',
      requirements: requirements,
      daysAgo: data['daysago']?.toInt() ?? 0,
      jobId: data['jobid']?.toString() ?? '',
      submittedAt: DateTime.tryParse(data['submittedat']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ApplicationTrackerPage extends StatefulWidget {
  const ApplicationTrackerPage({super.key});

  @override
  State<ApplicationTrackerPage> createState() => _ApplicationTrackerPageState();
}

class _ApplicationTrackerPageState extends State<ApplicationTrackerPage> {
  String searchQuery = '';
  String selectedFilter = 'All';
  List<Application> applications = [];
  bool isLoading = true;
  String? errorMessage;

  final List<String> filterOptions = [
    'All',
    'pending',
    'under review', 
    'interview scheduled',
    'selected',
    'rejected',
    'phone interview',
    'technical interview',
    'applied',
  ];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get applicant_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? profile;
      try {
        final p = prefs.getString('profile_data');
        if (p != null) profile = jsonDecode(p);
      } catch (_) {}

      final applicantId = profile?['applicant_id']?.toString();
      if (applicantId == null || applicantId.isEmpty) {
        setState(() {
          errorMessage = 'Applicant ID not found. Please log in again.';
          isLoading = false;
        });
        return;
      }

      // Call the API
      final result = await ApiService.getApplications(applicantId);
      
      if (result['success'] == true && result['applications'] != null) {
        final List<dynamic> apiApplications = result['applications'];
        setState(() {
          applications = apiApplications
              .map((app) => Application.fromApi(app as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to fetch applications';
          isLoading = false;
          applications = [];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
        applications = [];
      });
    }
  }

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
      filtered = filtered.where((app) => app.status.toLowerCase() == selectedFilter.toLowerCase()).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchApplications,
        child: CustomScrollView(
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
                            isLoading 
                                ? 'Loading applications...'
                                : '${filteredApplications.length} applications',
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

            // Filter chips (only show if not loading)
            if (!isLoading)
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

            // Content area
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchApplications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredApplications.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty || selectedFilter != 'All'
                            ? 'No applications match your filter'
                            : 'No applications yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      if (searchQuery.isNotEmpty || selectedFilter != 'All') ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              selectedFilter = 'All';
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              // Applications list (your existing SliverPadding with list remains the same)
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
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        app.company,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
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
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              app.location,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
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
      ),
    );
  }
}
