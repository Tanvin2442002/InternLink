import 'package:flutter/material.dart';

class PrepResourcesPage extends StatefulWidget {
  const PrepResourcesPage({super.key});
  @override
  State<PrepResourcesPage> createState() => _PrepResourcesPageState();
}

class _PrepResourcesPageState extends State<PrepResourcesPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _category = 0;

  final _categories = const ['All','DSA','Flutter','Behavioral','SQL'];
  final List<Map<String,dynamic>> _questions = [
    {
      'q': 'Explain difference between final and const in Dart.',
      'a': 'final: runtime single assignment. const: compile‑time constant & implicit final. const widgets canonicalized.' , 'cat':'Flutter'
    },
    {
      'q': 'What is Big O of binary search?',
      'a': 'O(log n) time, O(1) space (iterative).', 'cat':'DSA'
    },
    {
      'q': 'Tell me about a challenge you overcame.',
      'a': 'Use STAR: Situation, Task, Action, Result. Emphasize impact + learning.', 'cat':'Behavioral'
    },
    {
      'q': 'Write a SQL query to get 2nd highest salary from employees table.',
      'a': 'SELECT MAX(salary) FROM employees WHERE salary < (SELECT MAX(salary) FROM employees);', 'cat':'SQL'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Iterable<Map<String,dynamic>> get _filteredQuestions {
    if (_category==0) return _questions; 
    final cat = _categories[_category];
    return _questions.where((q)=>q['cat']==cat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Interview Prep'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tab,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text:'Practice'),
              Tab(text:'Tips'),
              Tab(text:'Schedule'),
            ]),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildPractice(),
          _buildTips(),
          _buildSchedule(),
        ],
      ),
    );
  }

  Widget _buildPractice() {
    return Column(
      children: [
        SizedBox(
          height: 54,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal:16, vertical:10),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_,i)=> ChoiceChip(
              label: Text(_categories[i]),
              selected: _category==i,
              onSelected: (_){ setState(()=>_category=i); },
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(color: _category==i? Colors.white: Colors.deepPurple),
              backgroundColor: Colors.deepPurple.withOpacity(.08),
            ),
            separatorBuilder: (_,__)=> const SizedBox(width: 8),
            itemCount: _categories.length,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16,4,16,24),
            itemCount: _filteredQuestions.length,
            itemBuilder: (_,i){
              final item = _filteredQuestions.elementAt(i);
              return _QuestionCard(question: item['q']!, answer: item['a']!, category: item['cat']!);
            },
          ),
        )
      ],
    );
  }

  Widget _buildTips() {
    final tips = [
      {'icon': Icons.timer, 'text': 'Time each coding question (target < 30 min).'},
      {'icon': Icons.psychology, 'text': 'Explain thought process out loud while practicing.'},
      {'icon': Icons.compare, 'text': 'After solving, compare with an optimal solution & refactor.'},
      {'icon': Icons.record_voice_over, 'text': 'Record yourself answering behavioral prompts; refine clarity.'},
      {'icon': Icons.auto_awesome, 'text': 'Group patterns: sliding window, two pointers, hashing, recursion.'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16,16,16,32),
      itemBuilder: (_,i){
        final t = tips[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8, offset: const Offset(0,4))],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(t['icon'] as IconData, color: Colors.deepPurple),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(t['text'] as String, style: const TextStyle(fontSize: 14, height: 1.3))),
            ],
          ),
        );
      },
      separatorBuilder: (_,__)=> const SizedBox(height: 12),
      itemCount: tips.length,
    );
  }

  Widget _buildSchedule() {
    final upcoming = [
      {'role':'Frontend Intern','company':'Netflix','time':'Mon 10:00 AM','type':'Technical'},
      {'role':'Data Analyst Intern','company':'Spotify','time':'Wed 2:00 PM','type':'Behavioral'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16,16,16,32),
      itemCount: upcoming.length,
      itemBuilder: (_,i){
        final u = upcoming[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(backgroundColor: Colors.deepPurple.withOpacity(.15), child: const Icon(Icons.event, color: Colors.deepPurple)),
            title: Text(u['role'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${u['company']} • ${u['type']}', style: TextStyle(color: Colors.grey[600])),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.deepPurple),
                const SizedBox(height: 4),
                Text(u['time'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final String question; final String answer; final String category; const _QuestionCard({required this.question, required this.answer, required this.category});
  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard>{
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0,6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(.12), borderRadius: BorderRadius.circular(40)),
                child: Text(widget.category, style: const TextStyle(color: Colors.deepPurple, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_show? Icons.visibility_off: Icons.visibility, color: Colors.deepPurple),
                onPressed: () => setState(()=> _show = !_show),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height:1.3)),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top:12),
              child: Text(widget.answer, style: TextStyle(color: Colors.grey[800], height: 1.35)),
            ),
            crossFadeState: _show? CrossFadeState.showSecond: CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          )
        ],
      ),
    );
  }
}
