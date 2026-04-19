import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Widgets
import '../../widgets/cupertino_text_field.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String assignmentId; // We pass this so the AI knows what they are talking about!
  
  const AIChatScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // =========================================================================
  // 🛑 THE FRONTEND BYPASS (Mock Chat History)
  // =========================================================================
  final List<Map<String, dynamic>> _messages = [
    {
      'isAI': true,
      'text': 'Hello! I am Academic AI. How can I help you with this assignment today?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    }
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    
    // 1. Add User Message to UI
    setState(() {
      _messages.add({
        'isAI': false,
        'text': userMessage,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // 2. Simulate Gemini Network Delay (Your friend will replace this with real API)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Add AI Response
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'isAI': true,
          'text': 'I am currently running in Mock Mode, but once connected to Firebase, I will analyze your request and provide a detailed, intelligent response!',
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.sparkles, size: 18, color: AppColors.aiAccent),
            const SizedBox(width: 8),
            const Text('Gemini Tutor', style: AppTypography.headline),
          ],
        ),
        // A clean back button
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- CHAT MESSAGES AREA ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show the typing indicator at the very bottom if AI is thinking
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }

                  final msg = _messages[index];
                  final isAI = msg['isAI'] as bool;

                  return _buildChatBubble(msg['text'], isAI);
                },
              ),
            ),

            // --- BOTTOM INPUT AREA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PremiumIOSTextField(
                      controller: _messageController,
                      placeholder: 'Ask Gemini...',
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.aiAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.white, size: 20),
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

  // 🎨 Helper: Draws the beautiful chat bubbles
  Widget _buildChatBubble(String text, bool isAI) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Bubbles take max 75% width
        ),
        decoration: BoxDecoration(
          color: isAI ? AppColors.surfaceElevated : AppColors.primary,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(20),
            bottomRight: isAI ? const Radius.circular(20) : const Radius.circular(0),
          ),
          border: isAI ? Border.all(color: AppColors.glassBorder) : null,
        ),
        child: Text(
          text,
          style: AppTypography.body.copyWith(
            color: isAI ? AppColors.textPrimary : CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  // ✨ Helper: A premium pulsating text indicator
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Text('Thinking...', style: TextStyle(color: AppColors.aiAccent, fontStyle: FontStyle.italic)),
      ),
    );
  }
}