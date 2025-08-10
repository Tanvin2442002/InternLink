import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});
  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<_ChatMessage> _messages = [
    _ChatMessage('assistant', 'Hi! I\'m your InternLink assistant. Ask me about internships, applications, or interview prep.'),
  ];
  final TextEditingController _input = TextEditingController();
  bool _thinking = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _thinking) return;
    setState(() {
      _messages.add(_ChatMessage('user', text));
      _input.clear();
      _thinking = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final reply = _generateMockReply(text);
    setState(() {
      _messages.add(_ChatMessage('assistant', reply));
      _thinking = false;
    });
  }

  String _generateMockReply(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('resume')) {
      return 'For a strong resume: quantify impact (e.g. "Reduced load time 35%"), highlight relevant tech (Flutter, Dart, REST), and keep it to 1 page for an intern role.';
    }
    if (lower.contains('interview')) {
      return 'Interview prep: practice explaining projects, review data structures (lists, maps), and prep 2-3 STAR stories for behavioral questions.';
    }
    if (lower.contains('apply')) {
      return 'Apply strategy: batch 5 applications/day, tailor the first bullet to the role keywords, and follow up politely after 7-10 days.';
    }
    if (lower.contains('cover')) {
      return 'Cover letter tip: 3 short paragraphs – hook + alignment, core impact story, and a confident close with a call to connect.';
    }
    return 'Noted! I can help with internships, resume tips, interview prep, and application strategy. Ask me something like "How do I improve my resume?"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Assistant Chat'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _showPrompts(),
            tooltip: 'Starter Prompts',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              reverse: false,
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_thinking && index == _messages.length) {
                  return const _TypingBubble();
                }
                final m = _messages[index];
                return Align(
                  alignment: m.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: m.role == 'user' ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(m.role == 'user' ? 18 : 4),
                          bottomRight: Radius.circular(m.role == 'user' ? 4 : 18),
                        ),
                        boxShadow: m.role == 'user'
                            ? null
                            : [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: SelectableText(
                        m.text,
                        style: TextStyle(
                          color: m.role == 'user' ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _composer(),
        ],
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 16, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
              onPressed: () => _insertSuggestion(),
              tooltip: 'Insert suggestion',
            ),
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration.collapsed(hintText: 'Ask something...'),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _insertSuggestion() {
    const suggestions = [
      'How do I improve my resume?',
      'Give me 3 behavioral interview tips',
      'What skills should I learn for a Flutter internship?',
      'How many applications should I send weekly?',
    ];
    final next = suggestions[(DateTime.now().millisecondsSinceEpoch ~/ 1000) % suggestions.length];
    setState(() => _input.text = next);
  }

  void _showPrompts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[
              const Icon(Icons.lightbulb, color: Colors.deepPurple),
              const SizedBox(width: 10),
              const Text('Starter Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'How to structure my resume summary?',
                'Best way to follow up after applying',
                'Difference between CV and resume',
                'Mock interview suggestions',
                'How to show project impact',
              ].map((p) => ActionChip(
                label: Text(p),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _input.text = p);
                },
              )).toList(),
            )
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;
  _ChatMessage(this.role, this.text);
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final v = _c.value;
            return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
              final opacity = ((v + i * 0.2) % 1).clamp(0, 1).toDouble();
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            }));
          },
        ),
      ),
    );
  }
}
