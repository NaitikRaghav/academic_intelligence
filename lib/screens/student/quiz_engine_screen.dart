import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Models & Providers
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';

// Widgets
import '../../widgets/ios_glass_card.dart';
import '../../widgets/primary_action_button.dart';

// A temporary model just for the UI
class QuizQuestion {
  final String questionText;
  final List<String> options;
  QuizQuestion({required this.questionText, required this.options});
}

class QuizEngineScreen extends ConsumerStatefulWidget {
  final AssignmentModel quizAssignment;

  const QuizEngineScreen({super.key, required this.quizAssignment});

  @override
  ConsumerState<QuizEngineScreen> createState() => _QuizEngineScreenState();
}

class _QuizEngineScreenState extends ConsumerState<QuizEngineScreen> {
  List<QuizQuestion> _questions = [];
  Map<int, int> _selectedAnswers = {}; // Map of QuestionIndex -> SelectedOptionIndex
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _parseQuizData();
  }

  // 🕵️‍♂️ THE PARSER: This safely extracts questions and HIDES the answers from the student!
  void _parseQuizData() {
    final rawText = widget.quizAssignment.generatedContent;
    final blocks = rawText.split('--------------------------------------------------');
    
    for (var block in blocks) {
      if (block.trim().isEmpty) continue;

      // Split right before the answer to hide it
      final parts = block.split('✅ Correct Answer:');
      final cleanBlock = parts[0].trim();

      final lines = cleanBlock.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isNotEmpty) {
        final qText = lines.first;
        final opts = lines.skip(1).toList();
        _questions.add(QuizQuestion(questionText: qText, options: opts));
      }
    }
  }

  Future<void> _submitQuiz() async {
    // Ensure they answered everything
    if (_selectedAnswers.length < _questions.length) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Incomplete'),
          content: const Text('Please answer all questions before submitting.'),
          actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('No user logged in!');

      // 1. Format their answers into a clean text sheet for the Teacher's AI Analyzer
      final StringBuffer studentAnswers = StringBuffer();
      studentAnswers.writeln("Student Quiz Submission:\n");
      
      for (int i = 0; i < _questions.length; i++) {
        final selectedOptionIndex = _selectedAnswers[i]!;
        final selectedAnswerText = _questions[i].options[selectedOptionIndex];
        
        studentAnswers.writeln("Question ${i + 1}:");
        studentAnswers.writeln("Selected Answer: $selectedAnswerText\n");
      }

     // 2. Build the Submission Model
      final submission = SubmissionModel(
        id: 'uuid_placeholder',
        assignmentId: widget.quizAssignment.id,
        studentId: user.id,
        fileUrl: '', 
        // 👇 FIXED: We now put the answers safely into the ocrText column!
        ocrText: studentAnswers.toString(), 
        submittedAt: DateTime.now(),
      );

      // 3. Save to Supabase
      await ref.read(databaseServiceProvider).submitAssignment(submission);

      if (mounted) {
        Navigator.of(context).pop(); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Submission Failed'),
            content: Text(e.toString()),
            actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: Text(widget.quizAssignment.title.replaceAll('[Quiz] ', ''), style: AppTypography.headline),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: _questions.isEmpty 
          ? const Center(child: Text('Error loading quiz formatting.', style: AppTypography.callout))
          : Column(
              children: [
                // --- SCROLLABLE QUIZ CONTENT ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(question.questionText, style: AppTypography.title2),
                            const SizedBox(height: 16),
                            
                            // Generate the Tappable Options
                            ...List.generate(question.options.length, (optIndex) {
                              final isSelected = _selectedAnswers[index] == optIndex;
                              final optionText = question.options[optIndex];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAnswers[index] = optIndex;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? CupertinoColors.activeOrange.withOpacity(0.15) : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? CupertinoColors.activeOrange : AppColors.glassBorder,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                                          color: isSelected ? CupertinoColors.activeOrange : AppColors.textSecondary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            optionText,
                                            style: AppTypography.body.copyWith(
                                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // --- FIXED BOTTOM SUBMIT BUTTON ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
                  ),
                  child: PrimaryActionButton(
                    text: _isSubmitting ? 'Submitting...' : 'Submit Quiz',
                    icon: CupertinoIcons.paperplane_fill,
                    isAIAction: false,
                    
                    isLoading: _isSubmitting,
                    onPressed: _submitQuiz,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}