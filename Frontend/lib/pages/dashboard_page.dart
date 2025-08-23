import 'package:flutter/material.dart';
import 'login_page.dart';
import 'internship_details_page.dart';
import 'chatbot_page.dart';
import '../services/api_service.dart'; // <-- add import

class DashboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab;
  const DashboardPage({super.key, this.onSwitchTab});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _statsController;
  int _statsPage = 0;
  DateTime _now = DateTime.now();
  bool _refreshing = false;
  // Profile completion tasks (local demo state)
  final List<_ProfileTask> _profileTasks = [
    _ProfileTask('Add profile photo', Icons.person, 'Upload a clear headshot.', false),
    _ProfileTask('Add education', Icons.school, 'Include degree & year.', true),
    _ProfileTask('Add 3+ skills', Icons.code, 'Show relevant technologies.', false),
    _ProfileTask('Upload resume', Icons.description, 'Attach a recent PDF.', false),
    _ProfileTask('Complete bio/summary', Icons.badge, 'Short value statement.', true),
  ];

  // Recent activities (demo data)
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'Applied to Flutter Dev Intern',
      'icon': Icons.send_rounded,
      'color': Colors.blue,
      'time': '2h ago',
    },
    {
      'title': 'Interview scheduled with OpenAI',
      'icon': Icons.video_call_rounded,
      'color': Colors.orange,
      'time': '1d ago',
    },
    {
      'title': 'Saved ML Intern at AWS',
      'icon': Icons.bookmark_rounded,
      'color': Colors.green,
      'time': '3d ago',
    },
  ];

  double get _profileCompletion => _profileTasks.where((t)=>t.done).length / _profileTasks.length;

  @override
  void initState() {
    super.initState();
    _statsController = PageController(viewportFraction: .88);
    _fetchSavedInternships(); // <-- load saved items
  }

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 900)); // TODO hook real calls
    setState(() {
      _now = DateTime.now();
      _refreshing = false;
    });
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fabApply',
        onPressed: () => widget.onSwitchTab?.call(1),
        icon: const Icon(Icons.search_rounded),
        label: const Text('Find Internships'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        edgeOffset: 70,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: _buildTopBar(context),
              toolbarHeight: 90,
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildStatsPager()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Profile Progress', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildProfileCompletionCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Quick Actions', onViewAll: null)),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Application Activity', onViewAll: null)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: _buildActivityChart())),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Recommendations', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildRecommendations()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Career Tips', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildTips()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Saved Internships', onViewAll: () => widget.onSwitchTab?.call(1))),
            SliverToBoxAdapter(child: _buildHorizontalSaved(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Recent Activity', onViewAll: null)),
            SliverList.builder(
              itemCount: _recentActivities.length,
              itemBuilder: (_, i) => _buildActivityTile(_recentActivities[i]),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 96))
          ],
        ),
      ),
    );
  }

  // Top bar with greeting + avatar popup
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: TextStyle(color: Colors.grey[600], fontSize: 13, letterSpacing: .2)),
                const SizedBox(height: 4),
                const Text('Pallab 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                AnimatedOpacity(
                  opacity: _refreshing ? 1 : .0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text('Updating...', style: TextStyle(fontSize: 11, color: Colors.deepPurple)),
                )
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'profile') {
                widget.onSwitchTab?.call(3);
              } else if (v == 'logout') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person), title: Text('Profile'))),
              const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout'))),
            ],
            child: Hero(
              tag: 'avatar',
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.deepPurple.shade100,
                child: const Icon(Icons.person, color: Colors.deepPurple, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Stats pager
  Widget _buildStatsPager() {
    final items = [
      _StatSummary(applications: 12, interviews: 3, saved: 8, title: 'This Week'),
      _StatSummary(applications: 34, interviews: 6, saved: 21, title: 'This Month'),
    ];
    return Column(
      children: [
        SizedBox(
          height: 170, // slightly reduced to align internal calculated heights & avoid flex rounding overflow
          child: PageView.builder(
            controller: _statsController,
            onPageChanged: (i) => setState(() => _statsPage = i),
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(left: i==0?16:8, right: i==items.length-1?16:8),
              child: items[i],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: _statsPage == i ? 22 : 8,
            decoration: BoxDecoration(
              color: _statsPage == i ? Colors.deepPurple : Colors.deepPurple.withOpacity(.25),
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        )
      ],
    );
  }

  Widget _buildProfileCompletionCard() {
  final completion = _profileCompletion; // dynamic progress
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 7,
                    backgroundColor: Colors.deepPurple.withOpacity(.1),
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                ),
                Text('${(completion*100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complete your profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Add education, skills & resume to boost visibility.', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: completion,
                      minHeight: 6,
                      backgroundColor: Colors.deepPurple.withOpacity(.15),
                      valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => widget.onSwitchTab?.call(3),
              child: const Text('Update'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recs = [
      {'role':'Flutter Dev Intern','company':'Airbnb','color':Colors.teal},
      {'role':'ML Intern','company':'OpenAI','color':Colors.indigo},
      {'role':'Cloud Intern','company':'AWS','color':Colors.orange},
      {'role':'Security Intern','company':'Cloudflare','color':Colors.blueGrey},
    ];
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final r = recs[i];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (r['color'] as Color).withOpacity(.08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children:[
                  Container(width:38,height:38, decoration: BoxDecoration(color: (r['color'] as Color).withOpacity(.25), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.work, color: r['color'] as Color, size: 20)),
                  const Spacer(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.bookmark_add_outlined, color: r['color'] as Color))
                ]),
                const Spacer(),
                Text(r['role'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height:4),
                Text(r['company'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[700]))
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: recs.length,
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      {'icon': Icons.picture_as_pdf, 'title': 'Polish your resume'},
      {'icon': Icons.question_answer_outlined, 'title': 'Prep interview Qs'},
      {'icon': Icons.badge_outlined, 'title': 'Add certifications'},
      {'icon': Icons.people_alt_outlined, 'title': 'Grow your network'},
    ];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final t = tips[i];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 14, offset: const Offset(0,6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(t['icon'] as IconData, color: Colors.deepPurple, size: 20),
                ),
                const Spacer(),
                Text(t['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: tips.length,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.search_rounded, label: 'Browse', onTap: () => widget.onSwitchTab?.call(1)),
      _QuickAction(icon: Icons.track_changes_rounded, label: 'Tracker', onTap: () => widget.onSwitchTab?.call(2)),
  _QuickAction(icon: Icons.smart_toy_rounded, label: 'Chatbot', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const ChatbotPage()))),
    ];
    return SizedBox(
      height: 86, // reduce to avoid vertical tightness below
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) => actions[i],
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: actions.length,
      ),
    );
  }

  Widget _buildHorizontalSaved(BuildContext context) {
    final data = _savedInternships; // reuse existing structure later if dynamic
    return SizedBox(
      height: 210,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (_, i) {
          final it = data[i];
          return Container(
            width: 260,
            margin: EdgeInsets.only(right: i==data.length-1?0:16),
            child: _SavedHorizontalCard(
              item: it,
              onDetails: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InternshipDetailsPage(
                    // push the whole raw backend item; fall back to mapped item
                    job: (it['_raw'] is Map)
                        ? Map<String, dynamic>.from(it['_raw'] as Map)
                        : it,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityTile(Map<String,dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity['title'] as String, style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(activity['time'] as String, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Activity chart (kept lightweight for now; replace with real data later)
  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Last 7 Days', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
                child: const Row(children:[Icon(Icons.trending_up, size:14, color: Colors.green), SizedBox(width:4), Text('+23%', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600))]),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: LineChartPainter(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ChartLegend(label: 'Applications', color: Colors.blue, value: '12'),
              _ChartLegend(label: 'Responses', color: Colors.green, value: '5'),
              _ChartLegend(label: 'Interviews', color: Colors.orange, value: '3'),
            ],
          )
        ],
      ),
    );
  }

  // Data -----------------------------------------------------------------
  // Replace hard-coded demo with backend data
  List<Map<String,dynamic>> _savedInternships = []; // <-- was final demo list

  Future<void> _fetchSavedInternships() async {
    final res = await ApiService.getSavedInternshipsWithStoredApplicant();
    if (!mounted) return;
    if (res['success'] == true) {
      final list = (res['savedInternships'] as List? ?? [])
          .map<Map<String,dynamic>>((e) => _mapSavedBackendItem(e as Map))
          .toList();
      setState(() => _savedInternships = list);
    } else {
      // Keep empty silently; UI design unchanged
    }
  }

  // Map backend saved item -> card shape (keeps existing design)
  Map<String, dynamic> _mapSavedBackendItem(Map src) {
    // API may return { id, applicant_id, job_id, saved_at, job: {...} } or just the job itself
    final Map job = (src['job'] is Map) ? (src['job'] as Map) : src;

    final title = (job['title'] ?? 'Internship').toString();
    final company = (job['company_name'] ?? 'Unknown Company').toString();
    final location = (job['location'] ?? job['employment_type'] ?? 'Remote').toString();
    final stipend = (job['stipend'] ?? 'N/A').toString();
    final savedIso = (src['saved_at'] ?? job['updated_at'] ?? job['created_at'])?.toString();

    final icon = _pickIconForTitle(title);
    final color = _pickColorForTitle(title);

    return {
      'title': title,
      'company': company,
      'location': location,
      'type': (job['role_type'] ?? 'Internship').toString(),
      'logo': icon,          // IconData for existing card UI
      'color': color,        // Color for existing card UI
      'salary': stipend,     // shown as salary in card
      'savedDate': _relativeShort(savedIso), // e.g., "2d"
      // keep the full raw backend item for Details navigation
      '_raw': Map<String, dynamic>.from(src),
    };
  }

  IconData _pickIconForTitle(String t) {
    final s = t.toLowerCase();
    if (s.contains('data') || s.contains('ml') || s.contains('ai')) return Icons.analytics;
    if (s.contains('design') || s.contains('ui') || s.contains('ux')) return Icons.design_services;
    if (s.contains('cloud') || s.contains('devops')) return Icons.cloud;
    if (s.contains('mobile') || s.contains('android') || s.contains('ios') || s.contains('flutter')) return Icons.phone_iphone;
    return Icons.computer;
  }

  Color _pickColorForTitle(String t) {
    final s = t.toLowerCase();
    if (s.contains('data') || s.contains('ml') || s.contains('ai')) return Colors.green;
    if (s.contains('design') || s.contains('ui') || s.contains('ux')) return Colors.purple;
    if (s.contains('cloud') || s.contains('devops')) return Colors.blueGrey;
    if (s.contains('mobile') || s.contains('android') || s.contains('ios') || s.contains('flutter')) return Colors.orange;
    return Colors.blue;
  }

  String _relativeShort(String? iso) {
    if (iso == null || iso.isEmpty) return 'now';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      final w = (diff.inDays / 7).floor();
      if (w < 5) return '${w}w';
      final mo = (diff.inDays / 30).floor();
      return '${mo}mo';
    } catch (_) {
      return 'recent';
    }
  }

  // (Removed unused _mapSavedToJob method)
}

// Reusable small widgets --------------------------------------------------
class _ProfileTask {
  final String title; final IconData icon; final String subtitle; bool done; _ProfileTask(this.title, this.icon, this.subtitle, this.done);
}
class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback? onViewAll; const _SectionHeader({required this.title, this.onViewAll});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal:16),
    child: Row(children: [
      Text(title, style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700)),
      const Spacer(),
      if (onViewAll != null) TextButton(onPressed: onViewAll, child: const Text('See all'))
    ]));
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(horizontal:10, vertical:8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700]),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)
            ],
          ))
      ),
    );
  }
}

