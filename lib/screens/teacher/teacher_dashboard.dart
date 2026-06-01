import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modals & Screens
import 'ai_generator_modal.dart';
import 'quiz_generator_modal.dart'; // 👈 Your new Quiz Modal!
import 'assignment_detail_screen.dart';
import '../shared/ai_chat_screen.dart';

// 📦 Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// 📦 Providers
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';

// 📦 Widgets
import '../../widgets/ios_glass_card.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final teacherId = user?.id ?? '';
    final assignmentsAsync = ref.watch(teacherAssignmentsStreamProvider(teacherId));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
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
          onPressed: () => ref.read(authServiceProvider).signOut(),
        ),
      ),
      
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HERO SECTION ---
              const Text('Welcome, Professor', style: AppTypography.largeTitle),
              const SizedBox(height: 8),
              const Text(
                'Manage your classes and generate content using Academic AI.',
                style: AppTypography.callout,
              ),
              const SizedBox(height: 32),

              // --- 🚀 THE NEW ACTION GRID SURPRISE ---
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Assignment',
                      subtitle: 'Essays & Tasks',
                      icon: CupertinoIcons.doc_text_viewfinder,
                      color: AppColors.aiAccent,
                      onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) => const AIGeneratorModal(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Smart Quiz',
                      subtitle: 'Multiple Choice',
                      icon: CupertinoIcons.checkmark_seal_fill,
                      color: CupertinoColors.activeOrange, // Distinct color for quizzes
                      onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) => const QuizGeneratorModal(), // We build this next!
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // --- ASSIGNMENTS LIST ---
              const Text('Active Content', style: AppTypography.title2),
              const SizedBox(height: 16),

              assignmentsAsync.when(
                loading: () => const Center(child: CupertinoActivityIndicator(radius: 16)),
                error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: AppColors.destructive))),
                data: (assignments) {
                  if (assignments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('Your dashboard is clear.\nTap above to generate content!', 
                          textAlign: TextAlign.center, 
                          style: AppTypography.callout.copyWith(color: AppColors.textSecondary)
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assignments.length, 
                    itemBuilder: (context, index) {
                      final assignment = assignments[index]; 
                      final isQuiz = assignment.title.startsWith('[Quiz]');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => AssignmentDetailScreen(assignment: assignment),
                              ),
                            );
                          },
                          child: IOSGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        assignment.title.replaceAll('[Quiz] ', ''), // Hide the internal tag
                                        style: AppTypography.headline,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, 
                                      ),
                                    ),
                                    if (assignment.generatedContent.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isQuiz 
                                              ? CupertinoColors.activeOrange.withOpacity(0.2)
                                              : AppColors.aiAccent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isQuiz 
                                                ? CupertinoColors.activeOrange.withOpacity(0.5)
                                                : AppColors.aiAccent.withOpacity(0.5)
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(isQuiz ? CupertinoIcons.checkmark_alt : CupertinoIcons.sparkles, 
                                              size: 12, 
                                              color: isQuiz ? CupertinoColors.activeOrange : AppColors.aiAccent
                                            ),
                                            const SizedBox(width: 4),
                                            Text(isQuiz ? 'AI Quiz' : 'AI Task', 
                                              style: AppTypography.caption.copyWith(
                                                color: isQuiz ? CupertinoColors.activeOrange : AppColors.aiAccent
                                              )
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  assignment.generatedContent,
                                  style: AppTypography.subheadline,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Container(height: 0.5, color: AppColors.divider),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      assignment.deadline != null 
                                        ? 'Due: ${assignment.deadline!.day}/${assignment.deadline!.month}/${assignment.deadline!.year}'
                                        : 'No Deadline',
                                      style: AppTypography.footnote,
                                    ),
                                    const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Premium Grid Action Card
  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.headline),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}