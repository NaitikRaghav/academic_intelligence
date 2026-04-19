import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_generator_modal.dart';
import '../shared/ai_chat_screen.dart';
// 📦 1. CORE (Colors & Fonts)
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// 📦 2. MODELS (The Blueprints)
import '../../models/assignment_model.dart';

// 📦 3. PROVIDERS (The Mock Backend Glue)
import '../../providers/mock_database_provider.dart';
import '../../providers/mock_auth_provider.dart';

// 📦 4. WIDGETS (Our Premium UI Building Blocks)
import '../../widgets/ios_glass_card.dart';
import '../../widgets/primary_action_button.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // =========================================================================
    // 🟢 THE END-TO-END MOCK FLOW
    // The screen now listens directly to our Riverpod Mock Database!
    // =========================================================================
    final assignments = ref.watch(mockAssignmentsProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      
      // 📱 A premium iOS-style navigation bar that blurs the content behind it
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        // 👇 ADD THIS LEADING ICON 👇
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chat_bubble_text, color: AppColors.aiAccent),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => const AIChatScreen(assignmentId: 'general')),
            );
          },
        ),
        middle: const Text('Teacher Dashboard', style: AppTypography.headline),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_right, color: AppColors.destructive),
          onPressed: () {
            // Log out the user using our MOCK auth provider
            ref.read(mockAuthServiceProvider).signOut();
          },
        ),
      ),
      
      // 📜 SafeArea ensures the UI doesn't hide behind the iPhone notch or battery bar
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WELCOME HEADER ---
              const Text('Welcome, Professor', style: AppTypography.largeTitle),
              const SizedBox(height: 8),
              const Text(
                'Manage your classes and generate assignments using Academic AI.',
                style: AppTypography.callout,
              ),
              const SizedBox(height: 32),

              // --- THE AI ACTION BUTTON ---
              PrimaryActionButton(
                text: 'Generate Assignment with AI',
                icon: CupertinoIcons.sparkles,
                isAIAction: true, 
                onPressed: () {
                  // This is the magic command that slides the modal up
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => const AIGeneratorModal(),
                  );
                },
              ),
              const SizedBox(height: 40),

              // --- ASSIGNMENTS LIST HEADER ---
              const Text('Active Assignments', style: AppTypography.title2),
              const SizedBox(height: 16),

              // --- ASSIGNMENTS LIST (Using Riverpod Mock Database) ---
              ListView.builder(
                shrinkWrap: true, // Prevents scrolling errors inside a SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Let the main screen handle scrolling
                itemCount: assignments.length, // Listens to Provider
                itemBuilder: (context, index) {
                  final assignment = assignments[index]; // Listens to Provider

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IOSGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // Top Row: Title & AI Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  assignment.title,
                                  style: AppTypography.headline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis, 
                                ),
                              ),
                              // Show a tiny glowing badge if Gemini generated this assignment
                              if (assignment.aiGenerated)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.aiAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.aiAccent.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(CupertinoIcons.sparkles, size: 12, color: AppColors.aiAccent),
                                      const SizedBox(width: 4),
                                      Text('AI Generated', style: AppTypography.caption.copyWith(color: AppColors.aiAccent)),
                                    ],
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Middle Row: Description snippet
                          Text(
                            assignment.description,
                            style: AppTypography.subheadline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // iOS hairline separator
                          Container(
                            height: 0.5, 
                            color: AppColors.divider,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Bottom Row: Due Date & Action Arrow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Due: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
                                style: AppTypography.footnote,
                              ),
                              const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}