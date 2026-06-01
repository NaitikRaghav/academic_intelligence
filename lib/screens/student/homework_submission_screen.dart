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
import '../../widgets/cupertino_text_field.dart';

class HomeworkSubmissionScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;

  const HomeworkSubmissionScreen({super.key, required this.assignment});

  @override
  ConsumerState<HomeworkSubmissionScreen> createState() => _HomeworkSubmissionScreenState();
}

class _HomeworkSubmissionScreenState extends ConsumerState<HomeworkSubmissionScreen> {
  final TextEditingController _textController = TextEditingController();
  
  bool _isUploadingFile = false;
  String? _attachedFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 📸 Simulates the device camera/file picker scanning a document
  Future<void> _simulateFileScan() async {
    setState(() => _isUploadingFile = true);
    
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _attachedFileName = 'scanned_worksheet_01.pdf';
      _isUploadingFile = false;
    });
  }

  Future<void> _submitHomework() async {
    final typedText = _textController.text.trim();

    // Make sure they actually did the work!
    if (typedText.isEmpty && _attachedFileName == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Empty Submission'),
          content: const Text('Please type an answer or attach a scanned document.'),
          actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('No user logged in!');

      // Build the Submission Model
      final submission = SubmissionModel(
        id: 'uuid_placeholder',
        assignmentId: widget.assignment.id,
        studentId: user.id,
        fileUrl: _attachedFileName ?? '', 
        // 👇 We safely use ocrText here so it doesn't crash your Supabase!
        ocrText: typedText.isNotEmpty ? typedText : 'Submitted via attached document.', 
        submittedAt: DateTime.now(),
      );

      // Save to Supabase
      await ref.read(databaseServiceProvider).submitAssignment(submission);

      if (mounted) {
        Navigator.of(context).pop(); // Go back to dashboard on success
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
        middle: const Text('Submit Homework', style: AppTypography.headline),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ASSIGNMENT DETAILS ---
                    Text(widget.assignment.title, style: AppTypography.largeTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Subject: ${widget.assignment.subject} • Topic: ${widget.assignment.topic}',
                      style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // --- UPLOAD / SCANNER BOX ---
                    const Text('Attach File', style: AppTypography.title2),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _simulateFileScan,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: _attachedFileName != null ? CupertinoColors.activeGreen.withOpacity(0.1) : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _attachedFileName != null ? CupertinoColors.activeGreen : AppColors.glassBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_isUploadingFile)
                              const CupertinoActivityIndicator(radius: 14)
                            else if (_attachedFileName != null) ...[
                              const Icon(CupertinoIcons.checkmark_seal_fill, color: CupertinoColors.activeGreen, size: 40),
                              const SizedBox(height: 12),
                              Text(_attachedFileName!, style: AppTypography.headline.copyWith(color: CupertinoColors.activeGreen)),
                            ] else ...[
                              const Icon(CupertinoIcons.camera_viewfinder, color: AppColors.primary, size: 40),
                              const SizedBox(height: 12),
                              const Text('Tap to Scan Document', style: AppTypography.headline),
                              const SizedBox(height: 4),
                              Text('PDF, JPG, or PNG', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- TEXT SUBMISSION BOX ---
                    const Text('Or Type Answer', style: AppTypography.title2),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: CupertinoTextField(
                        controller: _textController,
                        placeholder: 'Type your essay or assignment response here...',
                        placeholderStyle: const TextStyle(color: AppColors.textSecondary),
                        style: const TextStyle(color: CupertinoColors.white), 
                        maxLines: null, 
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        padding: const EdgeInsets.all(16),
                        decoration: null, 
                      ),
                    ),
                  ],
                ), // 👇 These were the missing brackets!
              ),
            ),

            // --- FIXED SUBMIT BUTTON ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: PrimaryActionButton(
                text: _isSubmitting ? 'Submitting...' : 'Turn In Assignment',
                icon: CupertinoIcons.paperplane_fill,
                isAIAction: false,
                isLoading: _isSubmitting,
                onPressed: _submitHomework,
              ),
            ),
          ],
        ),
      ),
    );
  }
}