import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📦 Models & Providers
import '../../models/assignment_model.dart';
import '../../providers/submission_provider.dart';

// 📦 Screens
import 'submission_analyzer_screen.dart';

// 📦 Core & Widgets
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../widgets/ios_glass_card.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 Stream the live submissions for THIS specific assignment
    final submissionsAsync = ref.watch(assignmentSubmissionsProvider(assignment.id));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: const Text('Assignment Details', style: AppTypography.headline),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(assignment.title, style: AppTypography.largeTitle),
              const SizedBox(height: 16),
              
              // --- META DATA BOX ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaRow('Subject', assignment.subject ?? 'N/A'),
                    _buildMetaRow('Topic', assignment.topic ?? 'N/A'),
                    _buildMetaRow('Difficulty', assignment.difficulty?.name.toUpperCase() ?? 'N/A'),
                    _buildMetaRow('Due Date', assignment.deadline != null ? '${assignment.deadline!.day}/${assignment.deadline!.month}/${assignment.deadline!.year}' : 'No Deadline'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Generated Content', style: AppTypography.title2),
              const SizedBox(height: 16),
              
              Text(
                assignment.generatedContent,
                style: AppTypography.body.copyWith(height: 1.5),
              ),
              const SizedBox(height: 48),

              // --- 🚀 NEW: STUDENT SUBMISSIONS INBOX ---
              const Text('Student Submissions', style: AppTypography.title2),
              const SizedBox(height: 16),

              submissionsAsync.when(
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e, st) => Center(child: Text('Error loading submissions: $e', style: const TextStyle(color: AppColors.destructive))),
                data: (submissions) {
                  // If the table is empty, show a beautiful placeholder
                  if (submissions.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder, style: BorderStyle.solid),
                      ),
                      child: const Text(
                        'No submissions yet.\nWaiting for students to complete the assignment.',
                        textAlign: TextAlign.center,
                        style: AppTypography.callout,
                      ),
                    );
                  }

                  // If we have submissions, list them out!
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final sub = submissions[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            // 🚀 ROUTE TO THE AI ANALYZER
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => SubmissionAnalyzerScreen(
                                  assignment: assignment,
                                  submission: sub,
                                ),
                              ),
                            );
                          },
                          child: IOSGlassCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Shows a truncated Student ID for now
                                    Text('Student ID: ${sub.studentId.substring(0, 8)}...', style: AppTypography.headline),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}',
                                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (sub.isLate)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.destructiveRed.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('LATE', style: AppTypography.caption.copyWith(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold)),
                                      ),
                                    // A spark icon indicating this is ready for AI grading
                                    const Icon(CupertinoIcons.sparkles, color: AppColors.aiAccent, size: 20),
                                    const SizedBox(width: 8),
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

  // Helper widget for clean layout
  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: AppTypography.footnote.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTypography.callout)),
        ],
      ),
    );
  }
}