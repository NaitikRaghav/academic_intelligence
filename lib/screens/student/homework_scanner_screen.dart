import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Widgets
import '../../widgets/primary_action_button.dart';

class HomeworkScannerScreen extends ConsumerStatefulWidget {
  final String assignmentId;

  const HomeworkScannerScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<HomeworkScannerScreen> createState() => _HomeworkScannerScreenState();
}

class _HomeworkScannerScreenState extends ConsumerState<HomeworkScannerScreen> {
  bool _isCapturing = false;
  bool _isScanning = false;
  bool _scanComplete = false;
  
  String _extractedText = '';

  // Simulate the camera capture and AI OCR extraction
  Future<void> _captureAndScan() async {
    // 1. Camera Shutter Effect
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2. Start AI Scanning Animation
    setState(() {
      _isCapturing = false;
      _isScanning = true;
    });

    // =========================================================================
    // 🛑 THE FRONTEND BYPASS (Simulating Google ML Kit)
    // Your friend will replace this with actual ImagePicker and ML Kit logic
    // =========================================================================
    await Future.delayed(const Duration(seconds: 3));

    // 3. Show Results
    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanComplete = true;
        _extractedText = "According to the Second Law of Thermodynamics, the total entropy of an isolated system can never decrease over time. Therefore, heat cannot spontaneously flow from a colder body to a hotter body.";
      });
    }
  }

  void _submitHomework() {
    // Return to the dashboard and trigger a success message
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceElevated.withOpacity(0.8),
        middle: Text(_scanComplete ? 'Review Extraction' : 'AI Scanner', style: AppTypography.headline),
      ),
      child: SafeArea(
        child: _scanComplete ? _buildReviewScreen() : _buildCameraScreen(),
      ),
    );
  }

  // 📷 The Futuristic Camera Viewfinder
  Widget _buildCameraScreen() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isScanning ? AppColors.aiAccent : AppColors.glassBorder,
                width: _isScanning ? 3 : 1,
              ),
              boxShadow: _isScanning 
                ? [BoxShadow(color: AppColors.aiAccent.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)] 
                : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated Camera Feed (Dark grey placeholder)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                
                // Viewfinder Brackets
                const Icon(CupertinoIcons.viewfinder, size: 250, color: AppColors.glassOverlay),
                
                // Scanning Text Overlay
                if (_isScanning)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20, color: AppColors.aiAccent),
                      SizedBox(height: 16),
                      Text('Extracting Handwriting...', style: TextStyle(color: AppColors.aiAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        
        // Capture Button Area
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: (_isCapturing || _isScanning) ? null : _captureAndScan,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary, width: 4),
              ),
              child: Center(
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: _isCapturing ? AppColors.textSecondary : AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 📝 The Review & Submit Screen
  Widget _buildReviewScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Extracted Text', style: AppTypography.title2),
          const SizedBox(height: 8),
          const Text(
            'Review the text our AI extracted from your handwriting. You can edit it before submitting.',
            style: AppTypography.callout,
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: CupertinoTextField(
                controller: TextEditingController(text: _extractedText),
                maxLines: null,
                expands: true,
                style: AppTypography.body,
                decoration: null, // Removes default border
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          PrimaryActionButton(
            text: 'Submit Homework',
            icon: CupertinoIcons.paperplane_fill,
            isAIAction: false, // Standard action, no glow needed
            onPressed: _submitHomework,
          ),
        ],
      ),
    );
  }
}