import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homework_scanner_screen.dart';
import '../shared/ai_chat_screen.dart';
// 📦 1. CORE
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// 📦 2. MODELS
import '../../models/assignment_model.dart';

// 📦 3. PROVIDERS
import '../../providers/assignment_provider.dart';
import '../../providers/auth_provider.dart';

// 📦 4. WIDGETS
import '../../widgets/ios_glass_card.dart';
import '../../widgets/primary_action_button.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // =========================================================================
    // 🛑 THE FRONTEND BYPASS (MOCK DATA)
    // =========================================================================
    final List<AssignmentModel> mockPendingAssignments = [
      AssignmentModel(
        id: 'mock_1',
        teacherId: 'teacher_123',
        title: 'Advanced Thermodynamics',
        description: 'Please explain the Second Law of Thermodynamics using real-world examples.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        aiGenerated: true,
        createdAt: DateTime.now(),
      ),
    ];

    // =========================================================================
    // 🟢 THE BACKEND READY ZONE 
    // Your friend will uncomment this later to stream the student's actual tasks
    // =========================================================================
    // final liveAssignments = ref.watch(allAssignmentsProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      
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
          onPressed: () => ref.read(authServiceProvider).signOut(),
        ),
      ),
      
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WELCOME HEADER ---
              const Text('Ready to learn?', style: AppTypography.largeTitle),
              const SizedBox(height: 8),
              const Text(
                'View your pending tasks and use AI to scan your handwritten work.',
                style: AppTypography.callout,
              ),
              const SizedBox(height: 32),

              // --- THE CAMERA / AI SCANNER BUTTON ---
              PrimaryActionButton(
                text: 'Scan Handwritten Homework',
                icon: CupertinoIcons.camera_viewfinder,
                isAIAction: true, // Triggers the presentation-ready Indigo glow
                onPressed: () {
                  // TODO: Open OCR Camera Scanner
                  // 👇 ADD THIS NAVIGATION 👇
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const HomeworkScannerScreen(assignmentId: 'general'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // --- ASSIGNMENTS LIST HEADER ---
              const Text('Pending Tasks', style: AppTypography.title2),
              const SizedBox(height: 16),

              // --- ASSIGNMENTS LIST ---
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mockPendingAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = mockPendingAssignments[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    // Wrapping the card in a CupertinoButton so they can tap it to go to the Shared Screen!
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // TODO: Navigate to the Shared Assignment Details Screen
                      },
                      child: IOSGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // Top Row: Title & Warning Badge
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Due in 3 Days', 
                                    style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)
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
                            // ✅ Add this standard iOS hairline separator:
                            Container(
                              height: 0.5, // 0.5 gives that ultra-thin, premium Apple feel
                              color: AppColors.divider,
                            ),
                            const SizedBox(height: 8),
                            
                            // Bottom Row: Action Arrow
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('View Details', style: AppTypography.footnote),
                                SizedBox(width: 4),
                                Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 16),
                              ],
                            ),
                          ],
                        ),
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