class _SavedHorizontalCard extends StatelessWidget {
  final Map<String,dynamic> item; final VoidCallback onDetails; const _SavedHorizontalCard({required this.item, required this.onDetails});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16,14,16,14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(item['logo'] as IconData, color: item['color'] as Color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5,fontWeight: FontWeight.w700, height: 1.15))),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved ${item['title']}')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_rounded, color: Colors.orange, size: 20),
                )
              ]),
              Row(children:[
                Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                const SizedBox(width:3),
                Expanded(child: Text(item['location'] as String, style: TextStyle(fontSize: 10.5,color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width:6),
                Container(padding: const EdgeInsets.symmetric(horizontal:7, vertical:3), decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(.1), borderRadius: BorderRadius.circular(30)), child: Text(item['type'] as String, style: const TextStyle(fontSize: 9.5, color: Colors.deepPurple, fontWeight: FontWeight.w600)))
              ]),
              Row(children:[
                Text(item['salary'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green)),
                const Spacer(),
                Text('Saved '+(item['savedDate'] as String), style: TextStyle(fontSize: 10,color: Colors.grey[500]))
              ]),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.deepPurple.withOpacity(.4))
                  ),
                  onPressed: onDetails,
                  child: const Text('Details'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatSummary extends StatelessWidget {
  final int applications; final int interviews; final int saved; final String title; const _StatSummary({required this.applications, required this.interviews, required this.saved, required this.title});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final h = constraints.maxHeight; // expected ~180 from pager
      // Vertical padding = 40; title section ~22; bottom row ~32 -> remaining for metrics
  // Recompute available space with outer card height ~170 and slightly reduced paddings
  final double metricsHeight = (h - 38 - 20 - 30).clamp(58.0, 88.0);
      // Width-based scale to prevent overflow & avoid zero-size issues from FittedBox+Expanded
      final width = constraints.maxWidth;
      final widthScale = (width / (3*95)).clamp(.75, 1.0); // assume ideal 95px per metric
      final scale = ((metricsHeight / 80) * widthScale).clamp(.70, 1.0);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(.3), blurRadius: 18, offset: const Offset(0,10))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,18,20,18),
          child: IntrinsicHeight(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white70, fontSize: 12*scale, letterSpacing: .5)),
              SizedBox(height: 5*scale),
              SizedBox(
                height: metricsHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _miniStat('Applications', applications, Icons.send_rounded, scale)),
                    _divider(metricsHeight, scale),
                    Expanded(child: _miniStat('Interviews', interviews, Icons.video_call_rounded, scale)),
                    _divider(metricsHeight, scale),
                    Expanded(child: _miniStat('Saved', saved, Icons.bookmark_rounded, scale)),
                  ],
                ),
              ),
              SizedBox(height: 3*scale),
              Row(children:[
                Icon(Icons.trending_up, size: 16*scale, color: Colors.white70),
                SizedBox(width:6*scale),
                Text('+23% vs last period', style: TextStyle(color: Colors.white70, fontSize: 11*scale))
              ])
            ],
            ),
          ),
        ),
      );
    });
  }
  Widget _miniStat(String label, int v, IconData icon, double scale) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children:[
      Container(
        padding: EdgeInsets.all(9*scale),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(14*scale)),
        child: Icon(icon, color: Colors.white, size: 18*scale),
      ),
      SizedBox(height:4*scale),
      Text('$v', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15*scale), maxLines: 1, overflow: TextOverflow.visible),
      Text(label, style: TextStyle(color: Colors.white70, fontSize: 9.5*scale), maxLines: 1, overflow: TextOverflow.fade, softWrap: false)
    ]
  );
  Widget _divider(double metricsHeight, double scale) => Container(width: 1, height: metricsHeight*0.65, margin: EdgeInsets.symmetric(horizontal:10*scale), color: Colors.white.withOpacity(.25));
}

