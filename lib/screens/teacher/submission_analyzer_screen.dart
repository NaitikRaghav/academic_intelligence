import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Models & Services
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';
import '../../services/gemini_service.dart';

// Widgets
import '../../widgets/ios_glass_card.dart';
import '../../widgets/primary_action_button.dart';

class SubmissionAnalyzerScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;
  final SubmissionModel submission;

  const SubmissionAnalyzerScreen({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  ConsumerState<SubmissionAnalyzerScreen> createState() => _SubmissionAnalyzerScreenState();
}

class _SubmissionAnalyzerScreenState extends ConsumerState<SubmissionAnalyzerScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiReport;

  Future<void> _runAIAnalysis() async {
    setState(() => _isAnalyzing = true);

    try {
      // 🚀 The Magic: We pass the teacher's original questions AND the student's text to Gemini
      final report = await GeminiService().evaluateSubmission(
        assignmentTitle: widget.assignment.title,
        assignmentQuestions: widget.assignment.generatedContent,
        studentSubmissionText: widget.submission.ocrText ?? widget.submission.cleanedText ?? 'No text provided by student.',
      );

      setState(() {
        _aiReport = report;
      });

      // TODO in Step 3: Save this report to your 'evaluations' table in Supabase!
      
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Analysis Failed'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.sparkles, size: 18, color: AppColors.aiAccent),
            SizedBox(width: 8),
            Text('AI Analyzer', style: AppTypography.headline),
          ],
        ),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- STUDENT SUBMISSION DATA ---
              const Text('Student Submission', style: AppTypography.title2),
              const SizedBox(height: 12),
              IOSGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assignment: ${widget.assignment.title}', style: AppTypography.headline),
                    const SizedBox(height: 8),
                    Container(height: 0.5, color: AppColors.divider),
                    const SizedBox(height: 12),
                    Text(
                      widget.submission.ocrText ?? widget.submission.cleanedText ?? 'Attached a file...',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- AI ACTION OR REPORT ---
              if (_aiReport == null) ...[
                const Text('AI Evaluation', style: AppTypography.title2),
                const SizedBox(height: 12),
                const Text(
                  'Run the Gemini Analyzer to instantly grade this submission against your original assignment rubrics.',
                  style: AppTypography.callout,
                ),
                const SizedBox(height: 24),
                PrimaryActionButton(
                  text: _isAnalyzing ? 'Analyzing Submission...' : 'Generate Grading Report',
                  icon: CupertinoIcons.sparkles,
                  isAIAction: true,
                  isLoading: _isAnalyzing,
                  onPressed: _runAIAnalysis,
                ),
              ] else ...[
                // THE BEAUTIFUL AI REPORT DASHBOARD
                const Text('Grading Report', style: AppTypography.title2),
                const SizedBox(height: 16),
                
                // Score Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.aiAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.aiAccent.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Final Score', style: AppTypography.title2),
                      Text(
                        '${_aiReport!['score'] ?? 0} / 10', 
                        style: AppTypography.largeTitle.copyWith(color: AppColors.aiAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Summary
                IOSGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Summary', style: AppTypography.headline),
                      const SizedBox(height: 8),
                      Text(_aiReport!['summary'] ?? '', style: AppTypography.body),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Strengths & Weaknesses
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeedbackList('Strengths', CupertinoColors.activeGreen, _aiReport!['strengths'] ?? [])),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFeedbackList('Weaknesses', CupertinoColors.destructiveRed, _aiReport!['weaknesses'] ?? [])),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Helper widget to draw nice bullet points for Strengths/Weaknesses
  Widget _buildFeedbackList(String title, Color color, List<dynamic> items) {
    return IOSGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(title == 'Strengths' ? CupertinoIcons.arrow_up_circle_fill : CupertinoIcons.arrow_down_circle_fill, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.headline.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Expanded(child: Text(item.toString(), style: AppTypography.footnote)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}