import 'package:flutter/material.dart';
import 'login_page.dart';

class RecruiterDashboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab;
  const RecruiterDashboardPage({super.key, this.onSwitchTab});
  @override
  State<RecruiterDashboardPage> createState() => _RecruiterDashboardPageState();
}

class _RecruiterDashboardPageState extends State<RecruiterDashboardPage> {
  late final PageController _statsController;
  final ScrollController _scrollController = ScrollController();
  int _statsPage = 0;
  bool _refreshing = false;
  DateTime _now = DateTime.now();

  final List<Map<String, dynamic>> _recentApplications = [
    {
      'name': 'Saba',
      'role': 'Frontend Intern',
      'university': 'MIT',
      'time': '2h',
      'status': 'New',
      'color': Colors.blue
    },
    {
      'name': 'Fahim',
      'role': 'Data Science Intern',
      'university': 'Stanford',
      'time': '5h',
      'status': 'Reviewed',
      'color': Colors.orange
    },
    {
      'name': 'Pallab',
      'role': 'UX Design Intern',
      'university': 'CMU',
      'time': '1d',
      'status': 'Shortlisted',
      'color': Colors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _statsController = PageController(viewportFraction: .9);
  }

  @override
  void dispose() {
    _statsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() { _now = DateTime.now(); _refreshing = false; });
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
        heroTag: 'fabPost',
        onPressed: () => widget.onSwitchTab?.call(1),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Post Job'),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          edgeOffset: 70,
          child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildStatsPager()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Talent Funnel', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: _buildFunnelCard())),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Quick Actions', onViewAll: null)),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Application Metrics', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: _buildMetricsChart())),
            SliverToBoxAdapter(child: const SizedBox(height: 18)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: _buildMiniTrendsRow())),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Recent Applications', onViewAll: () => widget.onSwitchTab?.call(2))),
            SliverList.builder(
              itemCount: _recentApplications.length,
              itemBuilder: (_, i) => _buildRecentApplicationTile(_recentApplications[i]),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Top Posts', onViewAll: null)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal:16), child: _buildTopPostsList())),
            SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 120))
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: TextStyle(color: Colors.grey[600], fontSize: 13, letterSpacing: .2)),
                const SizedBox(height: 10),
                const Text('TechVision Labs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                AnimatedOpacity(
                  opacity: _refreshing ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text('Syncing metrics...', style: TextStyle(fontSize: 11, color: Colors.deepPurple)),
                )
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'profile') {
                widget.onSwitchTab?.call(3);
              } else if (v == 'logout') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginPage()));
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.business), title: Text('Company Profile'))),
              PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout'))),
            ],
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.business, color: Colors.deepPurple, size: 30),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsPager() {
    final items = [
      _StatsCard(title: 'This Week', metrics: [
        StatMetric(label: 'Active Posts', value: '8', icon: Icons.work_outline),
        StatMetric(label: 'New Apps', value: '124', icon: Icons.inbox_rounded),
        StatMetric(label: 'Shortlisted', value: '32', icon: Icons.star_rate_rounded),
      ], accent: Colors.deepPurple),
      _StatsCard(title: 'Last Week', metrics: [
        StatMetric(label: 'Active Posts', value: '7', icon: Icons.work_history_rounded),
        StatMetric(label: 'New Apps', value: '110', icon: Icons.move_to_inbox),
        StatMetric(label: 'Shortlisted', value: '27', icon: Icons.star_border_rounded),
      ], accent: Colors.indigo),
    ];
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _statsController,
            onPageChanged: (i) => setState(() => _statsPage = i),
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(left: i==0?16:8, right: i==items.length-1?16:8),
              child: GestureDetector(
                onTap: () => _showStatsDetails(items[i].title),
                child: items[i],
              ),
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

  Widget _buildFunnelCard() {
    final stages = [
      {'label':'Applied','value':124,'color':Colors.blue},
      {'label':'Reviewed','value':90,'color':Colors.indigo},
      {'label':'Interview','value':18,'color':Colors.orange},
      {'label':'Offer','value':4,'color':Colors.green},
    ];
    final max = stages.first['value'] as int; // largest assumed first
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 24, offset: const Offset(0,8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children:[
            const Text('Conversion Funnel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:4), decoration: BoxDecoration(color: Colors.green.withOpacity(.12), borderRadius: BorderRadius.circular(30)), child: const Row(children:[Icon(Icons.trending_up, size:14, color: Colors.green), SizedBox(width:4), Text('+6%', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600))]))
          ]),
          const SizedBox(height: 18),
          ...stages.map((s) {
            final w = (s['value'] as int)/max;
            final Color base = s['color'] as Color;
            final bool narrow = w < 0.45; // use darker text when bar narrow
            final Color txt = narrow ? _adjustLum(base, -.25) : Colors.white;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children:[
                Expanded(
                  child: Stack(children:[
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [base.withOpacity(.12), base.withOpacity(.05)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: w,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [base, base.withOpacity(.75)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Positioned.fill(child: Row(children:[
                      const SizedBox(width: 14),
                      Icon(Icons.circle, size: 10, color: base.withOpacity(.9)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s['label'] as String, style: TextStyle(color: txt, fontWeight: FontWeight.w600, fontSize: 13, shadows: [Shadow(color: Colors.black.withOpacity(narrow?0.05:0.25), blurRadius: 4)]))),
                      Text('${s['value']}', style: TextStyle(color: txt, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black.withOpacity(narrow?0.05:0.25), blurRadius: 4)])),
                      const SizedBox(width: 14),
                    ]))
                  ]),
                )
              ]),
            );
          }),
        ],
      ),
    );
  }

  Color _adjustLum(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.add_circle_outline, label: 'Post Job', color: Colors.deepPurple, onTap: () => widget.onSwitchTab?.call(1)),
      _QuickAction(icon: Icons.people_alt_rounded, label: 'Candidates', color: Colors.indigo, onTap: () => widget.onSwitchTab?.call(2)),
  _QuickAction(icon: Icons.auto_graph_rounded, label: 'Analytics', color: Colors.orange, onTap: _showAnalytics),
  _QuickAction(icon: Icons.chat_bubble_outline, label: 'Messages', color: Colors.green, onTap: _showMessages),
    ];
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal:16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) => actions[i],
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: actions.length,
      ),
    );
  }

  Widget _buildMiniTrendsRow() {
    return Row(children:[
      Expanded(child: _buildMiniTrendCard('Applications', '124', '+12%', Colors.blue, [15,18,22,28,25,30,35])),
      const SizedBox(width: 12),
      Expanded(child: _buildMiniTrendCard('Views', '1.2k', '+8%', Colors.green, [180,190,170,220,240,260,280])),
      const SizedBox(width: 12),
      Expanded(child: _buildMiniTrendCard('Saves', '89', '+5%', Colors.orange, [8,10,12,15,13,16,18])),
    ]);
  }

  Widget _buildRecentApplicationTile(Map<String,dynamic> a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showApplicantDetails(a),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children:[
              CircleAvatar(radius: 26, backgroundColor: (a['color'] as Color).withOpacity(.15), child: Text((a['name'] as String).substring(0,1), style: TextStyle(color: a['color'] as Color, fontWeight: FontWeight.w700))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text(a['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height:4),
                Text('${a['role']} • ${a['university']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height:6),
                Row(children:[
                  Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (a['color'] as Color).withOpacity(.12), borderRadius: BorderRadius.circular(30)), child: Text(a['status'] as String, style: TextStyle(color: a['color'] as Color, fontSize: 11, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 10),
                  Text('• ${a['time']} ago', style: TextStyle(fontSize: 11, color: Colors.grey[500]))
                ])
              ])),
              Column(children:[
                IconButton(onPressed: () { _snack('Shortlisted ${a['name']}'); }, icon: const Icon(Icons.playlist_add_check, color: Colors.green)),
                IconButton(onPressed: () { _snack('Archived ${a['name']}'); }, icon: const Icon(Icons.archive_outlined, color: Colors.redAccent)),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  void _snack(String msg) { if(!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); }
  void _showStatsDetails(String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24,24,24,32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[const Icon(Icons.insights, color: Colors.deepPurple), const SizedBox(width:12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(), IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))]),
            const SizedBox(height: 12),
            const Text('Detailed metrics coming soon. This modal proves tap works for stat cards.', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
  void _showAnalytics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .9,
        minChildSize: .5,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(24,20,24,32),
          child: ListView(
            controller: controller,
            children: [
              Row(children:[const Icon(Icons.auto_graph, color: Colors.orange), const SizedBox(width: 10), const Text('Analytics Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const Spacer(), IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))]),
              const SizedBox(height: 18),
              _miniAnalyticsRow('Applications / Post','15.5','Avg last 7d', Icons.trending_up, Colors.blue),
              const SizedBox(height: 14),
              _miniAnalyticsRow('View → Apply Rate','12%','Healthy', Icons.show_chart, Colors.indigo),
              const SizedBox(height: 14),
              _miniAnalyticsRow('Shortlist Rate','26%','Above avg', Icons.star_half, Colors.orange),
              const SizedBox(height: 14),
              _miniAnalyticsRow('Time to First Review','3h','Fast', Icons.timer, Colors.green),
              const SizedBox(height: 26),
              ElevatedButton.icon(onPressed: (){Navigator.pop(context); _snack('Export coming soon');}, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(vertical: 14)), icon: const Icon(Icons.file_download, color: Colors.white), label: const Text('Export Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }
  Widget _miniAnalyticsRow(String title, String value, String subtitle, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14, offset: const Offset(0,6))]),
    child: Row(children:[
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600]))
      ])),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))
    ]),
  );
  void _showMessages() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24,24,24,32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[const Icon(Icons.chat_bubble_outline, color: Colors.green), const SizedBox(width: 12), const Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(), IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))]),
            const SizedBox(height: 12),
            _messageStub('System','You have 3 new applications today.'),
            _messageStub('HR Bot','Remember to review pending candidates.'),
            _messageStub('Platform','Feature update: AI screening coming soon.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: (){Navigator.pop(context); _snack('Open full inbox (future)');}, icon: const Icon(Icons.open_in_new), label: const Text('Open Inbox'))
          ],
        ),
      ),
    );
  }
  Widget _messageStub(String from, String body) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10, offset: const Offset(0,4))]),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
      CircleAvatar(radius: 18, backgroundColor: Colors.deepPurple.shade100, child: Text(from.substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w700))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(from, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(fontSize: 12, height: 1.3)),
      ]))
    ]),
  );
  void _showApplicantDetails(Map<String,dynamic> a) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24,24,24,32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[CircleAvatar(radius: 26, backgroundColor: (a['color'] as Color).withOpacity(.15), child: Text((a['name'] as String).substring(0,1), style: TextStyle(color: a['color'] as Color, fontWeight: FontWeight.w700))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(a['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text('${a['role']} • ${a['university']}', style: TextStyle(fontSize: 12, color: Colors.grey[600]))])), IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))]),
            const SizedBox(height: 16),
            const Text('Summary', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Motivated candidate for internship role. Portfolio and resume review feature to be integrated.', style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3)),
            const SizedBox(height: 18),
            Row(children:[
              Expanded(child: ElevatedButton.icon(onPressed: (){Navigator.pop(context); _snack('Shortlisted ${a['name']}');}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)), icon: const Icon(Icons.check, color: Colors.white), label: const Text('Shortlist', style: TextStyle(color: Colors.white)))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: (){Navigator.pop(context); _snack('Scheduled interview (stub)');}, icon: const Icon(Icons.video_call), label: const Text('Interview'))),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: (){Navigator.pop(context); _snack('Archived ${a['name']}');}, icon: const Icon(Icons.archive_outlined), label: const Text('Archive')))
          ],
        ),
      ),
    );
  }


  Widget _buildMetricsChart() {
    // Sample data for the last 7 days
    final List<double> applicationData = [15, 25, 18, 30, 22, 35, 28];
    final List<double> viewsData = [120, 180, 150, 220, 190, 280, 240];
    final List<double> savesData = [8, 12, 10, 15, 13, 18, 16];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 7 Days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      '+18%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Chart bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final maxValue = applicationData.reduce((a, b) => a > b ? a : b);
                      final normalizedHeight = (applicationData[index] / maxValue) * 100;
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Application bar
                          Container(
                            width: 25,
                            height: normalizedHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day label
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Applications', Colors.blue, '${applicationData.reduce((a, b) => a + b).toInt()}'),
              _buildLegendItem('Profile Views', Colors.green, '${(viewsData.reduce((a, b) => a + b) / 1000).toStringAsFixed(1)}k'),
              _buildLegendItem('Job Saves', Colors.orange, '${savesData.reduce((a, b) => a + b).toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }


  Widget _buildTopPostsList() {
    final topPosts = [
      {
        'title': 'Frontend Developer Intern',
        'applications': '45',
        'views': '234',
        'postedDate': '5 days ago',
        'status': 'Active',
      },
      {
        'title': 'Data Science Intern',
        'applications': '38',
        'views': '189',
        'postedDate': '1 week ago',
        'status': 'Active',
      },
      {
        'title': 'UX Design Intern',
        'applications': '29',
        'views': '156',
        'postedDate': '2 weeks ago',
        'status': 'Active',
      },
    ];

    return Column(
      children: topPosts.map((post) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post['title'] as String, // Cast to String
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post['status'] as String, // Cast to String
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${post['applications'] as String} applications', // Cast to String
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${post['views'] as String} views', // Cast to String
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    post['postedDate'] as String, // Cast to String
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniTrendCard(String title, String value, String change, Color color, List<double> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: CustomPaint(
              size: const Size(double.infinity, 30),
              painter: MiniChartPainter(data: data, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback? onViewAll; const _SectionHeader({required this.title, this.onViewAll});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal:16),
    child: Row(children:[
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const Spacer(),
      if(onViewAll!=null) TextButton(onPressed: onViewAll, child: const Text('See all'))
    ]));
}

class StatMetric {
  final String label; final String value; final IconData icon; StatMetric({required this.label, required this.value, required this.icon});
}

class _StatsCard extends StatelessWidget {
  final String title; final List<StatMetric> metrics; final Color accent; const _StatsCard({required this.title, required this.metrics, required this.accent});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
  final totalH = constraints.maxHeight; // ~180 from pager sizing
  final metricsAvailable = (totalH - 40 - 22 - 32).clamp(50.0, 110.0);
  final scale = (metricsAvailable / 80).clamp(.75, 1.05);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent.withOpacity(.85), accent]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: accent.withOpacity(.35), blurRadius: 20, offset: const Offset(0,10))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22,20,22,20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 140),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white70, fontSize: 12*scale, letterSpacing: .5)),
              SizedBox(height: 8*scale),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for(final m in metrics)...[
                      Expanded(child: _miniMetric(m, scale)),
                      if(m != metrics.last) Container(width:1, height: double.infinity, margin: EdgeInsets.symmetric(horizontal:10*scale), color: Colors.white24)
                    ]
                  ],
                ),
              ),
              SizedBox(height: 8*scale),
              Row(children:[
                Icon(Icons.trending_up, size: 16*scale, color: Colors.white70),
                SizedBox(width:6*scale),
                Text('+${(5 + metrics.length*3)}% vs last', style: TextStyle(color: Colors.white70, fontSize: 11*scale))
              ])
            ],
            ),
          ),
        ),
      );
    });
  }
  Widget _miniMetric(StatMetric m, double scale) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children:[
      Container(
        padding: EdgeInsets.all(8*scale),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(14*scale)),
        child: Icon(m.icon, color: Colors.white, size: 18*scale),
      ),
      SizedBox(height:4*scale),
      FittedBox(child: Text(m.value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16*scale))),
      FittedBox(child: Text(m.label, style: TextStyle(color: Colors.white70, fontSize: 9*scale)))
    ]
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap; const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(.7)]), borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  MiniChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Normalize data to fit the chart height
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw the filled area
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line
    canvas.drawPath(path, linePaint);

    // Draw small circles at data points
    final Paint pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

