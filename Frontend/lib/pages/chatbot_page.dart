import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _applicantId;
  String? _userName;
  bool _hasCV = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data
      final userData = prefs.getString('user_data');
      final profileData = prefs.getString('profile_data');
      
      if (userData != null) {
        final user = jsonDecode(userData);
        _applicantId = user['applicant_id']?.toString();
      }
      
      if (profileData != null) {
        final profile = jsonDecode(profileData);
        _userName = profile['full_name'] ?? 'Student';
        _hasCV = profile['cv_url'] != null && profile['cv_url'].toString().isNotEmpty;
      }

      // Add welcome message
      setState(() {
        _messages.add(ChatMessage(
          content: "Hi ${_userName ?? 'there'}! 👋 I'm your InternLink career assistant. I can help you with:\n\n• CV improvement & analysis\n• Interview preparation\n• Application strategies\n• Career guidance\n\nWhat would you like to work on today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare conversation history (last 10 messages)
      final conversationHistory = _messages
          .where((msg) => msg.content != "Hi ${_userName ?? 'there'}! 👋 I'm your InternLink career assistant...")
          .map((msg) => {
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
          }).toList();

      // Send to backend
      final result = await ApiService.sendChatMessage(
        message: message,
        applicantId: _applicantId,
        conversationHistory: conversationHistory.cast<Map<String, String>>(),
      );

      if (result['success'] == true) {
        setState(() {
          _messages.add(ChatMessage(
            content: result['response'] ?? 'I apologize, but I couldn\'t generate a response.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            content: 'Sorry, I\'m having trouble connecting right now. Please try again in a moment.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: 'I\'m experiencing technical difficulties. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _getCVSuggestions() async {
    if (_applicantId == null) {
      _showSnackBar('Please log in to get CV suggestions');
      return;
    }

    if (!_hasCV) {
      _showSnackBar('Please upload your CV first in the Profile section');
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        content: "Analyze my CV and give me improvement suggestions",
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final result = await ApiService.getCvSuggestions(_applicantId!);

      if (result['success'] == true) {
        final suggestions = result['suggestions'];
        final hasCV = result['hasCV'] ?? false;
        
        if (!hasCV) {
          setState(() {
            _messages.add(ChatMessage(
              content: 'I notice you haven\'t uploaded a CV yet. Please upload your CV in the Profile section first, then I can provide detailed analysis and suggestions!',
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
        } else {
          // Format the AI suggestions into a readable response
          String response = _formatCVSuggestions(suggestions);
          setState(() {
            _messages.add(ChatMessage(
              content: response,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
      } else {
        setState(() {
          _messages.add(ChatMessage(
            content: 'I couldn\'t analyze your CV right now. Please try again or ask me any specific questions about CV improvement.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: 'I\'m having trouble accessing your CV. Please try again or ask me general CV questions.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _formatCVSuggestions(Map<String, dynamic> suggestions) {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 **CV Analysis Complete!**\n');
    
    // Overall score
    if (suggestions['overall_score'] != null) {
      buffer.writeln('**Overall Score:** ${suggestions['overall_score']}/10\n');
    }
    
    // Strengths
    if (suggestions['strengths'] != null && suggestions['strengths'].isNotEmpty) {
      buffer.writeln('✅ **Current Strengths:**');
      for (String strength in suggestions['strengths']) {
        buffer.writeln('• $strength');
      }
      buffer.writeln('');
    }
    
    // Priority improvements
    if (suggestions['priority_improvements'] != null && suggestions['priority_improvements'].isNotEmpty) {
      buffer.writeln('🎯 **Priority Improvements:**');
      for (var improvement in suggestions['priority_improvements']) {
        buffer.writeln('**${improvement['category']}**');
        buffer.writeln('• Issue: ${improvement['issue']}');
        buffer.writeln('• Suggestion: ${improvement['suggestion']}');
        buffer.writeln('• Impact: ${improvement['impact']}\n');
      }
    }
    
    // Quick wins
    if (suggestions['quick_wins'] != null && suggestions['quick_wins'].isNotEmpty) {
      buffer.writeln('⚡ **Quick Wins (Easy fixes):**');
      for (String win in suggestions['quick_wins']) {
        buffer.writeln('• $win');
      }
      buffer.writeln('');
    }
    
    // Advanced tips
    if (suggestions['advanced_tips'] != null && suggestions['advanced_tips'].isNotEmpty) {
      buffer.writeln('🚀 **Advanced Tips:**');
      for (String tip in suggestions['advanced_tips']) {
        buffer.writeln('• $tip');
      }
      buffer.writeln('');
    }
    
    // Sector specific
    if (suggestions['sector_specific'] != null && suggestions['sector_specific'].toString().isNotEmpty) {
      buffer.writeln('🎓 **For Your Field:**');
      buffer.writeln(suggestions['sector_specific']);
      buffer.writeln('');
    }
    
    buffer.writeln('Feel free to ask me about any specific area you\'d like to improve! 💪');
    
    return buffer.toString();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Assistant'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Quick action buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickActionButton(
                    icon: Icons.description,
                    label: 'CV Analysis',
                    onTap: _getCVSuggestions,
                    enabled: _hasCV,
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.work,
                    label: 'Interview Tips',
                    onTap: () => _sendMessage('Give me interview tips'),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.send,
                    label: 'Application Help',
                    onTap: () => _sendMessage('How do I write a good application?'),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionButton(
                    icon: Icons.school,
                    label: 'Career Advice',
                    onTap: () => _sendMessage('What career advice do you have for me?'),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _TypingIndicator();
                }
                
                final message = _messages[index];
                return _ChatBubble(
                  message: message,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me about CV, interviews, applications...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _ChatBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.deepPurple : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[600]!.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? Colors.deepPurple.withOpacity(0.1) : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? Colors.deepPurple.withOpacity(0.3) : Colors.grey[400]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled ? Colors.deepPurple : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.deepPurple : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}