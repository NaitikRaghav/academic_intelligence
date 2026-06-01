import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../models/assignment_model.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../services/gemini_service.dart';

// Widgets
import '../../widgets/cupertino_text_field.dart';
import '../../widgets/primary_action_button.dart';

class QuizGeneratorModal extends ConsumerStatefulWidget {
  const QuizGeneratorModal({super.key});

  @override
  ConsumerState<QuizGeneratorModal> createState() => _QuizGeneratorModalState();
}

class _QuizGeneratorModalState extends ConsumerState<QuizGeneratorModal> {
  final TextEditingController _subjectController = TextEditingController(); 
  final TextEditingController _topicController = TextEditingController();
  
  DifficultyLevel _selectedDifficulty = DifficultyLevel.intermediate;
  int _questionCount = 5;
  bool _isGenerating = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    final subject = _subjectController.text.trim();
    final topic = _topicController.text.trim();
    
    if (subject.isEmpty || topic.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('No user logged in!');

      // 🚀 1. Call Gemini for the Quiz
      final aiData = await GeminiService().generateQuiz(
        subject: subject,
        topic: topic,
        difficulty: _selectedDifficulty,
        numberOfQuestions: _questionCount,
      );

      // 2. Format the JSON deeply into a clean text sheet for the database
      final rawQuestions = aiData['questions'] as List<dynamic>;
      final StringBuffer quizBuffer = StringBuffer();
      
      for (int i = 0; i < rawQuestions.length; i++) {
        final q = rawQuestions[i];
        quizBuffer.writeln("Question ${i + 1}: ${q['question']}");
        
        final options = List<String>.from(q['options']);
        final letters = ['A', 'B', 'C', 'D'];
        for (int j = 0; j < options.length; j++) {
          quizBuffer.writeln("  ${letters[j]}) ${options[j]}");
        }
        
        quizBuffer.writeln("\n✅ Correct Answer: ${q['correct_answer']}");
        quizBuffer.writeln("💡 Explanation: ${q['explanation']}\n");
        quizBuffer.writeln("--------------------------------------------------\n");
      }

      // 3. Build the model (We add "[Quiz]" to the title so the dashboard knows what it is!)
      final newQuiz = AssignmentModel(
        id: 'uuid_placeholder', 
        title: '[Quiz] ${aiData['title'] ?? 'Generated Quiz'}',
        subject: subject,
        topic: topic,
        difficulty: _selectedDifficulty,
        generatedContent: quizBuffer.toString().trim(),
        createdBy: user.id, 
        deadline: DateTime.now().add(const Duration(days: 3)), // Quizzes due sooner!
        createdAt: DateTime.now(),
      );

      // 4. Save to existing Supabase table
      await ref.read(databaseServiceProvider).createAssignment(newQuiz);

      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      print('GEMINI QUIZ ERROR: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Glitch in the Matrix'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90, 
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(padding: EdgeInsets.zero, child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)), onPressed: () => Navigator.of(context).pop()),
                    const Text('Quiz Builder', style: AppTypography.headline),
                    const SizedBox(width: 60), 
                  ],
                ),
              ],
            ),
          ),
          
          Container(height: 0.5, color: AppColors.divider),

          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Test their knowledge', style: AppTypography.title2),
                    const SizedBox(height: 8),
                    const Text('Gemini will build a multiple-choice quiz with explanations included.', style: AppTypography.callout),
                    const SizedBox(height: 32),

                    const Text('Subject', style: AppTypography.footnote),
                    const SizedBox(height: 8),
                    PremiumIOSTextField(placeholder: 'e.g., Biology', controller: _subjectController, prefixIcon: CupertinoIcons.folder),
                    const SizedBox(height: 24),

                    const Text('Specific Topic', style: AppTypography.footnote),
                    const SizedBox(height: 8),
                    PremiumIOSTextField(placeholder: 'e.g., Cell Division (Mitosis)', controller: _topicController, prefixIcon: CupertinoIcons.book),
                    const SizedBox(height: 24),

                    // 🎚️ NEW: Number of Questions Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Questions', style: AppTypography.footnote),
                        Text('$_questionCount', style: AppTypography.headline.copyWith(color: CupertinoColors.activeOrange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlider(
                        value: _questionCount.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: CupertinoColors.activeOrange,
                        onChanged: (val) => setState(() => _questionCount = val.toInt()),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Difficulty Level', style: AppTypography.footnote),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<DifficultyLevel>(
                        backgroundColor: AppColors.surfaceElevated,
                        thumbColor: AppColors.primary,
                        groupValue: _selectedDifficulty,
                        children: {
                          DifficultyLevel.beginner: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Beginner', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.beginner ? AppColors.textPrimary : AppColors.textSecondary))),
                          DifficultyLevel.intermediate: Text('Intermediate', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.intermediate ? AppColors.textPrimary : AppColors.textSecondary)),
                          DifficultyLevel.advanced: Text('Advanced', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.advanced ? AppColors.textPrimary : AppColors.textSecondary)),
                        },
                        onValueChanged: (val) { if (val != null) setState(() => _selectedDifficulty = val); },
                      ),
                    ),
                    const SizedBox(height: 48),

                    PrimaryActionButton(
                      text: _isGenerating ? 'Gemini is thinking...' : 'Generate Quiz',
                      icon: CupertinoIcons.checkmark_seal_fill,
                      isAIAction: false, 
                      
                      isLoading: _isGenerating,
                      onPressed: _generateQuiz,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}