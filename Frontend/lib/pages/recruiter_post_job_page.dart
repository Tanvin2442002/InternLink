import 'package:flutter/material.dart';

class RecruiterPostJobPage extends StatefulWidget {
  const RecruiterPostJobPage({super.key});

  @override
  State<RecruiterPostJobPage> createState() => _RecruiterPostJobPageState();
}

class _RecruiterPostJobPageState extends State<RecruiterPostJobPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample job posts data with enhanced information
  List<Map<String, dynamic>> jobPosts = [
    {
      'id': '1',
      'title': 'Frontend Developer Intern',
      'category': 'Technology',
      'location': 'San Francisco, CA',
      'type': 'Full-time',
      'duration': '3 months',
      'stipend': '\$3000/month',
      'description': 'Join our team to work on cutting-edge web applications using React and modern JavaScript frameworks. You\'ll collaborate with senior developers and gain hands-on experience in building scalable user interfaces.',
      'requirements': 'JavaScript, React, HTML/CSS, Git, TypeScript',
      'applications': 45,
      'views': 234,
      'postedDate': '2024-01-15',
      'status': 'Active',
      'urgency': 'High',
      'company': 'TechCorp',
      'salary': '\$45,000 - \$55,000',
    },
    {
      'id': '2',
      'title': 'Data Science Intern',
      'category': 'Technology',
      'location': 'New York, NY',
      'type': 'Remote',
      'duration': '6 months',
      'stipend': '\$2500/month',
      'description': 'Work with our data team to analyze large datasets and build machine learning models. Perfect opportunity to apply statistical knowledge and learn industry-standard tools.',
      'requirements': 'Python, Pandas, NumPy, Machine Learning, SQL, R',
      'applications': 38,
      'views': 189,
      'postedDate': '2024-01-10',
      'status': 'Active',
      'urgency': 'Medium',
      'company': 'DataTech Solutions',
      'salary': '\$40,000 - \$50,000',
    },
    {
      'id': '3',
      'title': 'UX Design Intern',
      'category': 'Design',
      'location': 'Austin, TX',
      'type': 'Hybrid',
      'duration': '4 months',
      'stipend': '\$2000/month',
      'description': 'Create user-centered designs and improve user experience across our product suite. Work closely with product managers and developers to bring innovative designs to life.',
      'requirements': 'Figma, Adobe XD, User Research, Prototyping, Sketch',
      'applications': 29,
      'views': 156,
      'postedDate': '2024-01-08',
      'status': 'Active',
      'urgency': 'Low',
      'company': 'CreativeSpace',
      'salary': '\$35,000 - \$45,000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple[50]!,
              Colors.purple[50]!,
              Colors.pink[50]!,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Beautiful App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple[600]!,
                        Colors.purple[600]!,
                        Colors.pink[400]!,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.work_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Job Management',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage your internship opportunities',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Header Section with Stats
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Active Jobs',
                                '${jobPosts.length}',
                                Icons.work,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Total Views',
                                '${jobPosts.fold(0, (sum, job) => sum + (job['views'] as int))}',
                                Icons.visibility,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Applications',
                                '${jobPosts.fold(0, (sum, job) => sum + (job['applications'] as int))}',
                                Icons.person,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Post Job Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple[600]!, Colors.purple[500]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showPostJobForm(),
                              borderRadius: BorderRadius.circular(16),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      'Post New Job',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
            
            // Job Posts List
            jobPosts.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          child: _buildJobCard(jobPosts[index], index),
                        );
                      },
                      childCount: jobPosts.length,
                    ),
                  ),
            
            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    final urgencyColor = job['urgency'] == 'High' 
        ? Colors.red 
        : job['urgency'] == 'Medium' 
            ? Colors.orange 
            : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showJobDetails(job),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Company Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple[300] ?? Colors.deepPurple, Colors.purple[400] ?? Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          (job['company'] as String? ?? 'C').substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job['title'] as String? ?? 'Job Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: urgencyColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: urgencyColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  '${job['urgency'] ?? 'Medium'} Priority',
                                  style: TextStyle(
                                    color: urgencyColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job['company'] as String? ?? 'Company Name',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.more_vert, size: 20),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showPostJobForm(job: job, index: index);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(index);
                        } else if (value == 'duplicate') {
                          _duplicateJob(job);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit Job'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Duplicate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Job Categories
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(job['category'] as String? ?? 'Technology', Colors.blue),
                    _buildChip(job['type'] as String? ?? 'Full-time', Colors.purple),
                    _buildChip(job['duration'] as String? ?? '3 months', Colors.orange),
                    _buildChip(job['location'] as String? ?? 'Location', Colors.green),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Job Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50] ?? Colors.grey.shade50, Colors.grey[25] ?? Colors.grey.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job['description'] as String? ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Salary Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[50] ?? Colors.green.shade50, Colors.green[25] ?? Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200] ?? Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[600] ?? Colors.green.shade600, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stipend: ${job['stipend'] ?? 'Not specified'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700] ?? Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'Annual: ${job['salary'] ?? 'Not specified'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600] ?? Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChipSmall(
                        Icons.person,
                        '${job['applications'] ?? 0} applications',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChipSmall(
                        Icons.visibility,
                        '${job['views'] ?? 0} views',
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChipSmall(
                        Icons.calendar_today,
                        _formatDate(job['postedDate'] as String? ?? '2024-01-01'),
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatChipSmall(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[50]!, Colors.purple[50]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.deepPurple[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No job posts yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first job posting to start attracting talented candidates for your internship opportunities.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[600]!, Colors.purple[500]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPostJobForm(),
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Post Your First Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    return '${(difference / 7).floor()}w ago';
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      job['company'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Full Description',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['description'] as String,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Requirements',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['requirements'] as String,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateJob(Map<String, dynamic> job) {
    setState(() {
      final duplicatedJob = Map<String, dynamic>.from(job);
      duplicatedJob['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      duplicatedJob['title'] = '${duplicatedJob['title']} (Copy)';
      duplicatedJob['applications'] = 0;
      duplicatedJob['views'] = 0;
      duplicatedJob['postedDate'] = DateTime.now().toIso8601String().split('T')[0];
      jobPosts.add(duplicatedJob);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Job duplicated successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Rest of the methods (_showPostJobForm, _showDeleteConfirmation) remain the same...
  void _showPostJobForm({Map<String, dynamic>? job, int? index}) {
    showDialog(
      context: context,
      builder: (context) => _PostJobFormDialog(
        job: job,
        onSave: (jobData) {
          setState(() {
            if (index != null) {
              // Edit existing job
              jobPosts[index] = {...jobData, 'id': job!['id']};
            } else {
              // Add new job
              jobPosts.add({
                ...jobData,
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'applications': 0,
                'views': 0,
                'postedDate': DateTime.now().toIso8601String().split('T')[0],
                'status': 'Active',
                'urgency': 'Medium',
                'company': 'Your Company',
                'salary': '\$40,000 - \$50,000',
              });
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Job Post'),
          ],
        ),
        content: Text('Are you sure you want to delete "${jobPosts[index]['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                jobPosts.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Job post deleted successfully'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Enhanced Form Dialog with better styling
class _PostJobFormDialog extends StatefulWidget {
  final Map<String, dynamic>? job;
  final Function(Map<String, dynamic>) onSave;

  const _PostJobFormDialog({
    this.job,
    required this.onSave,
  });

  @override
  State<_PostJobFormDialog> createState() => _PostJobFormDialogState();
}

class _PostJobFormDialogState extends State<_PostJobFormDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _requirementsController;
  late final TextEditingController _locationController;
  late final TextEditingController _stipendController;
  
  late String _selectedDuration;
  late String _selectedType;
  late String _selectedCategory;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    
    // Initialize controllers
    _titleController = TextEditingController(text: widget.job?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.job?['description'] ?? '');
    _requirementsController = TextEditingController(text: widget.job?['requirements'] ?? '');
    _locationController = TextEditingController(text: widget.job?['location'] ?? '');
    _stipendController = TextEditingController(text: widget.job?['stipend'] ?? '');
    
    String existingDuration = widget.job?['duration'] ?? '3 months';
    List<String> validDurations = ['3 months', '4 months', '6 months', '12 months'];
    
    if (validDurations.contains(existingDuration)) {
      _selectedDuration = existingDuration;
    } else {
      _selectedDuration = '3 months';
    }
    
    _selectedType = widget.job?['type'] ?? 'Full-time';
    _selectedCategory = widget.job?['category'] ?? 'Technology';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _stipendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              child: Column(
                children: [
                  // Enhanced Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple[600]!, Colors.purple[500]!],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.work, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job != null ? 'Edit Job Post' : 'Create New Job',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.job != null ? 'Update job details' : 'Fill in the job information',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Content
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildFormField(
                            controller: _titleController,
                            label: 'Job Title',
                            hint: 'e.g., Frontend Developer Intern',
                            icon: Icons.title,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter job title' : null,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildDropdownField(
                            value: _selectedCategory,
                            label: 'Category',
                            icon: Icons.category,
                            items: ['Technology', 'Design', 'Marketing', 'Sales', 'Finance', 'Operations'],
                            onChanged: (value) => setState(() => _selectedCategory = value!),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _descriptionController,
                            label: 'Job Description',
                            hint: 'Describe the role and responsibilities...',
                            icon: Icons.description,
                            maxLines: 4,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter job description' : null,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _requirementsController,
                            label: 'Requirements',
                            hint: 'List required skills and qualifications...',
                            icon: Icons.checklist,
                            maxLines: 3,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter requirements' : null,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Duration and Type Row
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // If screen is too narrow, stack vertically
                              if (constraints.maxWidth < 400) {
                                return Column(
                                  children: [
                                    _buildDropdownField(
                                      value: _selectedDuration,
                                      label: 'Duration',
                                      icon: Icons.schedule,
                                      items: ['3 months', '4 months', '6 months', '12 months'],
                                      onChanged: (value) => setState(() => _selectedDuration = value!),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDropdownField(
                                      value: _selectedType,
                                      label: 'Type',
                                      icon: Icons.work_outline,
                                      items: ['Full-time', 'Part-time', 'Remote', 'Hybrid'],
                                      onChanged: (value) => setState(() => _selectedType = value!),
                                    ),
                                  ],
                                );
                              }
                              
                              // For wider screens, use horizontal layout
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      value: _selectedDuration,
                                      label: 'Duration',
                                      icon: Icons.schedule,
                                      items: ['3 months', '4 months', '6 months', '12 months'],
                                      onChanged: (value) => setState(() => _selectedDuration = value!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      value: _selectedType,
                                      label: 'Type',
                                      icon: Icons.work_outline,
                                      items: ['Full-time', 'Part-time', 'Remote', 'Hybrid'],
                                      onChanged: (value) => setState(() => _selectedType = value!),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Location and Stipend Row - FIXED
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 400) {
                                return Column(
                                  children: [
                                    _buildFormField(
                                      controller: _locationController,
                                      label: 'Location',
                                      hint: 'e.g., San Francisco, CA',
                                      icon: Icons.location_on,
                                      validator: (value) => value?.isEmpty ?? true ? 'Please enter location' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFormField(
                                      controller: _stipendController,
                                      label: 'Stipend',
                                      hint: 'e.g., \$3000/month',
                                      icon: Icons.attach_money,
                                      validator: (value) => value?.isEmpty ?? true ? 'Please enter stipend' : null,
                                    ),
                                  ],
                                );
                              }
                              
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      controller: _locationController,
                                      label: 'Location',
                                      hint: 'e.g., San Francisco, CA',
                                      icon: Icons.location_on,
                                      validator: (value) => value?.isEmpty ?? true ? 'Please enter location' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormField(
                                      controller: _stipendController,
                                      label: 'Stipend',
                                      hint: 'e.g., \$3000/month',
                                      icon: Icons.attach_money,
                                      validator: (value) => value?.isEmpty ?? true ? 'Please enter stipend' : null,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepPurple[600]!, Colors.purple[500]!],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _saveJob,
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: Text(
                                    widget.job != null ? 'Update Job' : 'Post Job',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple[100] ?? Colors.deepPurple.shade100, 
                  Colors.purple[100] ?? Colors.purple.shade100
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple[100] ?? Colors.deepPurple.shade100, 
                  Colors.purple[100] ?? Colors.purple.shade100
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
      ),
    );
  }

  void _saveJob() {
    if (_formKey.currentState!.validate()) {
      final jobData = {
        'title': _titleController.text,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'requirements': _requirementsController.text,
        'location': _locationController.text,
        'type': _selectedType,
        'duration': _selectedDuration,
        'stipend': _stipendController.text,
      };
      
      widget.onSave(jobData);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(widget.job != null 
                  ? 'Job updated successfully!' 
                  : 'Job posted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}