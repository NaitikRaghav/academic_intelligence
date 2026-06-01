import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Providers & Services
import '../../providers/chat_provider.dart';
import '../../services/gemini_service.dart'; // 👈 We imported your new AI brain here!

// Widgets
import '../../widgets/cupertino_text_field.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String assignmentId; 
  
  const AIChatScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Get the active Chat ID from our Riverpod provider
    final chatId = ref.read(chatIdProvider(widget.assignmentId)).value;
    if (chatId == null) return;

    _messageController.clear();
    setState(() => _isTyping = true);

    // 1. Insert User Message directly into Supabase
    await Supabase.instance.client.from('messages').insert({
      'chat_id': chatId,
      'sender': 'user',
      'message': text,
    });

    _scrollToBottom();

    try {
      // 🚀 2. CALL THE REAL GEMINI API!
      final aiResponse = await GeminiService().askChatbot(
        studentQuestion: text,
        // 👇 FIXED: Passing a real string instead of null to keep Null Safety happy!
        assignmentContext: widget.assignmentId == 'general' 
            ? 'General tutoring session' 
            : 'Assignment ID: ${widget.assignmentId}', 
      );

      // 3. Save Gemini's brilliant response to Supabase
      await Supabase.instance.client.from('messages').insert({
        'chat_id': chatId,
        'sender': 'ai',
        'message': aiResponse,
      });

    } catch (e) {
      // 👇 ADD THIS LINE TO FORCE FLUTTER TO TELL US WHAT IS WRONG
      print('GEMINI API CRASHED: $e'); 
      
      // If the API fails, tell the user gracefully
      await Supabase.instance.client.from('messages').insert({
        'chat_id': chatId,
        'sender': 'ai',
        'message': 'Oops! My AI brain hit a glitch: $e',
      });
    } finally {
      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
    // 🟢 Listen to the LIVE Supabase Messages Stream
    final messagesAsync = ref.watch(chatMessagesProvider(widget.assignmentId));

    // Force scroll to bottom when new messages arrive
    ref.listen(chatMessagesProvider(widget.assignmentId), (previous, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.sparkles, size: 18, color: AppColors.aiAccent),
            SizedBox(width: 8),
            Text('Gemini Tutor', style: AppTypography.headline),
          ],
        ),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- CHAT MESSAGES AREA ---
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: AppColors.destructive))),
                data: (messages) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }

                      final msg = messages[index];
                      final isAI = msg.sender == 'ai';

                      return _buildChatBubble(msg.message, isAI);
                    },
                  );
                },
              ),
            ),

            // --- BOTTOM INPUT AREA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
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
          maxWidth: MediaQuery.of(context).size.width * 0.75, 
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