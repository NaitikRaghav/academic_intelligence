import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_engine_screen.dart';
import 'homework_submission_screen.dart';

// 📦 Core & Models
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';

// 📦 Providers
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/submission_provider.dart';

// 📦 Screens (Chat)
import '../shared/ai_chat_screen.dart';

// 📦 Widgets
import '../../widgets/ios_glass_card.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  // 0 = Pending, 1 = Completed
  int _selectedTab = 0; 

  @override
  Widget build(BuildContext context) {
    // 1. Get the logged-in student
    final user = ref.watch(authStateProvider).value;
    final studentId = user?.id ?? '';

    // 2. Stream ALL assignments and THIS student's submissions
    final assignmentsAsync = ref.watch(allAssignmentsStreamProvider);
    final submissionsAsync = ref.watch(studentSubmissionsProvider(studentId));

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
        middle: const Text('My Classes', style: AppTypography.headline),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_right, color: AppColors.destructive),
          onPressed: () => ref.read(authServiceProvider).signOut(),
        ),
      ),
      child: SafeArea(
        child: assignmentsAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.destructive))),
          data: (allAssignments) {
            return submissionsAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.destructive))),
              data: (mySubmissions) {
                
                // 🧠 THE SORTING LOGIC: Separate Pending from Completed
                final submittedAssignmentIds = mySubmissions.map((s) => s.assignmentId).toSet();
                
                final pendingAssignments = allAssignments.where((a) => !submittedAssignmentIds.contains(a.id)).toList();
                final completedAssignments = allAssignments.where((a) => submittedAssignmentIds.contains(a.id)).toList();

                final displayList = _selectedTab == 0 ? pendingAssignments : completedAssignments;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER & TAB SELECTOR ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Homework & Quizzes', style: AppTypography.largeTitle),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoSlidingSegmentedControl<int>(
                              backgroundColor: AppColors.surfaceElevated,
                              thumbColor: AppColors.primary,
                              groupValue: _selectedTab,
                              children: {
                                0: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12), 
                                  child: Text('Pending (${pendingAssignments.length})', style: TextStyle(color: _selectedTab == 0 ? CupertinoColors.white : AppColors.textSecondary))
                                ),
                                1: Text('Completed (${completedAssignments.length})', style: TextStyle(color: _selectedTab == 1 ? CupertinoColors.white : AppColors.textSecondary)),
                              },
                              onValueChanged: (val) {
                                if (val != null) setState(() => _selectedTab = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- THE ASSIGNMENT LIST ---
                    Expanded(
                      child: displayList.isEmpty
                          ? Center(
                              child: Text(
                                _selectedTab == 0 ? 'You are all caught up! 🎉' : 'No completed work yet.',
                                style: AppTypography.callout.copyWith(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final assignment = displayList[index];
                                final isQuiz = assignment.title.startsWith('[Quiz]');
                                
                                // Find the submission if it exists (for the Completed tab)
                                final submission = mySubmissions.where((s) => s.assignmentId == assignment.id).firstOrNull;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_selectedTab == 1) {
                                        _showComingSoon(context, "You already completed this! Viewing grades coming soon.");
                                        return;
                                      }

                                      // 🚀 ROUTING: Go to Quiz Engine OR Upload Screen
                                      // 🚀 ROUTING: Go to Quiz Engine OR Upload Screen
                                      if (isQuiz) {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) => QuizEngineScreen(quizAssignment: assignment),
                                          ),
                                        );
                                      } else {
                                        // 👇 FIXED: Now it routes to our new Homework Submission Screen!
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) => HomeworkSubmissionScreen(assignment: assignment),
                                          ),
                                        );
                                      }
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
                                                  assignment.title.replaceAll('[Quiz] ', ''),
                                                  style: AppTypography.headline,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // Tag Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isQuiz ? CupertinoColors.activeOrange.withOpacity(0.2) : AppColors.aiAccent.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: isQuiz ? CupertinoColors.activeOrange.withOpacity(0.5) : AppColors.aiAccent.withOpacity(0.5)),
                                                ),
                                                child: Text(
                                                  isQuiz ? 'Quiz' : 'Assignment',
                                                  style: AppTypography.caption.copyWith(color: isQuiz ? CupertinoColors.activeOrange : AppColors.aiAccent),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Subject: ${assignment.subject ?? 'General'} • Topic: ${assignment.topic ?? 'General'}',
                                            style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(height: 0.5, color: AppColors.divider),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedTab == 0 
                                                  ? (assignment.deadline != null ? 'Due: ${assignment.deadline!.day}/${assignment.deadline!.month}/${assignment.deadline!.year}' : 'No Deadline')
                                                  : (submission != null ? 'Submitted: ${submission.submittedAt.day}/${submission.submittedAt.month}' : 'Submitted'),
                                                style: AppTypography.footnote.copyWith(
                                                  color: _selectedTab == 0 ? AppColors.textPrimary : CupertinoColors.activeGreen,
                                                  fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                              Icon(
                                                _selectedTab == 0 ? CupertinoIcons.play_circle_fill : CupertinoIcons.checkmark_alt_circle_fill, 
                                                color: _selectedTab == 0 ? AppColors.primary : CupertinoColors.activeGreen, 
                                                size: 24
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // A tiny helper to show a popup until we build the next screens in 2 minutes!
  void _showComingSoon(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Next Step Ready'),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }
}