class _ChartLegend extends StatelessWidget {
  final String label; final Color color; final String value; const _ChartLegend({required this.label, required this.color, required this.value});
  @override
  Widget build(BuildContext context) => Column(children:[
    Row(mainAxisSize: MainAxisSize.min, children:[
      Container(width:12,height:12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width:6),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))
    ]),
    const SizedBox(height:4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))
  ]);
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Sample data points for the chart
    final applicationData = [2, 1, 3, 2, 4, 1, 2]; // Applications per day
    final responseData = [0, 1, 1, 0, 2, 0, 1];    // Responses per day
    final interviewData = [0, 0, 1, 0, 1, 0, 1];   // Interviews per day

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height - (i * size.height / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i < 7; i++) {
      final x = i * size.width / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw lines
    _drawLine(canvas, size, applicationData, Colors.blue, paint);
    _drawLine(canvas, size, responseData, Colors.green, paint);
    _drawLine(canvas, size, interviewData, Colors.orange, paint);

    // Draw day labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < days.length; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      
      final x = i * size.width / 6 - textPainter.width / 2;
      textPainter.paint(canvas, Offset(x, size.height + 10));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<int> data, Color color, Paint paint) {
    paint.color = color;
    
    final path = Path();
    final maxValue = 5; // Max value for scaling
    
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw points
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
