import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core & Models
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../models/assignment_model.dart';

// Widgets
import '../../widgets/cupertino_text_field.dart';
import '../../widgets/primary_action_button.dart';

class AIGeneratorModal extends ConsumerStatefulWidget {
  const AIGeneratorModal({super.key});

  @override
  ConsumerState<AIGeneratorModal> createState() => _AIGeneratorModalState();
}

class _AIGeneratorModalState extends ConsumerState<AIGeneratorModal> {
  final TextEditingController _topicController = TextEditingController();
  DifficultyLevel _selectedDifficulty = DifficultyLevel.intermediate;
  bool _isGenerating = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAI() async {
    if (_topicController.text.isEmpty) return;

    setState(() => _isGenerating = true);

    // =========================================================================
    // 🛑 THE FRONTEND BYPASS (Simulating Gemini AI)
    // Your friend will replace this Future.delayed with the actual Gemini API call
    // =========================================================================
    await Future.delayed(const Duration(seconds: 3)); 

    if (mounted) {
      setState(() => _isGenerating = false);
      // Close the modal and return "success" so the dashboard knows it worked
      Navigator.of(context).pop(true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Takes up 85% of screen
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- MODAL DRAG HANDLE & HEADER ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text('AI Generator', style: AppTypography.headline),
                    // Invisible placeholder to keep the title perfectly centered
                    const SizedBox(width: 60), 
                  ],
                ),
              ],
            ),
          ),
          
          Container(height: 0.5, color: AppColors.divider),

          // --- MODAL CONTENT ---
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('What are we teaching today?', style: AppTypography.title2),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a topic and let Gemini create a structured assignment.',
                      style: AppTypography.callout,
                    ),
                    const SizedBox(height: 32),

                    // 📝 TOPIC INPUT
                    const Text('Assignment Topic', style: AppTypography.footnote),
                    const SizedBox(height: 8),
                    PremiumIOSTextField(
                      placeholder: 'e.g., The French Revolution, Quantum Physics...',
                      controller: _topicController,
                      prefixIcon: CupertinoIcons.book,
                    ),
                    const SizedBox(height: 24),

                    // 🎚️ DIFFICULTY SELECTOR (Native Apple Control)
                    const Text('Difficulty Level', style: AppTypography.footnote),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<DifficultyLevel>(
                        backgroundColor: AppColors.surfaceElevated,
                        thumbColor: AppColors.primary,
                        groupValue: _selectedDifficulty,
                        children: {
                          DifficultyLevel.beginner: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Beginner', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.beginner ? AppColors.textPrimary : AppColors.textSecondary)),
                          ),
                          DifficultyLevel.intermediate: Text('Intermediate', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.intermediate ? AppColors.textPrimary : AppColors.textSecondary)),
                          DifficultyLevel.advanced: Text('Advanced', style: TextStyle(color: _selectedDifficulty == DifficultyLevel.advanced ? AppColors.textPrimary : AppColors.textSecondary)),
                        },
                        onValueChanged: (DifficultyLevel? value) {
                          if (value != null) {
                            setState(() => _selectedDifficulty = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 48),

                    // 🚀 GENERATE BUTTON
                    PrimaryActionButton(
                      text: _isGenerating ? 'Gemini is thinking...' : 'Generate Assignment',
                      icon: CupertinoIcons.sparkles,
                      isAIAction: true,
                      isLoading: _isGenerating,
                      onPressed: _generateWithAI,
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