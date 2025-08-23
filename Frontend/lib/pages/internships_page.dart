import 'dart:convert'; // for jsonDecode
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'internship_details_page.dart';

class InternshipListPage extends StatefulWidget {
  const InternshipListPage({super.key});

  @override
  State<InternshipListPage> createState() => _InternshipListPageState();
}

class _InternshipListPageState extends State<InternshipListPage> {
  List<Map<String, dynamic>> _internships = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.getAllJobsWithStoredApplicant();
    if (!mounted) return;

    if (result['success'] == true) {
      final jobs = (result['jobs'] as List)
          .map<Map<String, dynamic>>((j) => _normalizeJob(j as Map<String, dynamic>))
          .toList();
      setState(() {
        _internships = jobs;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message']?.toString() ?? 'Failed to fetch jobs';
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _normalizeJob(Map<String, dynamic> j) {
    // Normalize backend fields to the UI keys used by the card
    final skillsRaw = j['required_skills'];
    List<String> skills;
    if (skillsRaw is List) {
      skills = skillsRaw.map((e) => e.toString()).toList();
    } else if (skillsRaw is String) {
      // try JSON array, else comma-separated
      try {
        final parsed = (jsonDecode(skillsRaw) as List).map((e) => e.toString()).toList();
        skills = parsed;
      } catch (_) {
        skills = skillsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } else {
      skills = [];
    }

    String duration = '';
    if (j['duration_months'] != null) {
      final d = j['duration_months'];
      duration = d is num ? '${d.toInt()} months' : d.toString();
    }

    String stipend = '';
    if (j['stipend'] != null) {
      final s = j['stipend'];
      stipend = s is num ? '\$${s.toStringAsFixed(0)}/month' : s.toString();
    }

    return {
      // UI fields for card
      'company_name': j['company_name'] ?? j['company'] ?? 'Unknown Company',
      'title': j['title'] ?? j['position_title'] ?? 'Internship',
      'location': j['location'] ?? (j['employment_type'] ?? 'Remote'),
      'duration_months': duration.isNotEmpty ? duration : (j['duration']?.toString() ?? 'N/A'),
      'stipend': stipend.isNotEmpty ? stipend : (j['salary']?.toString() ?? 'N/A'),
      'required_skills': skills,
      'company_logo_url': j['company_logo_url'] ?? j['logo_url'] ?? '',
      // keep identifiers and the raw backend job so details page gets everything
      'id': j['id'],
      '_raw': j,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? RefreshIndicator(
                  onRefresh: _fetchJobs,
                  child: ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.work_outline, size: 56, color: Colors.grey[500]),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _fetchJobs,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
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
                                    'Discover Internships',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_internships.length} opportunities available',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search internships...',
                                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                                        suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Featured Opportunities',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return InternshipCard(data: _internships[index]);
                          },
                          childCount: _internships.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
    );
  }
}

class InternshipCard extends StatelessWidget {
  final Map<String, dynamic> data; // normalized + _raw
  const InternshipCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final Map<String, dynamic> job =
                (data['_raw'] is Map<String, dynamic>) ? data['_raw'] as Map<String, dynamic> : data;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InternshipDetailsPage(job: job), // pass full raw job (with id)
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'company_${data['company_name']}_${data['title']}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: (data['company_logo_url'] as String).isNotEmpty
                              ? Image.network(
                                  data['company_logo_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.business, color: Colors.grey, size: 30),
                                    );
                                  },
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.business, color: Colors.grey, size: 30),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['company_name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['title'],
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.location_on_outlined,
                        text: data['location'],
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.schedule_outlined,
                        text: data['duration_months'],
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (data['required_skills'] as List)
                      .map<Widget>(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            skill.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stipend', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(
                          data['stipend'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          final Map<String, dynamic> job =
                              (data['_raw'] is Map<String, dynamic>) ? data['_raw'] as Map<String, dynamic> : data;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InternshipDetailsPage(job: job), // pass full raw job (with id)
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Apply Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
