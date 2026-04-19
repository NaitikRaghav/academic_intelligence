import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/ocr_service.dart';

// 1. Expose the Gemini Service
// This will be used by Teachers to generate assignments and by Students for the chatbot.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// 2. Expose the OCR Service
// This will be used in the Submission screen to extract text from handwritten photos.
final ocrServiceProvider = Provider<OCRService>((ref) {
  final ocr = OCRService();
  
  // Clean up the scanner automatically when the screen is closed to save memory
  ref.onDispose(() => ocr.dispose());
  
  return ocr;
});