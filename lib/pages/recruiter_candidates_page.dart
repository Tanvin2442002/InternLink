import 'package:flutter/material.dart';

class RecruiterCandidatesPage extends StatefulWidget {
  const RecruiterCandidatesPage({super.key});

  @override
  State<RecruiterCandidatesPage> createState() => _RecruiterCandidatesPageState();
}

class _RecruiterCandidatesPageState extends State<RecruiterCandidatesPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> candidates = [
    {
      'name': 'Nabiha Parvez',
      'university': 'MIT',
      'major': 'Computer Science',
      'gpa': '3.8',
      'position': 'Frontend Developer Intern',
      'appliedDate': '2024-01-15',
      'status': 'New',
      'statusColor': Colors.blue,
      'skills': ['React', 'JavaScript', 'HTML/CSS', 'TypeScript'],
      'email': 'john.doe@mit.edu',
      'phone': '+1 (555) 123-4567',
      'experience': '2 years',
      'location': 'Boston, MA',
    },
    {
      'name': 'Yusuf Reza Hasnat',
      'university': 'Stanford',
      'major': 'Data Science',
      'gpa': '3.7',
      'position': 'Data Science Intern',
      'appliedDate': '2024-01-14',
      'status': 'Reviewed',
      'statusColor': Colors.orange,
      'skills': ['Python', 'Machine Learning', 'SQL', 'Pandas'],
      'email': 'sarah.smith@stanford.edu',
      'phone': '+1 (555) 987-6543',
      'experience': '1 year',
      'location': 'Palo Alto, CA',
    },
    {
      'name': 'Zaima Ahmed',
      'university': 'Carnegie Mellon',
      'major': 'Design',
      'gpa': '3.9',
      'position': 'UX Design Intern',
      'appliedDate': '2024-01-13',
      'status': 'Shortlisted',
      'statusColor': Colors.green,
      'skills': ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
      'email': 'mike.johnson@cmu.edu',
      'phone': '+1 (555) 456-7890',
      'experience': '1.5 years',
      'location': 'Pittsburgh, PA',
    },
    {
      'name': 'Nazifa Zahin',
      'university': 'UC Berkeley',
      'major': 'Computer Science',
      'gpa': '3.9',
      'position': 'Backend Developer Intern',
      'appliedDate': '2024-01-12',
      'status': 'Interview Scheduled',
      'statusColor': Colors.purple,
      'skills': ['Node.js', 'MongoDB', 'API Development', 'AWS'],
      'email': 'emma.wilson@berkeley.edu',
      'phone': '+1 (555) 321-0987',
      'experience': '2.5 years',
      'location': 'Berkeley, CA',
    },
  ];

  List<Map<String, dynamic>> get filteredCandidates {
    return candidates.where((candidate) {
      final matchesFilter = _selectedFilter == 'All' || 
                           candidate['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
                           (candidate['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (candidate['position'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (candidate['university'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Candidates'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search candidates by name, position, or university...',
                      prefixIcon: Icon(Icons.search, color: Colors.deepPurple[300]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'New', 'Reviewed', 'Shortlisted', 'Interview Scheduled']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: _selectedFilter == filter ? Colors.white : Colors.deepPurple,
                                  ),
                                ),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.deepPurple,
                                checkmarkColor: Colors.white,
                                side: BorderSide(
                                  color: _selectedFilter == filter ? Colors.deepPurple : Colors.grey[300]!,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.people, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '${filteredCandidates.length} candidates found',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showSortOptions,
                        child: Text(
                          'Sort',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Candidates List
          Expanded(
            child: filteredCandidates.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCandidates.length,
                    itemBuilder: (context, index) {
                      final candidate = filteredCandidates[index];
                      return _buildCandidateCard(candidate);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple[300]!, Colors.deepPurple[500]!],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      (candidate['name'] as String).substring(0, 1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                        candidate['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${candidate['major']} • ${candidate['university']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // FIXED: Responsive badges layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // If space is too narrow, stack badges vertically
                          if (constraints.maxWidth < 200) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                      const SizedBox(width: 4),
                                      Flexible( // ADDED: Flexible to prevent overflow
                                        child: Text(
                                          'GPA: ${candidate['gpa']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis, // ADDED: Handle text overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.work_outline, size: 14, color: Colors.blue[700]),
                                      const SizedBox(width: 4),
                                      Flexible( // ADDED: Flexible to prevent overflow
                                        child: Text(
                                          '${candidate['experience']} exp',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis, // ADDED: Handle text overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          // For wider spaces, use Wrap to handle overflow gracefully
                          return Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                    const SizedBox(width: 4),
                                    Flexible( // ADDED: Flexible to prevent overflow
                                      child: Text(
                                        'GPA: ${candidate['gpa']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis, // ADDED: Handle text overflow
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.work_outline, size: 14, color: Colors.blue[700]),
                                    const SizedBox(width: 4),
                                    Flexible( // ADDED: Flexible to prevent overflow
                                      child: Text(
                                        '${candidate['experience']} exp',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis, // ADDED: Handle text overflow
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (candidate['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (candidate['statusColor'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    candidate['status'] as String,
                    style: TextStyle(
                      color: candidate['statusColor'] as Color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Applied Position
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[50]!, Colors.purple[50]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.work, color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applied for:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          candidate['position'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Skills
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (candidate['skills'] as List<String>)
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[100]!, Colors.grey[50]!],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact Info and Action Buttons - FIXED
            Column(
              children: [
                // Contact Info Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  candidate['email'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Text(
                                'Applied: ${candidate['appliedDate']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons Row - Made responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 350) {
                      // Stack buttons vertically on narrow screens
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _viewCV(candidate),
                              icon: const Icon(Icons.description, size: 18),
                              label: const Text('View CV'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.deepPurple),
                                foregroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showActionMenu(candidate),
                              icon: const Icon(Icons.more_horiz, size: 18),
                              label: const Text('Actions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    
                    // Side by side buttons for wider screens
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _viewCV(candidate),
                            icon: const Icon(Icons.description, size: 18),
                            label: const Text('View CV'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.deepPurple),
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showActionMenu(candidate),
                            icon: const Icon(Icons.more_horiz, size: 18),
                            label: const Text('Actions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.deepPurple[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No candidates found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _viewCV(Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.description, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('${candidate['name']} - CV')),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CV viewer functionality will be implemented here. This would typically show the candidate\'s resume/CV document.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Overview:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('📧 ${candidate['email']}'),
                    Text('📱 ${candidate['phone']}'),
                    Text('🎓 ${candidate['university']}'),
                    Text('📍 ${candidate['location']}'),
                    Text('⏱️ ${candidate['experience']} experience'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading ${candidate['name']}\'s CV...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Advanced filters coming soon: Filter by GPA, skills, experience, location, etc.',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sort by', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.deepPurple),
              title: const Text('Most Recent'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('GPA (Highest)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Colors.green),
              title: const Text('Name (A-Z)'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(Map<String, dynamic> candidate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Actions for ${candidate['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              title: const Text('Shortlist Candidate'),
              subtitle: const Text('Move to shortlisted candidates'),
              onTap: () {
                Navigator.pop(context);
                _updateCandidateStatus(candidate, 'Shortlisted', Colors.green);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Colors.blue),
              ),
              title: const Text('Schedule Interview'),
              subtitle: const Text('Set up an interview with candidate'),
              onTap: () {
                Navigator.pop(context);
                _updateCandidateStatus(candidate, 'Interview Scheduled', Colors.purple);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cancel, color: Colors.red),
              ),
              title: const Text('Reject Application'),
              subtitle: const Text('Decline this application'),
              onTap: () {
                Navigator.pop(context);
                _updateCandidateStatus(candidate, 'Rejected', Colors.red);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateCandidateStatus(Map<String, dynamic> candidate, String newStatus, Color newColor) {
    setState(() {
      candidate['status'] = newStatus;
      candidate['statusColor'] = newColor;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate['name']} status updated to $newStatus'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}